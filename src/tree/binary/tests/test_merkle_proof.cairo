use alexandria_bytes::BytesTrait;
use blobstream_sn::tree::binary::merkle_proof::BinaryMerkleProof;
use blobstream_sn::tree::binary::merkle_tree;

#[test]
fn verify_none_test() {
    let root: u256 = BytesTrait::new_empty().sha256();
    let side_nodes: Array<u256> = array![];
    let key: u256 = 0;
    let num_leaves: u256 = 0;
    let proof: BinaryMerkleProof = BinaryMerkleProof{ side_nodes, key, num_leaves };
    let data = BytesTrait::new_empty();
    let (is_valid, error_code) = merkle_tree::verify(root, @proof, @data);
    assert_eq!(is_valid, false);
}

#[test]
#[ignore]
fn verify_one_leaf_empty_test() {
    assert_eq!(false, true);
}

#[test]
#[ignore]
fn verify_one_leaf_test() {
    assert_eq!(false, true);
}

#[test]
#[ignore]
fn verify_one_leaf_01_test() {
    assert_eq!(false, true);
}

#[test]
#[ignore]
fn verify_leaf_one_of_eight_test() {
    assert_eq!(false, true);
}

#[test]
#[ignore]
fn verify_leaf_two_of_eight_test() {
    assert_eq!(false, true);
}

#[test]
#[ignore]
fn verify_leaf_three_of_eight_test() {
    assert_eq!(false, true);
}

#[test]
#[ignore]
fn verify_leaf_seven_of_eight_test() {
    assert_eq!(false, true);
}

#[test]
#[ignore]
fn verify_leaf_eight_of_eight_test() {
    assert_eq!(false, true);
}

#[test]
#[ignore]
fn verify_proof_of_five_leaves_test() {
    assert_eq!(false, true);
}

#[test]
#[ignore]
fn verify_invalid_proof_root_test() {
    assert_eq!(false, true);
}

#[test]
#[ignore]
fn verify_invalid_proof_key_test() {
    assert_eq!(false, true);
}

#[test]
#[ignore]
fn verify_invalid_proof_number_of_leaves_test() {
    assert_eq!(false, true);
}

#[test]
#[ignore]
fn verify_invalid_proof_side_nodes_test() {
    assert_eq!(false, true);
}

#[test]
#[ignore]
fn verify_invalid_proof_data_test() {
    assert_eq!(false, true);
}

#[test]
#[ignore]
fn valid_slice_test() {
    assert_eq!(false, true);
}

#[test]
#[ignore]
fn same_key_and_leaves_number_test() {
    assert_eq!(false, true);
}

#[test]
#[ignore]
fn consecutive_key_and_number_of_leaves_test() {
    assert_eq!(false, true);
}

#[test]
#[ignore]
fn invalid_slice_begin_end_test() {
    assert_eq!(false, true);
}

#[test]
#[ignore]
fn out_of_bounds_slice_test() {
    assert_eq!(false, true);
}
