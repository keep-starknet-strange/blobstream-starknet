use alexandria_bytes::{Bytes, BytesTrait};
use blobstream_sn::blobstreamx::blobstreamx;
use blobstream_sn::interfaces::{
    IBlobstreamXDispatcher, IBlobstreamXDispatcherTrait, Validator, ITendermintXDispatcher,
    ITendermintXDispatcherTrait
};
use blobstream_sn::mocks::evm_facts_registry::{IEVMFactsRegistryMockDispatcher, IEVMFactsRegistryMockDispatcherImpl};
use blobstream_sn::tests::common::{
    setup_base, setup_spied, setup_succinct_gateway, TEST_START_BLOCK, TEST_END_BLOCK, TEST_HEADER,
};
use openzeppelin::tests::utils::constants::OWNER;
use snforge_std as snf;
use snforge_std::{CheatTarget, EventSpy, EventAssertions};
use starknet::secp256_trait::Signature;
use starknet::{ContractAddress, EthAddress, info::get_block_number};
use succinct_sn::interfaces::{ISuccinctGatewayDispatcher, ISuccinctGatewayDispatcherTrait};

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
fn blobstreamx_fulfill_commit_header_range() {
    let bsx = setup_blobstreamx();
    let gateway = get_gateway_contract(bsx.contract_address);

    // test data: https://sepolia.etherscan.io/tx/0x38ff4174e1e2c56d26f1f54e564fe282a662cff8335b3cd368e9a29004cee04d#eventlog
    let mut input = BytesTrait::new_empty();
    input.append_u64(TEST_START_BLOCK);
    input.append_u256(TEST_HEADER);
    input.append_u64(TEST_END_BLOCK);

    let mut output = BytesTrait::new_empty();
    output.append_u256(0x94a3afe8ce56375bedcb401c07a38a93a6b9d47461a01b6a410d5a958ca9bc7a);
    output.append_u256(0xAAA0E18EB3689B8D88BE03EA19589E3565DB343F6509C8601DB6AFA01255A488);

    gateway
        .fulfill_call(
            bsx.get_header_range_id(),
            input,
            output,
            BytesTrait::new_empty(),
            bsx.contract_address,
            selector!("commit_header_range"),
            array![TEST_END_BLOCK.into()].span(),
        );

    assert!(
        get_bsx_latest_block(bsx.contract_address) == TEST_END_BLOCK, "latest block does not match"
    );
    assert!(bsx.get_state_proof_nonce() == 2, "state proof nonce invalid");
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

// TODO: fix with refactor
#[test]
#[ignore]
fn blobstreamx_commit_next_header() {
    let bsx = setup_blobstreamx();
    let gateway = get_gateway_contract(bsx.contract_address);
    let latest_block = get_bsx_latest_block(bsx.contract_address);

    // TODO: need test data for input, output, and proof as no txs on testnet
    gateway
        .fulfill_call(
            bsx.get_next_header_id(),
            BytesTrait::new_empty(),
            BytesTrait::new_empty(),
            BytesTrait::new_empty(),
            bsx.contract_address,
            selector!("commit_next_header"),
            array![latest_block.into()].span(),
        );

    assert!(
        get_bsx_latest_block(bsx.contract_address) == latest_block + 1,
        "latest block does not match"
    );
    assert!(bsx.get_state_proof_nonce() == 2, "state proof nonce invalid");
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

    snf::store(
        bsx.contract_address,
        snf::map_entry_address(
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

#[test]
#[should_panic(expected: ('Contract is frozen',))]
fn blobstreamx_frozen() {
    let bsx = setup_blobstreamx();
    snf::start_prank(CheatTarget::One(bsx.contract_address), OWNER());
    bsx.set_frozen(true);
    bsx.commit_header_range(0);
}

#[test]
fn blobstreamx_data_commitments_from_herodotus_facts() {
    let bsx = setup_blobstreamx();

    let hfr_addr = bsx.get_herodotus_facts_registry();
    let l1_addr: felt252 = 0x48B257EC1610d04191cC2c528d0c940AdbE1E439;
    let l1_block_num: u256 = 0x100;

    let hfr_dispatcher = IEVMFactsRegistryMockDispatcher { contract_address: hfr_addr };
    hfr_dispatcher.set_slot_value(l1_addr, l1_block_num, 0xfc, 3.into()); // state_proofNonce at slot 0xfc

    // Slot pos = keccak256(abi.encode(map_key, state_dataCommitment_slot)) ie keccak256(abi.encode(map_key, 0xfe))
    let data_commitment1_slot: u256 = 0x457c8a48b4735f56b938837eb0a8a5f9c55f23c1a85767ce3b65c3e59d3d32b7;
    let data_commitment1: u256 = 0xe1078369756a0b28e3b8cc1fa6e0133630ccdf9d2bd5bde1d40d197793c3c8b4;
    hfr_dispatcher.set_slot_value(l1_addr, l1_block_num, data_commitment1_slot, data_commitment1); // state_dataCommitment[1]

    let data_commitment2_slot: u256 = 0xeeac6037a1009734a3fd8a7d8347d53da92d0725658242afb43dd0d755dbe634;
    let data_commitment2: u256 = 0xc2b2d9e303ad14a5aeeda362d3d4177eedb43e1e0e4e6d42f6922f2ebfb23cc6;
    hfr_dispatcher.set_slot_value(l1_addr, l1_block_num, data_commitment2_slot, data_commitment2); // state_dataCommitment[2]

    bsx.update_data_commitments_from_facts(l1_block_num);
    assert!(bsx.get_state_proof_nonce() == 3, "state proof nonce invalid");
    assert!(bsx.get_state_data_commitment(0) == 0, "data commitment 0 invalid");
    assert!(bsx.get_state_data_commitment(1) == data_commitment1, "data commitment 1 invalid");
    assert!(bsx.get_state_data_commitment(2) == data_commitment2, "data commitment 2 invalid");
    assert!(bsx.get_state_data_commitment(3) == 0, "data commitment 3 invalid");
    // TODO: test invalid inputs and things
}
