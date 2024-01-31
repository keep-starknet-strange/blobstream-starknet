use blobstream_sn::interfaces::{
    IUpgradeableDispatcher, IUpgradeableDispatcherTrait, IDAOracleDispatcher,
    IDAOracleDispatcherTrait
};
use blobstream_sn::mocks::upgraded::{IMockUpgradedDispatcher, IMockUpgradedDispatcherTrait};
use blobstream_sn::{
    VALIDATOR_SET_HASH_DOMAIN_SEPARATOR, DATA_ROOT_TUPLE_ROOT_DOMAIN_SEPARATOR, Validator,
    Blobstream,
};
use core::bytes_31::one_shift_left_bytes_u128;
use openzeppelin::access::ownable::interface::{IOwnableDispatcher, IOwnableDispatcherTrait};
use openzeppelin::tests::utils::constants::{OWNER};
use snforge_std::{declare, ContractClassTrait, start_prank, stop_prank, CheatTarget};
use starknet::secp256_trait::Signature;
use starknet::{EthAddress, ContractAddress, ClassHash, contract_address_const};

#[test]
fn constants_test() {
    let checkpoint = 'checkpoint' * one_shift_left_bytes_u128(6);
    assert!(VALIDATOR_SET_HASH_DOMAIN_SEPARATOR.high == checkpoint, "checkpoint const");
    assert!(
        DATA_ROOT_TUPLE_ROOT_DOMAIN_SEPARATOR.high == 'transactionBatch', "transactinBatch const"
    );
}


// #[test]
// fn setup_test() {
//     let contract = declare('Blobstream');
//     let contract_address = contract.deploy(@ArrayTrait::new()).unwrap();
//     let dispatcher = IDAOracleDispatcher { contract_address };
//     assert_eq!(1, 1);
// }

fn setup_test() -> IDAOracleDispatcher {
    let owner: felt252 = OWNER().into();
    let contract = declare('Blobstream');
    let calldata = array!['1', '1231132', 12301230123, 413431231, owner];
    let contract_address = contract.deploy(@calldata).unwrap();
    let dispatcher = IDAOracleDispatcher { contract_address };
    dispatcher
}

#[test]
#[should_panic(expected: ('Malformed current validator set',))]
fn blobstream_error_malformed_current_validator_set() {
    let dispatcher = setup_test();

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
#[should_panic(expected: ('Invalid signature',))]
fn blobstream_error_invalid_signature() {
    let state = Blobstream::contract_state_for_testing();

    // Testing Error::INVALID_SIGNATURE
    let _current_validators = array![
        Validator { addr: EthAddress { address: 0x123123123 }, power: '3123' }
    ];
    let _sigs: Array<Signature> = array![Signature { r: 1231231, s: 132132, y_parity: true }];
    Blobstream::check_validator_signatures(
        @state, _current_validators.span(), _sigs.span(), 13123123, '123213'
    );
}


#[test]
#[should_panic(expected: ('New set nonce > current nonce',))]
fn blobstream_error_invalid_validator_set_nonce_1() {
    let dispatcher = setup_test();

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
#[should_panic(expected: ('Validator&power not matching cp',))]
fn blobstream_error_supplied_validator_set_invalid() {
    let dispatcher = setup_test();

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
#[should_panic(expected: ('Data RTR nonce > current nonce',))]
fn blobstream_error_data_rtr_nonce() {
    let dispatcher = setup_test();

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

#[test]
fn blobstream_upgrade() {
    let dispatcher = setup_test();

    let new_class: ClassHash = declare('MockUpgraded').class_hash;
    start_prank(CheatTarget::One(dispatcher.contract_address), OWNER());
    IUpgradeableDispatcher { contract_address: dispatcher.contract_address }.upgrade(new_class);
    stop_prank(CheatTarget::One(dispatcher.contract_address));

    assert(
        IMockUpgradedDispatcher { contract_address: dispatcher.contract_address }.get_version(),
        'Upgrade failed'
    );
}

#[test]
#[should_panic(expected: ('Caller is not the owner',))]
fn blobstream_upgrade_not_owner() {
    let dispatcher = setup_test();

    let new_class: ClassHash = declare('MockUpgraded').class_hash;
    IUpgradeableDispatcher { contract_address: dispatcher.contract_address }.upgrade(new_class);

    assert(
        IMockUpgradedDispatcher { contract_address: dispatcher.contract_address }.get_version(),
        'Upgrade failed'
    );
}

#[test]
fn blobstream_transfer_ownership() {
    let dispatcher = setup_test();

    let current_owner = IOwnableDispatcher { contract_address: dispatcher.contract_address }
        .owner();
    assert(current_owner == OWNER().into(), 'initial owner wrong');

    let new_owner = contract_address_const::<'new_owner'>();
    start_prank(CheatTarget::One(dispatcher.contract_address), OWNER());
    IOwnableDispatcher { contract_address: dispatcher.contract_address }
        .transfer_ownership(new_owner);
    stop_prank(CheatTarget::One(dispatcher.contract_address));

    assert(
        IOwnableDispatcher { contract_address: dispatcher.contract_address }
            .owner() == new_owner
            .into(),
        'transfer owner failed'
    );
}

#[test]
#[should_panic(expected: ('Caller is not the owner',))]
fn blobstream_transfer_ownership_no_owner() {
    let dispatcher = setup_test();

    let new_owner = contract_address_const::<'new_owner'>();
    IOwnableDispatcher { contract_address: dispatcher.contract_address }
        .transfer_ownership(new_owner);

    assert(
        IOwnableDispatcher { contract_address: dispatcher.contract_address }
            .owner() == new_owner
            .into(),
        'transfer owner failed'
    );
}
