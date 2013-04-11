#ifndef __TRY_CATCH_CONSTANTS__
#define __TRY_CATCH_CONSTANTS__

#include <perl.h>

/*** constants ***/

#define MAIN_PKG            "Syntax::Feature::Try"
#define HINTKEY_ENABLED     MAIN_PKG "/enabled"
#define HINTKEY_BLOCK       MAIN_PKG "/block"

#define BLOCK_TRY       1
#define BLOCK_CATCH     2
#define BLOCK_FINALLY   3

#define VAR_NAME_end_of_block   MAIN_PKG "::end_of_block"

static HV *internal_stash;
static SV *hintkey_enabled_sv, *hintkey_block_sv;

#define setup_constants()   my_setup_constants(aTHX)
static void my_setup_constants(pTHX);

#endif /* __TRY_CATCH_CONSTANTS__ */
