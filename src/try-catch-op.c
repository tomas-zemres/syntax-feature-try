#include "try-catch-constants.h"
#include "try-catch-op.h"

#include <perl.h>

#define build_assign_op(left_sv, right_op) \
        newASSIGNOP(0, newSVOP(left_sv, 0), OP_SASSIGN, newSVOP(right_sv, 0))

/*
 * append: END_OF_BLOCK_SV
 */
static OP* my_build_block_content_op(pTHX_ OP* orig_content_op) {
    return op_append_elem(OP_LINESEQ,
            orig_content_op,
            newSVOP(OP_CONST, 0, END_OF_BLOCK_SV)
        );
}

/* build optree for catch call arguments:
 *  ( $block_ref, $class_name )
 *  or
 *  ( $block_ref )
 */
static OP* my_build_catch_args_optree(pTHX_ OP* block_op, SV* class_name_sv) {
    OP *class_name_op = class_name_sv ? build_const_sv_op(class_name_sv) : NULL;
    return newLISTOP(OP_LIST, 0, (block_op), class_name_op);
}

#define call_sub_op(name, args_op)  my_call_sub_op(aTHX_ name, args_op)
static OP* my_call_sub_op(pTHX_ char *name, OP* args_op) {
    GV *sub_gv = gv_fetchmethod(internal_stash, name);

    return newUNOP(OP_ENTERSUB, OPf_STACKED,
            op_append_elem(OP_LIST, args_op,
                newGVOP(OP_GV, 0, sub_gv)
            )
        );
}

/* build optree for:
 *  <MAIN_PKG>::_statement($try_block, [@catch_blocks], $finally_block);
 *  or
 *  <MAIN_PKG>::_statement($try_block, [@catch_blocks]);
 */
static OP *my_build_statement_optree(pTHX_
            OP *try_block_op, OP* catch_list_op, OP* finally_block_op
) {
    OP *args_op, *call_op, *return_op;

    catch_list_op = catch_list_op ? newANONLIST(catch_list_op)
                                  : newOP(OP_UNDEF, 0);

    args_op = newLISTOP(OP_LIST, 0, try_block_op, catch_list_op);
    args_op = op_append_elem(OP_LIST, args_op, finally_block_op);

    call_op = call_sub_op("_statement", args_op);
    return_op = newUNOP(OP_RETURN, 0, call_sub_op("_get_return_value", NULL));

    return newCONDOP(0, call_op, return_op, NULL);
}

