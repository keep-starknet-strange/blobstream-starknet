use blobstream_sn::tree::binary::merkle_proof::BinaryMerkleProof;
use starknet::secp256_trait::Signature;
use starknet::{EthAddress, ContractAddress, ClassHash};

#[derive(Drop, Serde)]
struct Validator {
    addr: EthAddress,
    power: u256,
}

/// Each data root is associated with a Celestia block height. `availableDataRoot` in
/// https://github.com/celestiaorg/celestia-specs/blob/master/src/specs/data_structures.md#header
#[derive(Drop, Serde)]
struct DataRoot {
    height: felt252,
    data_root: u256,
}

mod TendermintXErrors {
    const TrustedHeaderNotFound: felt252 = 'Trusted header not found';
    const TargetBlockNotInRange: felt252 = 'Target block not in range';
    const LatestHeaderNotFound: felt252 = 'Latest header not found';
}

#[starknet::interface]
trait ITendermintX<TContractState> {
    // Get the header hash for a block height.
    fn get_header_hash(self: @TContractState, _height: u64) -> u256;
    // Get latest block number updated by the light client.
    fn get_latest_block(self: @TContractState) -> u64;
}

/// Data Availability Oracle interface.
#[starknet::interface]
trait IDAOracle<TContractState> {
    /// Verify a Data Availability attestation.
    /// * `proof_nonce` - Nonce of the tuple root to prove against.
    /// * `root` -  Data root tuple to prove inclusion of.
    /// * `proof` - Binary Merkle tree proof that `tuple` is in the root at `_tupleRootNonce`.
    fn verify_attestation(
        self: @TContractState, proof_nonce: u64, root: DataRoot, proof: BinaryMerkleProof
    ) -> bool;
}

#[starknet::interface]
trait IBlobstreamX<TContractState> {
    /// Max num of blocks that can be skipped in a single request
    /// ref: https://github.com/celestiaorg/celestia-core/blob/main/pkg/consts/consts.go#L43-L44
    fn data_commitment_max(self: @TContractState) -> u64;
    // Address of the gateway contract.
    fn set_gateway(ref self: TContractState, new_gateway: ContractAddress);
    fn get_gateway(self: @TContractState) -> ContractAddress;
    // Nonce for proof events. Must be incremented sequentially
    fn get_state_proof_nonce(self: @TContractState) -> u64;
    // Header range function id.
    fn get_header_range_id(self: @TContractState) -> u256;
    fn set_header_range_id(ref self: TContractState, _function_id: u256);
    // Next header function id.
    fn get_next_header_id(self: @TContractState) -> u256;
    fn set_next_header_id(ref self: TContractState, _function_id: u256);
    // Contract freezing state.
    fn get_frozen(self: @TContractState) -> bool;
    fn set_frozen(ref self: TContractState, _frozen: bool);
    // Prove the validity of the header at the target block and a data commitment for the block range [latestBlock, _targetBlock).
    fn request_header_range(ref self: TContractState, _target_block: u64);
    // Commits the new header at targetBlock and the data commitment for the block range [trustedBlock, targetBlock).
    fn commit_header_range(ref self: TContractState, _target_block: u64);
    // Prove the validity of the next header and a data commitment for the block range [latestBlock, latestBlock + 1).
    fn request_next_header(ref self: TContractState);
    // Stores the new header for _trustedBlock + 1 and the data commitment for the block range [_trustedBlock, _trustedBlock + 1).
    fn commit_next_header(ref self: TContractState, _trusted_block: u64);
}
