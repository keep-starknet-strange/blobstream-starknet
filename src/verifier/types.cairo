use blobstream_sn::tree::binary::merkle_proof::BinaryMerkleProof;

/// Each data root is associated with a Celestia block height. `availableDataRoot` in
/// https://github.com/celestiaorg/celestia-specs/blob/master/src/specs/data_structures.md#header
#[derive(Copy, Drop)]
struct DataRoot {
    // Celestia block height for data root(genesis height = 0)
    height: felt252,
    data_root: u256
}

// Data needed to verify that a data root tuple was committed to
// by the Blobstream smart contract, at some specific nonce
#[derive(Drop)]
struct AttestationProof {
    // attestation nonce that commits to the data root tuple
    tuple_root_nonce: u256,
    //data root tuple that was committed to
    data_root_tuple: DataRoot,
    // binary merkle proof of the tuple to the commitment
    proof: BinaryMerkleProof,
}
