#include <perl.h>
#include "try-catch-constants.h"

int my_is_end_of_block(pTHX_ SV* rv) {
    return SvROK(rv) && (SvRV(rv) == end_of_block_sv);
}

static void my_setup_constants(pTHX) {
    internal_stash = gv_stashpv(MAIN_PKG, 0);

    // create read-only unique value for "END_OF_BLOCK*" macros
    end_of_block_sv = newSV(0);
    SvREADONLY_on(end_of_block_sv);

    hintkey_enabled_sv = newSVpvs_share(HINTKEY_ENABLED);
    newCONSTSUB(internal_stash, "HINTKEY_ENABLED",   hintkey_enabled_sv);
}
