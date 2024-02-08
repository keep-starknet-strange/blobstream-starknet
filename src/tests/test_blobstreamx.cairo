use blobstream_sn::BlobstreamX;
use blobstream_sn::interfaces::{IBlobstreamXDispatcher, IBlobstreamXDispatcherTrait, Validator};
use blobstream_sn::tests::common::{setup_base, setup_spied, TEST_GATEWAY};
use snforge_std::EventSpy;
use starknet::secp256_trait::Signature;
use starknet::{EthAddress, info::get_block_number};

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


#[test]
fn blobstreamx_commit_header_range() {
    let blobstreamx = setup_blobstreamx();
    let state_proof_nonce = blobstreamx.get_state_proof_nonce();
    let _ = blobstreamx.get_latest_block();
    let block_number = get_block_number();
    blobstreamx.commit_header_range(block_number, block_number + 1);
    let _ = blobstreamx.get_state_proof_nonce();
    assert!(
        blobstreamx.get_state_proof_nonce() == state_proof_nonce + 1, "state proof nonce invalid"
    );
    assert!(blobstreamx.get_latest_block() == block_number + 1, "latest block does not match");
}


#[test]
#[should_panic(expected: ('Trusted header not found',))]
fn blobstreamx_commit_header_range_trusted_header_null() {
    let blobstreamx = setup_blobstreamx();
    blobstreamx.commit_header_range(0, 1);
}

#[test]
#[should_panic(expected: ('Target block not in range',))]
fn blobstreamx_commit_header_range_target_block_not_in_range() {
    let blobstreamx = setup_blobstreamx();
    let block_number = get_block_number();
    blobstreamx.commit_header_range(block_number, 1);
}

#[test]
#[should_panic(expected: ('Target block not in range',))]
fn blobstreamx_commit_header_range_target_block_not_in_range_2() {
    let blobstreamx = setup_blobstreamx();
    let block_number = get_block_number();
    blobstreamx.commit_header_range(block_number, block_number + 1001);
}


#[test]
fn blobstreamx_commit_next_header() {
    let blobstreamx = setup_blobstreamx();
    let state_proof_nonce = blobstreamx.get_state_proof_nonce();
    let _ = blobstreamx.get_latest_block();
    let block_number = get_block_number();
    blobstreamx.commit_next_header(block_number);
    let _ = blobstreamx.get_state_proof_nonce();
    assert!(
        blobstreamx.get_state_proof_nonce() == state_proof_nonce + 1, "state proof nonce invalid"
    );
    assert!(blobstreamx.get_latest_block() == block_number + 1, "latest block does not match");
}


#[test]
#[should_panic(expected: ('Trusted header not found',))]
fn blobstreamx_commit_next_header_trusted_header_null() {
    let blobstreamx = setup_blobstreamx();
    blobstreamx.commit_next_header(0);
}
