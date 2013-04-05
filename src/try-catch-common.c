#include <perl.h>
#include "try-catch-common.h"

static void setup_constants() {
    HV *stash;

    hintkey_enabled_sv = newSVpvs_share(HINTKEY_ENABLED);
    hintkey_block_sv = newSVpvs_share(HINTKEY_BLOCK);

    stash = gv_stashpv(MAIN_PKG, 0);
    newCONSTSUB(stash, "HINTKEY_ENABLED", hintkey_enabled_sv);
}
