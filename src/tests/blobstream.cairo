use blobstream::{
    VALIDATOR_SET_HASH_DOMAIN_SEPARATOR, DATA_ROOT_TUPLE_ROOT_DOMAIN_SEPARATOR
};
use core::bytes_31::one_shift_left_bytes_u128;

#[test]
fn constants_test() {
    let checkpoint = 'checkpoint' * one_shift_left_bytes_u128(6);
    assert!(VALIDATOR_SET_HASH_DOMAIN_SEPARATOR.high == checkpoint, "incorrect checkpoint const");
    assert!(
        DATA_ROOT_TUPLE_ROOT_DOMAIN_SEPARATOR.high == 'transactionBatch',
        "incorrect transactinBatch const"
    );
}
