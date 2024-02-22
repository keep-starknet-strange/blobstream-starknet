use openzeppelin::tests::utils::constants::OWNER;
use snforge_std::{
    declare, ContractClassTrait, start_prank, stop_prank, CheatTarget, spy_events, SpyOn, EventSpy
};
use starknet::ContractAddress;

const TEST_HEADER: u256 = 132413413413241324134134134141;

fn setup_base() -> ContractAddress {
    let succinct_gateway_class = declare('SuccinctGateway');
    let calldata = array![OWNER().into()];
    let gateway = succinct_gateway_class.deploy(@calldata).unwrap();

    let blobstreamx_class = declare('BlobstreamX');
    let calldata = array![
        gateway.into(), OWNER().into(), TEST_HEADER.low.into(), TEST_HEADER.high.into()
    ];
    blobstreamx_class.deploy(@calldata).unwrap()
}

fn setup_spied() -> (ContractAddress, EventSpy) {
    let blobstreamx = setup_base();
    let mut spy = spy_events(SpyOn::One(blobstreamx));
    (blobstreamx, spy)
}


fn setup_succinct_gateway() -> ContractAddress {
    let succinct_gateway_class = declare('SuccinctGateway');
    let calldata = array![OWNER().into()];
    succinct_gateway_class.deploy(@calldata).unwrap()
}
