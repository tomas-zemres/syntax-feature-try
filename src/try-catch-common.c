#include <perl.h>
#include "try-catch-common.h"

static void my_setup_constants(pTHX) {
    HV *stash;

    hintkey_enabled_sv = newSVpvs_share(HINTKEY_ENABLED);
    hintkey_block_sv = newSVpvs_share(HINTKEY_BLOCK);

    stash = gv_stashpv(MAIN_PKG, 0);
    newCONSTSUB(stash, "HINTKEY_ENABLED",   hintkey_enabled_sv);
    newCONSTSUB(stash, "HINTKEY_BLOCK",     hintkey_block_sv);
    newCONSTSUB(stash, "BLOCK_TRY",         newSViv(BLOCK_TRY));
    newCONSTSUB(stash, "BLOCK_CATCH",       newSViv(BLOCK_CATCH));
    newCONSTSUB(stash, "BLOCK_FINALLY",     newSViv(BLOCK_FINALLY));
}
