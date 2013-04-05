#ifndef __TRY_CATCH_COMMON__
#define __TRY_CATCH_COMMON__

#include <perl.h>

/*** constants ***/

#define MAIN_PKG            "Syntax::Feature::Try"
#define HINTKEY_ENABLED     MAIN_PKG "/enabled"
#define HINTKEY_BLOCK       MAIN_PKG "/block"

static SV *hintkey_enabled_sv, *hintkey_block_sv;

static void setup_constants();

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
