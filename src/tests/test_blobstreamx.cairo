use blobstream_sn::BlobstreamX;
use blobstream_sn::interfaces::{IBlobstreamXDispatcher, IBlobstreamXDispatcherTrait, Validator};
use blobstream_sn::tests::common::{setup_base, setup_spied, TEST_GATEWAY};
use snforge_std::EventSpy;
use starknet::EthAddress;
use starknet::secp256_trait::Signature;

fn setup_blobstreamx() -> IBlobstreamXDispatcher {
    IBlobstreamXDispatcher { contract_address: setup_base() }
}

fn setup_blobstreamx_spied() -> (IBlobstreamXDispatcher, EventSpy) {
    let (contract_address, spy) = setup_spied();
    (IBlobstreamXDispatcher { contract_address }, spy)
}

#[test]
fn blobstreamx_constructor_vals() {
    let blobstreamx = setup_blobstreamx();

    assert!(blobstreamx.DATA_COMMITMENT_MAX() == 1000, "max skip constnat invalid");
    assert!(blobstreamx.get_gateway().into() == TEST_GATEWAY, "gateway addr invalid");
    assert!(blobstreamx.get_state_proof_nonce() == 1, "state proof nonce invalid");
}
