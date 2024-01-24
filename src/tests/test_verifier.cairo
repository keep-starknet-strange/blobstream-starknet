use blobstream_sn::DataRoot;
use blobstream_sn::tree::binary::merkle_proof::BinaryMerkleProof;
use blobstream_sn::verifier::AttestationProof;

#[test]
fn attestation_proof_test() {
    let checkpoint = AttestationProof {
        tuple_root_nonce: 1,
        data_root_tuple: DataRoot { height: 2, data_root: 3 },
        proof: BinaryMerkleProof { side_nodes: array![1], key: 4, num_leaves: 5 },
    };
    assert!(checkpoint.tuple_root_nonce == 1, "stub for verifier test");
}
