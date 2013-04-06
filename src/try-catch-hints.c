#include "try-catch-hints.h"
#include "try-catch-stack.h"

static int my_is_inside_special_block(pTHX) {
    const PERL_CONTEXT * const cx = get_sub_context(0);

    return !cx || SvTRUE(get_stack_block_hint(cx));
}

