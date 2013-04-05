#include "try-catch-constants.h"
#include "try-catch-stack.h"

#include <perl.h>

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

