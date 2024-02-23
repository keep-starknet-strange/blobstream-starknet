use blobstream_sn::succinctx::function_registry::interfaces::{
    IFunctionRegistryDispatcher, IFunctionRegistryDispatcherTrait
};
use openzeppelin::tests::utils::constants::OWNER;
use snforge_std::{
    declare, ContractClassTrait, start_prank, stop_prank, CheatTarget, spy_events, SpyOn, EventSpy
};
use starknet::ContractAddress;

// https://sepolia.etherscan.io/tx/0xadced8dc7f4bb01d730ed78daecbf9640417c5bd60b0ada23c9045cc953481a5#eventlog
const TEST_START_BLOCK: u64 = 846054;
const TEST_END_BLOCK: u64 = 846360;
const TEST_HEADER: u256 = 0x47D040565942B111F7CD569BE78CE310644596F3929DF25584F3E5ADFD9F5001;
const HEADER_RANGE_DIGEST: u256 = 0xb646edd6dbb2e5482b2449404cf1888b8f4cd6958c790aa075e99226c2c1d62;
const NEXT_HEADER_DIGEST: u256 = 0xfd6c88812a160ff288fe557111815b3433c539c77a3561086cfcdd9482bceb8;

fn setup_base() -> ContractAddress {
    // deploy the succinct gateway
    let succinct_gateway_class = declare('succinct_gateway');
    let gateway_addr = succinct_gateway_class.deploy(@array![OWNER().into()]).unwrap();
    let gateway = IFunctionRegistryDispatcher { contract_address: gateway_addr };

    // deploy the mock function verifier
    let func_verifier_class = declare('function_verifier_mock');
    let header_range_verifier = func_verifier_class
        .deploy(@array![HEADER_RANGE_DIGEST.low.into(), HEADER_RANGE_DIGEST.high.into()])
        .unwrap();
    let next_header_verifier = func_verifier_class
        .deploy(@array![NEXT_HEADER_DIGEST.low.into(), NEXT_HEADER_DIGEST.high.into()])
        .unwrap();

    // register verifier functions w/ gateway
    let header_range_func_id = gateway
        .register_function(OWNER(), header_range_verifier, 'HEADER_RANGE');
    let next_header_func_id = gateway
        .register_function(OWNER(), next_header_verifier, 'NEXT_HEADER');

    // deploy blobstreamx
    let blobstreamx_class = declare('blobstreamx');
    let calldata = array![
        gateway_addr.into(),
        OWNER().into(),
        TEST_START_BLOCK.into(),
        TEST_HEADER.low.into(),
        TEST_HEADER.high.into(),
        header_range_func_id.low.into(),
        header_range_func_id.high.into(),
        next_header_func_id.low.into(),
        next_header_func_id.high.into(),
    ];
    blobstreamx_class.deploy(@calldata).unwrap()
}

fn setup_spied() -> (ContractAddress, EventSpy) {
    let blobstreamx = setup_base();
    let mut spy = spy_events(SpyOn::One(blobstreamx));
    (blobstreamx, spy)
}


fn setup_succinct_gateway() -> ContractAddress {
    let succinct_gateway_class = declare('succinct_gateway');
    let calldata = array![OWNER().into()];
    succinct_gateway_class.deploy(@calldata).unwrap()
}
