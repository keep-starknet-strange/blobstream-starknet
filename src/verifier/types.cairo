use blobstream_sn::interfaces::DataRoot;
use blobstream_sn::tree::binary::merkle_proof::BinaryMerkleProof;

// Data needed to verify that a data root tuple was committed to
// by the Blobstream smart contract, at some specific nonce
#[derive(Drop)]
struct AttestationProof {
    // attestation nonce that commits to the data root tuple
    commit_nonce: u256,
    //data root tuple that was committed to
    data_root: DataRoot,
    // binary merkle proof of the tuple to the commitment
    proof: BinaryMerkleProof,
}
