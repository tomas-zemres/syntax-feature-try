#ifndef __TRY_CATCH_HINTS__
#define __TRY_CATCH_HINTS__

#include <perl.h>

#define get_cop_hint_value(cop, key_sv) \
        cop_hints_fetch_sv((cop), (key_sv), 0, 0)

#define get_stack_block_hint(cx) \
        get_cop_hint_value((cx)->blk_oldcop, hintkey_block_sv)

#define is_syntax_enabled() \
        SvTRUE( get_cop_hint_value(PL_curcop, hintkey_enabled_sv) )

#define is_inside_special_block() my_is_inside_special_block(aTHX)
static int my_is_inside_special_block(pTHX);

#endif /* __TRY_CATCH_HINTS__ */
