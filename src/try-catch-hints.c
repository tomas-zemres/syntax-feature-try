#include "try-catch-hints.h"

static PERL_CONTEXT* get_current_sub_context() {
    I32 i;
    for (i = cxstack_ix; i >= 0; i--) {
        register PERL_CONTEXT* cx = cxstack+i;
        if (CxTYPE(cx) == CXt_SUB) {
            return cx;
        }
    }
    return NULL;
}

static int my_is_inside_special_block(pTHX) {
    const PERL_CONTEXT * const cx = get_current_sub_context();

    return !cx || SvTRUE(get_stack_block_hint(cx));
}

