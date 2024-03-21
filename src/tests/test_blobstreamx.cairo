use alexandria_bytes::{Bytes, BytesTrait};
use alexandria_encoding::sol_abi::{SolBytesTrait, SolAbiEncodeTrait};
use blobstream_sn::blobstreamx::blobstreamx;
use blobstream_sn::interfaces::{
    IBlobstreamXDispatcher, IBlobstreamXDispatcherTrait, Validator, ITendermintXDispatcher,
    ITendermintXDispatcherTrait, DataRoot, IDAOracleDispatcher, IDAOracleDispatcherTrait
};
use blobstream_sn::tests::common::{
    setup_base, setup_spied, setup_succinct_gateway, TEST_START_BLOCK, TEST_END_BLOCK, TEST_HEADER,
    OWNER
};
use blobstream_sn::tree::binary::merkle_proof::BinaryMerkleProof;
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
fn test_verify_attestation() {
    let bsx_address = setup_base();
    let bsx = IDAOracleDispatcher { contract_address: bsx_address };

    // Test data: https://github.com/celestiaorg/blobstream-contracts/blob/3a552d8f7bfbed1f3175933260e6e440915d2da4/src/lib/verifier/test/DAVerifier.t.sol#L295

    // Store the commitment we verify against.
    let proof_nonce: u64 = 2;
    let data_commitment: u256 = 0xf89859a09c0f2b1bbb039618d0fe60432b8c247f7ccde97814655f2acffb3434;
    snf::store(
        bsx_address,
        snf::map_entry_address(
            selector!("state_data_commitments"), array![proof_nonce.into()].span()
        ),
        array![data_commitment.low.into(), data_commitment.high.into()].span(),
    );
    snf::store(bsx_address, selector!("state_proof_nonce"), array![3].span(),);

    // Construct a valid proof.
    let data = DataRoot {
        height: 3, data_root: 0x55cfc29fc0cd263906122d5cb859091224495b141fc0c51529612d7ab8962950,
    };
    let side_nodes: Array<u256> = array![
        0xb5d4d27ec6b206a205bf09dde3371ffba62e5b53d27bbec4255b7f4f27ef5d90,
        0x406e22ba94989ca721453057a1391fc531edb342c86a0ab4cc722276b54036ec,
    ];
    let key: u256 = 2;
    let num_leaves: u256 = 4;
    let proof = BinaryMerkleProof { side_nodes, key, num_leaves, };

    let is_proof_valid: bool = bsx.verify_attestation(proof_nonce, data, proof);
    assert!(is_proof_valid, "valid proof should be accepted");
}


#[test]
fn blobstreamx_fulfill_commit_header_range() {
    let bsx = setup_blobstreamx();
    let gateway = get_gateway_contract(bsx.contract_address);

    // test data: https://sepolia.etherscan.io/tx/0x38ff4174e1e2c56d26f1f54e564fe282a662cff8335b3cd368e9a29004cee04d#eventlog
    let mut input = BytesTrait::new_empty()
        .encode_packed(TEST_START_BLOCK)
        .encode_packed(TEST_HEADER)
        .encode_packed(TEST_END_BLOCK);

    let mut output = BytesTrait::new_empty()
        .encode_packed(0x94a3afe8ce56375bedcb401c07a38a93a6b9d47461a01b6a410d5a958ca9bc7a_u256)
        .encode_packed(0xAAA0E18EB3689B8D88BE03EA19589E3565DB343F6509C8601DB6AFA01255A488_u256);

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
