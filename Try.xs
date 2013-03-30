#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>

static SV *hintkey_syntax_enabled;
static int (*next_keyword_plugin)(pTHX_ char *, STRLEN, OP **);

static void setup_constants() {
    hintkey_syntax_enabled = newSVpvs_share("Syntax::Feature::Try/enabled");
}

#define lex_buf_ptr         ( PL_parser->bufptr )
#define lex_buf_end         ( PL_parser->bufend )
#define lex_buf_len         ( lex_buf_end - lex_buf_ptr )
#define lex_next_char       ( lex_buf_len > 0 ? lex_buf_ptr[0] : 0 )
#define lex_read(n)         lex_read_to(lex_buf_ptr + (n))

#ifdef TRY_PARSER_DEBUG
    #include <perlio.h>
    #define DEBUG_MSG(fmt...)   PerlIO_printf(PerlIO_stderr(), "TRY_PARSER_DEBUG: " fmt)
#else
    #define DEBUG_MSG(fmt...)
#endif

static void syntax_error(const char *msg) {
    croak("syntax error: %s", msg);
}

static int parse_char(const char c) {
    if (lex_next_char != c) {
        return 0;   // different character found
    }

    lex_read(1);
    DEBUG_MSG("char: %c\n", c);
    return 1;
}

static int parse_keyword(char *keyword)
{
    char *b_ptr, *kw_ptr;

    b_ptr = lex_buf_ptr;
    for (kw_ptr = keyword; *kw_ptr; kw_ptr++) {
        if ( (lex_buf_end <= b_ptr) || (*kw_ptr != *b_ptr) ) {
            return 0;   // expected keyword does not match
        }
        b_ptr++;
    }

    if ( (lex_buf_end > b_ptr) && (isWORDCHAR(*b_ptr) || (*b_ptr == ':')) ) {
        return 0;   // there is not end of scanned keyword
    }

    lex_read_to(b_ptr);
    DEBUG_MSG("keyword: %s\n", keyword);
    return 1;
}

static SV *parse_identifier(int allow_namespace) {
    SV *ident;
    char *end_ptr;

    end_ptr = lex_buf_ptr;
    while (end_ptr < lex_buf_end) {
        if ( (*end_ptr == ':') && allow_namespace
             && (end_ptr+1 < lex_buf_end) && (end_ptr[1] == ':')
        ) {
            // namespace separator "::" in identifier
            end_ptr += 2;
            continue;
        }

        if (!isWORDCHAR(*end_ptr)) {
            break; // end of identifier found
        }
        end_ptr++;
    }

    if (end_ptr == lex_buf_ptr) {
        return 0;   // perl-identifier not found
    }

    ident = newSVpvn(lex_buf_ptr, end_ptr - lex_buf_ptr);
    lex_read_to(end_ptr);
    return ident;
}

static OP *parse_code_block(char *inject_code) {
    I32 floor;
    OP *ret;

    lex_read_space(0);
    if (lex_next_char != '{') {
        return 0;
    }

    // TODO better might be inject OPcode tree - instead of source-code
    if (inject_code) {
        DEBUG_MSG("Inject into block: %s\n", inject_code);
        lex_read_to(lex_buf_ptr+1);
        lex_stuff_pvn(inject_code, strlen(inject_code), 0);
        lex_stuff_pvs("{", 0);
    }

    floor = start_subparse(0, CVf_ANON);
    ret = newANONSUB(floor, NULL, parse_block(0));
    lex_read_space(0);

    DEBUG_MSG("{ ... }\n");
    return ret;
}

static void warn_on_unusual_class_name(char *name) {
    char *c;

    // do not warn if class-name contains ':' or any upper char
    for (c=name; *c; c++) {
        if ((*c == ':') || isUPPER(*c)) {
            return;
        }
    }

    warn("catch: lower case class-name '%s' may lead to confusion"
         " with perl keywords", name);
}

static OP *parse_catch_args() {
    SV *class_name, *var_name;
    OP *catch_args, *catch_block;
    static char inject_buf[1024];

    lex_read_space(0);
    if (!parse_char('(')) {
        syntax_error("expected '(' after catch");
    }

    catch_args = NULL;

    // exception class-name
    lex_read_space(0);
    class_name = parse_identifier(1);
    if (class_name) {
        DEBUG_MSG("class-name: %s\n", SvPVbyte_nolen(class_name));
        warn_on_unusual_class_name(SvPVbyte_nolen(class_name));
        catch_args = newSVOP(OP_CONST, 0, class_name);
    }

    // exception variable-name
    lex_read_space(0);
    if (!parse_char('$')) {
        syntax_error("invalid catch syntax");
    }
    var_name = sv_2mortal(parse_identifier(0));
    if (!var_name) {
        syntax_error("invalid catch syntax");
    }
    DEBUG_MSG("varname: %s\n", SvPVbyte_nolen(var_name));

    lex_read_space(0);
    if (!parse_char(')')) {
        syntax_error("invalid catch syntax");
    }

    catch_block = parse_code_block(form("my $%s=shift;", SvPVbyte_nolen(var_name)));
    if (!catch_block) {
        syntax_error("expected block after 'catch()'");
    }
    return newLISTOP(OP_LIST, 0, catch_block, catch_args);
}

static OP *parse_all_catch_blocks() {
    OP *catch_list, *catch_args;

    catch_list = NULL;
    while (parse_keyword("catch")) {
        catch_args = parse_catch_args();
        catch_args = newANONLIST(catch_args);

        catch_list = catch_list
                        ? op_append_elem(OP_LIST, catch_list, catch_args)
                        : newLISTOP(OP_LIST, 0, catch_args, NULL);
    }
    return catch_list;
}

static OP *parse_finally_block() {
    OP *finally_block;

    if (!parse_keyword("finally")) {
        return NULL;
    }

    finally_block = parse_code_block(NULL);
    if (!finally_block) {
        syntax_error("expected block after 'finally'");
    }
    return finally_block;
}

static OP *new_op_method_call(OP *self, SV* meth_name, OP* args) {
    return newUNOP(OP_ENTERSUB, OPf_STACKED,
        op_append_elem(OP_LIST,
            op_prepend_elem(OP_LIST, self, args),
            newSVOP(OP_METHOD_NAMED, 0, meth_name)
        )
    );
}

/* build optree for:
 *  {
 *      Syntax::Feature::Try::Handler->new(@args)->run();
 *  }
 */
static OP *build_try_statement_op(OP *args) {
    OP *op_class_name, *op_obj, *op_run;
    op_class_name = newSVOP(OP_CONST, 0,
                        newSVpvs_share("Syntax::Feature::Try::Handler"));
    op_obj = new_op_method_call(op_class_name, newSVpvs_share("new"), args);
    op_run = new_op_method_call(op_obj, newSVpvs_share("run"), NULL);
    return op_scope(op_run);
}

static OP *parse_try_statement()
{
    OP *try_block, *catch_list, *catch_args, *catch_block, *finally_block;

    try_block = parse_code_block(NULL);
    if (!try_block) {
        syntax_error("expected block after 'try'");
    }

    catch_list = parse_all_catch_blocks();
    finally_block = parse_finally_block();

    if (!catch_list && !finally_block) {
        syntax_error("expected catch/finally after try block");
    }

#ifdef TRY_PARSER_DUMP
    op_dump(catch_list);
#endif
    return build_try_statement_op(
        op_append_elem(
            OP_LIST,
            newLISTOP(OP_LIST, 0, try_block, newANONLIST(catch_list)),
            finally_block
        )
    );
}

/* keyword plugin */

#define is_keyword_active(hintkey_sv) THX_is_keyword_active(aTHX_ hintkey_sv)
static int THX_is_keyword_active(pTHX_ SV *hintkey_sv)
{
    HE *he;
    if (!GvHV(PL_hintgv)) {
        return 0;
    }
    he = hv_fetch_ent(GvHV(PL_hintgv), hintkey_sv, 0,
            SvSHARED_HASH(hintkey_sv)
        );
    return he && SvTRUE(HeVAL(he));
}

static int my_keyword_plugin(
            pTHX_ char *keyword_ptr, STRLEN keyword_len, OP **op_ptr)
{
    if (is_keyword_active(hintkey_syntax_enabled)) {
        if ((keyword_len == 3) && strnEQ(keyword_ptr, "try", 3)) {
            *op_ptr = parse_try_statement();
            return KEYWORD_PLUGIN_STMT;
        }
        if ((keyword_len == 5) && strnEQ(keyword_ptr, "catch", 5)) {
            syntax_error("try/catch/finally sequence");
        }
        if ((keyword_len == 7) && strnEQ(keyword_ptr, "finally", 7)) {
            syntax_error("finally without try block");
        }
    }
    return next_keyword_plugin(aTHX_ keyword_ptr, keyword_len, op_ptr);
}

MODULE = Syntax::Feature::Try  PACKAGE = Syntax::Feature::Try

PROTOTYPES: DISABLE

BOOT:
{
    setup_constants();

    next_keyword_plugin = PL_keyword_plugin;
    PL_keyword_plugin = my_keyword_plugin;
}
