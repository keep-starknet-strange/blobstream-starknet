use blobstream_sn::blobstreamx::blobstreamx;
use blobstream_sn::interfaces::{
    IBlobstreamXDispatcher, IBlobstreamXDispatcherTrait, Validator, ITendermintXDispatcher,
    ITendermintXDispatcherTrait
};
use blobstream_sn::succinctx::interfaces::{
    ISuccinctGatewayDispatcher, ISuccinctGatewayDispatcherTrait
};
use blobstream_sn::tests::common::{
    setup_base, setup_spied, setup_succinct_gateway, TEST_BLOCK_HEIGHT
};
use snforge_std::{EventSpy, EventAssertions, store, map_entry_address};
use starknet::secp256_trait::Signature;
use starknet::{ContractAddress, EthAddress, info::get_block_number};

fn setup_blobstreamx() -> IBlobstreamXDispatcher {
    IBlobstreamXDispatcher { contract_address: setup_base() }
}

fn setup_blobstreamx_spied() -> (IBlobstreamXDispatcher, EventSpy) {
    let (contract_address, spy) = setup_spied();
    (IBlobstreamXDispatcher { contract_address }, spy)
}

fn get_gateway_contract(contract_address: ContractAddress) -> ISuccinctGatewayDispatcher {
    let gateway_addr = IBlobstreamXDispatcher { contract_address }.get_gateway();
    ISuccinctGatewayDispatcher { contract_address: gateway_addr }
}

fn get_bsx_latest_block(contract_address: ContractAddress) -> u64 {
    ITendermintXDispatcher { contract_address }.get_latest_block()
}

fn get_bsx_header_hash(contract_address: ContractAddress, latest_block: u64) -> u256 {
    ITendermintXDispatcher { contract_address }.get_header_hash(latest_block)
}

#[test]
fn blobstreamx_constructor_vals() {
    let bsx = setup_blobstreamx();

    assert!(bsx.data_commitment_max() == 1000, "max skip constant invalid");
    assert!(bsx.get_state_proof_nonce() == 1, "state proof nonce invalid");
}

#[test]
#[ignore]
fn blobstreamx_fullfil_commit_header_range() {
    let bsx = setup_blobstreamx();
    let state_proof_nonce = bsx.get_state_proof_nonce();
    let next_block = get_bsx_latest_block(bsx.contract_address) + 1;

    let gateway = get_gateway_contract(bsx.contract_address);
    // gateway.fulfill_call();
    bsx.commit_header_range(next_block);

    assert!(
        get_bsx_latest_block(bsx.contract_address) == next_block, "latest block does not match"
    );
    assert!(bsx.get_state_proof_nonce() == state_proof_nonce + 1, "state proof nonce invalid");
}

#[test]
#[should_panic(expected: ('Target block not in range',))]
fn blobstreamx_commit_header_range_trusted_header_null() {
    let bsx = setup_blobstreamx();
    bsx.commit_header_range(0);
}

#[test]
#[should_panic(expected: ('Target block not in range',))]
fn blobstreamx_commit_header_range_target_block_not_in_range() {
    let bsx = setup_blobstreamx();
    bsx.commit_header_range(1);
}

#[test]
#[should_panic(expected: ('Target block not in range',))]
fn blobstreamx_commit_header_range_target_block_not_in_range_2() {
    let bsx = setup_blobstreamx();
    bsx.commit_header_range(get_block_number() + 1001);
}


#[test]
#[ignore]
fn blobstreamx_commit_next_header() {
    let bsx = setup_blobstreamx();
    let state_proof_nonce = bsx.get_state_proof_nonce();
    let latest_block = get_bsx_latest_block(bsx.contract_address);

    bsx.commit_next_header(latest_block);

    assert!(
        get_bsx_latest_block(bsx.contract_address) == latest_block + 1,
        "latest block does not match"
    );
    assert!(bsx.get_state_proof_nonce() == state_proof_nonce + 1, "state proof nonce invalid");
}


#[test]
#[should_panic(expected: ('Trusted header not found',))]
fn blobstreamx_commit_next_header_trusted_header_null() {
    let bsx = setup_blobstreamx();
    bsx.commit_next_header(0);
}

#[test]
fn blobstreamx_request_header_range() {
    let (bsx, mut spy) = setup_blobstreamx_spied();
    let latest_block = get_bsx_latest_block(bsx.contract_address);

    bsx.request_header_range(latest_block + 1);
    spy
        .assert_emitted(
            @array![
                (
                    bsx.contract_address,
                    blobstreamx::Event::HeaderRangeRequested(
                        blobstreamx::HeaderRangeRequested {
                            trusted_block: latest_block,
                            trusted_header: get_bsx_header_hash(bsx.contract_address, latest_block),
                            target_block: latest_block + 1
                        }
                    )
                )
            ]
        );
}

#[test]
#[should_panic(expected: ('Latest header not found',))]
fn blobstreamx_request_header_range_latest_header_null() {
    let bsx = setup_blobstreamx();
    let latest_block = get_bsx_latest_block(bsx.contract_address);

    store(
        bsx.contract_address,
        map_entry_address(
            selector!("block_height_to_header_hash"), array![latest_block.into()].span(),
        ),
        array![0, 0].span()
    );
    bsx.request_header_range(latest_block + 1);
}

#[test]
#[should_panic(expected: ('Target block not in range',))]
fn blobstreamx_request_header_range_target_block_not_in_range() {
    let bsx = setup_blobstreamx();
    bsx.request_header_range(1);
}

#[test]
#[should_panic(expected: ('Target block not in range',))]
fn blobstreamx_request_header_range_target_block_not_in_range_2() {
    let bsx = setup_blobstreamx();
    let latest_block = get_bsx_latest_block(bsx.contract_address);
    bsx.request_header_range(latest_block + 1001);
}
