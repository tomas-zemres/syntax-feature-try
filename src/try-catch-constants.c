#include <perl.h>
#include "try-catch-constants.h"

static void my_setup_constants(pTHX) {
    hintkey_enabled_sv = newSVpvs_share(HINTKEY_ENABLED);
    hintkey_block_sv = newSVpvs_share(HINTKEY_BLOCK);

    internal_stash = gv_stashpv(MAIN_PKG, 0);
    newCONSTSUB(internal_stash, "HINTKEY_ENABLED",   hintkey_enabled_sv);
    newCONSTSUB(internal_stash, "HINTKEY_BLOCK",     hintkey_block_sv);
    newCONSTSUB(internal_stash, "BLOCK_TRY",         newSViv(BLOCK_TRY));
    newCONSTSUB(internal_stash, "BLOCK_CATCH",       newSViv(BLOCK_CATCH));
    newCONSTSUB(internal_stash, "BLOCK_FINALLY",     newSViv(BLOCK_FINALLY));
}
