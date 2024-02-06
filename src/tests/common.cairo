use openzeppelin::tests::utils::constants::OWNER;
use snforge_std::{
    declare, ContractClassTrait, start_prank, stop_prank, CheatTarget, spy_events, SpyOn, EventSpy
};
use starknet::ContractAddress;

fn setup_base() -> ContractAddress {
    let blobstreamx_class = declare('BlobstreamX');
    let calldata = array![OWNER().into()];
    blobstreamx_class.deploy(@calldata).unwrap()
}

fn setup_spied() -> (ContractAddress, EventSpy) {
    let blobstreamx = setup_base();
    let mut spy = spy_events(SpyOn::One(blobstreamx));
    (blobstreamx, spy)
}
