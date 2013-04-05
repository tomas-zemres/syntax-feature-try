#include <EXTERN.h>
#include <perl.h>

#define NO_XSLOCKS
#include <XSUB.h>

#include "try-catch-common.c"
#include "try-catch-hints.c"
#include "try-catch-parser.c"

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

PROTOTYPES: DISABLE

BOOT:
{
    setup_constants();

    next_keyword_plugin = PL_keyword_plugin;
    PL_keyword_plugin = my_keyword_plugin;
}

