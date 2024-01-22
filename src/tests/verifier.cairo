use blobstream::DataRoot;
use blobstream::verifier::AttestationProof;
use blobstream::tree::binary::binary_merkle_proof::BinaryMerkleProof;

#[test]
fn attestation_proof_test() {
    let checkpoint = AttestationProof {
        tuple_root_nonce: 1,
        data_root_tuple: DataRoot {
            height: 2,
            data_root: 3
        },
        proof: BinaryMerkleProof {
            side_nodes: Default::default(),
            key: 4,
            num_leaves: 5
        },
    };
    assert!(checkpoint.tuple_root_nonce == 1, "stub for verifier test");
}
