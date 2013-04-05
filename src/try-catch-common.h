#ifndef __TRY_CATCH_COMMON__
#define __TRY_CATCH_COMMON__

#include <perl.h>

/*** constants ***/

#define MAIN_PKG            "Syntax::Feature::Try"
#define HINTKEY_ENABLED     MAIN_PKG "/enabled"
#define HINTKEY_BLOCK       MAIN_PKG "/block"

#define BLOCK_TRY       1
#define BLOCK_CATCH     2
#define BLOCK_FINALLY   3

static SV *hintkey_enabled_sv, *hintkey_block_sv;

#define setup_constants()   my_setup_constants(aTHX)
static void my_setup_constants(pTHX);

/*** debug ***/

#ifdef TRY_PARSER_DEBUG
    #include <perlio.h>
    #define DEBUG_MSG(fmt...)   PerlIO_printf(PerlIO_stderr(), "TRY_PARSER_DEBUG: " fmt)
#else
    #define DEBUG_MSG(fmt...)
#endif

/*** error reporting ***/

#define syntax_error(msg)   croak("syntax error: %s", msg)
#define internal_error(msg) croak("internal " MAIN_PKG " error: %s", msg)

#endif /* __TRY_CATCH_COMMON__ */
