#include "try-catch-constants.h"
#include "try-catch-optree.h"

#include <perl.h>

#define build_assign_op(left_sv, right_op) \
        newASSIGNOP(0, newSVOP(left_sv, 0), OP_SASSIGN, newSVOP(right_sv, 0))

/*
 * append: $Syntax::Feature::Try::end_of_block = 1;
 */
static OP* my_build_block_content_op(pTHX_ OP* orig_content_op) {
    OP* var_end_op;

    var_end_op = newSVREF(
                    newGVOP(OP_GV, 0,
                        gv_fetchpvs(VAR_NAME_end_of_block, 0, 0)
                    )
                );

    return op_append_elem(OP_LINESEQ,
            orig_content_op,
//            newOP(OP_UNDEF, 0)
            newASSIGNOP(0, var_end_op, 0,
                newSVOP(OP_CONST, 0, &PL_sv_yes)
            )
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

/* build optree for:
 *  <MAIN_PKG>::_statement($try_block, [@catch_blocks], $finally_block);
 *  or
 *  <MAIN_PKG>::_statement($try_block, [@catch_blocks]);
 */
static OP *my_build_statement_optree(pTHX_
            OP *try_block_op, OP* catch_list_op, OP* finally_block_op
) {
    GV *handler_gv, *return_value_gv;
    OP *args_op, *call_op, *return_op;

    catch_list_op = catch_list_op ? newANONLIST(catch_list_op)
                                  : newOP(OP_UNDEF, 0);

    args_op = newLISTOP(OP_LIST, 0, try_block_op, catch_list_op);
    args_op = op_append_elem(OP_LIST, args_op, finally_block_op);

    handler_gv = gv_fetchmethod(internal_stash, "_statement");
    call_op = newUNOP(OP_ENTERSUB, OPf_STACKED,
            op_append_elem(OP_LIST, args_op,
                newGVOP(OP_GV, 0, handler_gv)
            )
        );

    // TODO deduplicate with previous call op
    return_value_gv = gv_fetchmethod(internal_stash, "_get_return_value");
    return_op = newUNOP(OP_RETURN, 0,
                    newUNOP(OP_ENTERSUB, OPf_STACKED,
                        newGVOP(OP_GV, 0, return_value_gv)
                    )
                );
    return newCONDOP(0, call_op, return_op, NULL);
}

