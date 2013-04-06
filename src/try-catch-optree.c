#include "try-catch-constants.h"
#include "try-catch-optree.h"

/* build optree for catch call arguments:
 *  ( $block_ref, $class_name )
 *  or
 *  ( $block_ref )
 */
static OP* my_build_catch_args_optree(pTHX_ OP* block_op, SV* class_name_sv) {
    OP *class_name_op = class_name_sv ? build_const_sv_op(class_name_sv) : NULL;
    return newLISTOP(OP_LIST, 0, (block_op), class_name_op);
}

/* build optree for:
 *  <MAIN_PKG>::_statement($try_block, [@catch_blocks], $finally_block);
 *  or
 *  <MAIN_PKG>::_statement($try_block, [@catch_blocks]);
 */
static OP *my_build_statement_optree(pTHX_
            OP *try_block_op, OP* catch_list_op, OP* finally_block_op
) {
    GV *handler_gv;
    OP *args_op, *call_op;

    args_op = newLISTOP(OP_LIST, 0, try_block_op, newANONLIST(catch_list_op));
    args_op = op_append_elem(OP_LIST, args_op, finally_block_op);

    handler_gv = gv_fetchmethod(internal_stash, "_statement");
    call_op = newUNOP(OP_ENTERSUB, OPf_STACKED,
            op_append_elem(OP_LIST, args_op,
                newGVOP(OP_GV, 0, handler_gv)
            )
        );
    return op_scope(call_op);
}

