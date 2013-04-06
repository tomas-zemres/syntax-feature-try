#include <EXTERN.h>
#include <perl.h>

#define NO_XSLOCKS
#include <XSUB.h>

#include "try-catch-constants.c"
#include "try-catch-stack.c"
#include "try-catch-hints.c"
#include "try-catch-parser.c"
#include "try-catch-optree.c"

/* setup keyword plugin */
static int (*next_keyword_plugin)(pTHX_ char *, STRLEN, OP **);

static int my_keyword_plugin(pTHX_ char *keyword_ptr, STRLEN keyword_len,
                                OP **op_ptr)
{
    if (is_syntax_enabled()) {
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

PROTOTYPES: DISABLED

BOOT:
{
    setup_constants();

    next_keyword_plugin = PL_keyword_plugin;
    PL_keyword_plugin = my_keyword_plugin;
}

void
run_block(SV* coderef, SV* arg1=NULL)
    CODE:
    {
        dSP;
        PERL_CONTEXT *upper_sub_cx;
        I32 gimme;

        upper_sub_cx = get_sub_context(1);
        gimme = upper_sub_cx ? upper_sub_cx->blk_gimme : 0;

        ENTER;
        SAVETMPS;

        PUSHMARK(SP);
        if (SvTRUE(arg1)) {
            XPUSHs(arg1);
        }
        PUTBACK;
        call_sv(coderef, gimme | G_DISCARD);

        FREETMPS;
        LEAVE;
    }
