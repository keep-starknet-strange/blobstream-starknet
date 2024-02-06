use blobstream_sn::BlobstreamX;
use blobstream_sn::interfaces::{IDAOracleDispatcher, IDAOracleDispatcherTrait, Validator};
use blobstream_sn::tests::common::setup_base;
use starknet::EthAddress;
use starknet::secp256_trait::Signature;


fn setup_blobstreamx() -> IDAOracleDispatcher {
    IDAOracleDispatcher { contract_address: setup_base() }
}

#[test]
#[ignore]
#[should_panic(expected: ('Malformed current validator set',))]
fn blobstreamx_error_malformed_current_validator_set() {
    let dispatcher = setup_blobstreamx();

    // Testing Error::MALFORMED_CURRENT_VALIDATOR_SET
    let _current_validator_set = array![
        Validator { addr: EthAddress { address: 0x123123123 }, power: '3123' }
    ];
    let _sigs: Array<Signature> = array![];
    dispatcher
        .update_validator_set(
            '2', '1', '34123413', 21323123, _current_validator_set.span(), _sigs.span()
        );
}

#[test]
#[ignore]
#[should_panic(expected: ('New set nonce > current nonce',))]
fn blobstreamx_error_invalid_validator_set_nonce_1() {
    let dispatcher = setup_blobstreamx();

    // Testing Error::INVALID_VALIDATOR_SET_NONCE
    let _current_validator_set = array![
        Validator { addr: EthAddress { address: 0x123123123 }, power: '3123' }
    ];
    let _sigs: Array<Signature> = array![];
    dispatcher
        .update_validator_set(
            '1', '1', '34123413', 21323123, _current_validator_set.span(), _sigs.span()
        );
}


#[test]
#[ignore]
#[should_panic(expected: ('Validator&power not matching cp',))]
fn blobstreamx_error_supplied_validator_set_invalid() {
    let dispatcher = setup_blobstreamx();

    // Testing Error::INVALID_VALIDATOR_SET_NONCE
    let _current_validator_set = array![
        Validator { addr: EthAddress { address: 0x123123123 }, power: '3123' }
    ];
    let _sigs: Array<Signature> = array![Signature { r: 1231231, s: 132132, y_parity: true }];
    dispatcher
        .update_validator_set(
            '2', '1', '34123413', 21323123, _current_validator_set.span(), _sigs.span()
        );
}


#[test]
#[ignore]
#[should_panic(expected: ('Data RTR nonce > current nonce',))]
fn blobstreamx_error_data_rtr_nonce() {
    let dispatcher = setup_blobstreamx();

    // Testing Error::SUPPLIED_VALIDATOR_SET_INVALID
    let _current_validator_set = array![
        Validator { addr: EthAddress { address: 0x123123123 }, power: '3123' }
    ];
    let _sigs: Array<Signature> = array![Signature { r: 1231231, s: 132132, y_parity: true }];
    dispatcher
        .submit_data_root_tuple_root(
            '1', '34123413', 21323123, _current_validator_set.span(), _sigs.span()
        );
}
