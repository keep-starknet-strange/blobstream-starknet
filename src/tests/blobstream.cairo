use blobstream::{
    VALIDATOR_SET_HASH_DOMAIN_SEPARATOR, DATA_ROOT_TUPLE_ROOT_DOMAIN_SEPARATOR, IDAOracleDispatcher
};
use core::bytes_31::one_shift_left_bytes_u128;
use snforge_std::{declare, ContractClassTrait};

#[test]
fn constants_test() {
    let checkpoint = 'checkpoint' * one_shift_left_bytes_u128(6);
    assert!(VALIDATOR_SET_HASH_DOMAIN_SEPARATOR.high == checkpoint, "checkpoint const");
    assert!(
        DATA_ROOT_TUPLE_ROOT_DOMAIN_SEPARATOR.high == 'transactionBatch', "transactinBatch const"
    );
}

#[test]
fn setup_test() {
    let contract = declare('Blobstream');
    let contract_address = contract.deploy(@ArrayTrait::new()).unwrap();
    let dispatcher = IDAOracleDispatcher { contract_address };
    assert_eq!(1, 1);
}
