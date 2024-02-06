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
    fn DATA_COMMITMENT_MAX(self: @TContractState) -> u64;
    // Address of the gateway contract
    fn set_gateway(ref self: TContractState, new_gateway: ContractAddress);
    fn get_gateway(self: @TContractState) -> ContractAddress;
    // Block is the first one in the next data commitment
    fn get_latest_block(self: @TContractState) -> u64;
    // Nonce for proof events. Must be incremented sequentially
    fn get_state_proof_nonce(self: @TContractState) -> u64;
}
