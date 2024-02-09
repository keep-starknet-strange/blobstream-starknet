use blobstream_sn::blobstreamx::BlobstreamX;
use blobstream_sn::interfaces::{
    IBlobstreamXDispatcher, IBlobstreamXDispatcherTrait, Validator, ITendermintXDispatcher,
    ITendermintXDispatcherTrait
};
use blobstream_sn::tests::common::{setup_base, setup_spied, TEST_GATEWAY};
use snforge_std::{EventSpy, EventAssertions, store, map_entry_address};
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
    let block_number = get_block_number();
    blobstreamx.commit_header_range(block_number, block_number + 1);

    let latest_block = ITendermintXDispatcher { contract_address: blobstreamx.contract_address }
        .get_latest_block();
    assert!(latest_block == block_number + 1, "latest block does not match");
    assert!(
        blobstreamx.get_state_proof_nonce() == state_proof_nonce + 1, "state proof nonce invalid"
    );
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
    let block_number = get_block_number();
    blobstreamx.commit_next_header(block_number);

    let latest_block = ITendermintXDispatcher { contract_address: blobstreamx.contract_address }
        .get_latest_block();
    assert!(latest_block == block_number + 1, "latest block does not match");
    assert!(
        blobstreamx.get_state_proof_nonce() == state_proof_nonce + 1, "state proof nonce invalid"
    );
}


#[test]
#[should_panic(expected: ('Trusted header not found',))]
fn blobstreamx_commit_next_header_trusted_header_null() {
    let blobstreamx = setup_blobstreamx();
    blobstreamx.commit_next_header(0);
}

#[test]
fn blobstreamx_request_header_range() {
    let (blobstreamx, mut spy) = setup_blobstreamx_spied();
    let block_number = get_block_number();
    let latest_header = blobstreamx.get_header_hash(block_number);
    blobstreamx.request_header_range(block_number + 1);
    spy
        .assert_emitted(
            @array![
                (
                    blobstreamx.contract_address,
                    BlobstreamX::Event::HeaderRangeRequested(
                        BlobstreamX::HeaderRangeRequested {
                            trusted_block: block_number,
                            trusted_header: latest_header,
                            target_block: block_number + 1
                        }
                    )
                )
            ]
        );
}

#[test]
#[should_panic(expected: ('Latest header not found',))]
fn blobstreamx_request_header_range_latest_header_null() {
    let blobstreamx = setup_blobstreamx();
    store(
        blobstreamx.contract_address,
        map_entry_address(
            selector!("block_height_to_header_hash"), array![get_block_number().into()].span(),
        ),
        array![0].span()
    );
    blobstreamx.request_header_range(get_block_number() + 1);
}


#[test]
#[should_panic(expected: ('Target block not in range',))]
fn blobstreamx_request_header_range_target_block_not_in_range() {
    let blobstreamx = setup_blobstreamx();
    let block_number = get_block_number();
    blobstreamx.request_header_range(1);
}

#[test]
#[should_panic(expected: ('Target block not in range',))]
fn blobstreamx_request_header_range_target_block_not_in_range_2() {
    let blobstreamx = setup_blobstreamx();
    let block_number = get_block_number();
    blobstreamx.request_header_range(block_number + 1001);
}
