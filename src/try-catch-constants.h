#ifndef __TRY_CATCH_CONSTANTS__
#define __TRY_CATCH_CONSTANTS__

#include <perl.h>

/*** constants ***/

#define MAIN_PKG            "Syntax::Feature::Try"
#define HINTKEY_ENABLED     MAIN_PKG "/enabled"

static HV *internal_stash;
static SV *hintkey_enabled_sv, *end_of_block_sv;

#define END_OF_BLOCK_SV     newRV_inc(end_of_block_sv)
#define IS_END_OF_BLOCK(sv) my_is_end_of_block(aTHX_ sv)
int my_is_end_of_block(pTHX_ SV* rv);

#define setup_constants()   my_setup_constants(aTHX)
static void my_setup_constants(pTHX);

#endif /* __TRY_CATCH_CONSTANTS__ */
