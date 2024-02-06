use blobstream_sn::tree::binary::merkle_proof::BinaryMerkleProof;
use blobstream_sn::verifier::types::AttestationProof;
use blobstream_sn::verifier::types::DataRoot;

#[test]
fn attestation_proof_test() {
    let checkpoint = AttestationProof {
        commit_nonce: 1,
        data_root: DataRoot { height: 2, data_root: 3 },
        proof: BinaryMerkleProof { side_nodes: array![1], key: 4, num_leaves: 5 },
    };
    assert!(checkpoint.commit_nonce == 1, "stub for verifier test");
}
