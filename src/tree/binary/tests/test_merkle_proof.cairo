use alexandria_bytes::BytesTrait;
use blobstream_sn::tree::binary::merkle_proof::BinaryMerkleProof;
use blobstream_sn::tree::binary::merkle_tree;

#[test]
fn verify_none_test() {
    let root: u256 = BytesTrait::new_empty().sha256();
    let side_nodes: Array<u256> = array![];
    let key: u256 = 0;
    let num_leaves: u256 = 0;
    let proof: BinaryMerkleProof = BinaryMerkleProof { side_nodes, key, num_leaves };
    let data = BytesTrait::new_empty();
    let (is_valid, error_code) = merkle_tree::verify(root, @proof, @data);
    assert_eq!(is_valid, false, "verify none test failed");
}

#[test]
fn verify_one_leaf_empty_test() {
    let root: u256 = 0x6e340b9cffb37a989ca544e6bb780a2c78901d3fb33738768511a30617afa01d;
    let side_nodes: Array<u256> = array![];
    let key: u256 = 0;
    let num_leaves: u256 = 1;
    let proof: BinaryMerkleProof = BinaryMerkleProof { side_nodes, key, num_leaves };
    let data = BytesTrait::new_empty();
    let (is_valid, error_code) = merkle_tree::verify(root, @proof, @data);
    assert!(merkle_tree::is_no_error(error_code), "verify one leaf empty test failed with error");
    assert!(is_valid, "verify one leaf empty test invalid");
}

#[test]
fn verify_one_leaf_test() {
    let root: u256 = 0x48c90c8ae24688d6bef5d48a30c2cc8b6754335a8db21793cc0a8e3bed321729;
    let side_nodes: Array<u256> = array![];
    let key: u256 = 0;
    let num_leaves: u256 = 1;
    let proof: BinaryMerkleProof = BinaryMerkleProof { side_nodes, key, num_leaves };
    let mut data = BytesTrait::new_empty();
    data.append_u32(0xdeadbeef);
    let (is_valid, error_code) = merkle_tree::verify(root, @proof, @data);
    assert!(merkle_tree::is_no_error(error_code), "verify one leaf test failed with error");
    assert!(is_valid, "verify one leaf test invalid");
}

#[test]
fn verify_one_leaf_01_test() {
    let root: u256 = 0xb413f47d13ee2fe6c845b2ee141af81de858df4ec549a58b7970bb96645bc8d2;
    let side_nodes: Array<u256> = array![];
    let key: u256 = 0;
    let num_leaves: u256 = 1;
    let proof: BinaryMerkleProof = BinaryMerkleProof { side_nodes, key, num_leaves };
    let mut data = BytesTrait::new_empty();
    data.append_u8(0x01);
    let (is_valid, error_code) = merkle_tree::verify(root, @proof, @data);
    assert!(merkle_tree::is_no_error(error_code), "verify one leaf 01 test failed with error");
    assert!(is_valid, "verify one leaf 01 test invalid");
}

#[test]
fn verify_leaf_one_of_eight_test() {
    let root: u256 = 0xc1ad6548cb4c7663110df219ec8b36ca63b01158956f4be31a38a88d0c7f7071;
    let side_nodes: Array<u256> = array![
        0xfcf0a6c700dd13e274b6fba8deea8dd9b26e4eedde3495717cac8408c9c5177f,
        0x78850a5ab36238b076dd99fd258c70d523168704247988a94caa8c9ccd056b8d,
        0x4301a067262bbb18b4919742326f6f6d706099f9c0e8b0f2db7b88f204b2cf09
    ];
    let key: u256 = 0;
    let num_leaves: u256 = 8;
    let proof: BinaryMerkleProof = BinaryMerkleProof { side_nodes, key, num_leaves };
    let mut data = BytesTrait::new_empty();
    data.append_u8(0x01);
    let (is_valid, error_code) = merkle_tree::verify(root, @proof, @data);
    assert!(
        merkle_tree::is_no_error(error_code), "verify leaf one of eight test failed with error"
    );
    assert!(is_valid, "verify leaf one of eight test invalid");
}

#[test]
fn verify_leaf_two_of_eight_test() {
    let root: u256 = 0xc1ad6548cb4c7663110df219ec8b36ca63b01158956f4be31a38a88d0c7f7071;
    let side_nodes: Array<u256> = array![
        0xb413f47d13ee2fe6c845b2ee141af81de858df4ec549a58b7970bb96645bc8d2,
        0x78850a5ab36238b076dd99fd258c70d523168704247988a94caa8c9ccd056b8d,
        0x4301a067262bbb18b4919742326f6f6d706099f9c0e8b0f2db7b88f204b2cf09
    ];
    let key: u256 = 1;
    let num_leaves: u256 = 8;
    let proof: BinaryMerkleProof = BinaryMerkleProof { side_nodes, key, num_leaves };
    let mut data = BytesTrait::new_empty();
    data.append_u8(0x02);
    let (is_valid, error_code) = merkle_tree::verify(root, @proof, @data);
    assert!(
        merkle_tree::is_no_error(error_code), "verify leaf two of eight test failed with error"
    );
    assert!(is_valid, "verify leaf two of eight test invalid");
}

#[test]
fn verify_leaf_three_of_eight_test() {
    let root: u256 = 0xc1ad6548cb4c7663110df219ec8b36ca63b01158956f4be31a38a88d0c7f7071;
    let side_nodes: Array<u256> = array![
        0x4f35212d12f9ad2036492c95f1fe79baf4ec7bd9bef3dffa7579f2293ff546a4,
        0x6bcf0e2e93e0a18e22789aee965e6553f4fbe93f0acfc4a705d691c8311c4965,
        0x4301a067262bbb18b4919742326f6f6d706099f9c0e8b0f2db7b88f204b2cf09
    ];
    let key: u256 = 2;
    let num_leaves: u256 = 8;
    let proof: BinaryMerkleProof = BinaryMerkleProof { side_nodes, key, num_leaves };
    let mut data = BytesTrait::new_empty();
    data.append_u8(0x03);
    let (is_valid, error_code) = merkle_tree::verify(root, @proof, @data);
    assert!(
        merkle_tree::is_no_error(error_code), "verify leaf three of eight test failed with error"
    );
    assert!(is_valid, "verify leaf three of eight test invalid");
}

#[test]
fn verify_leaf_seven_of_eight_test() {
    let root: u256 = 0xc1ad6548cb4c7663110df219ec8b36ca63b01158956f4be31a38a88d0c7f7071;
    let side_nodes: Array<u256> = array![
        0xb4c43b50bf245bd727623e3c775a8fcfb8d823d00b57dd65f7f79dd33f126315,
        0x90eeb2c4a04ec33ee4dd2677593331910e4203db4fcc120a6cdb95b13cfe83f0,
        0xfa02d31a63cc11cc624881e52af14af7a1c6ab745efa71021cb24086b9b1793f
    ];
    let key: u256 = 6;
    let num_leaves: u256 = 8;
    let proof: BinaryMerkleProof = BinaryMerkleProof { side_nodes, key, num_leaves };
    let mut data = BytesTrait::new_empty();
    data.append_u8(0x07);
    let (is_valid, error_code) = merkle_tree::verify(root, @proof, @data);
    assert!(
        merkle_tree::is_no_error(error_code), "verify leaf seven of eight test failed with error"
    );
    assert!(is_valid, "verify leaf seven of eight test invalid");
}

#[test]
fn verify_leaf_eight_of_eight_test() {
    let root: u256 = 0xc1ad6548cb4c7663110df219ec8b36ca63b01158956f4be31a38a88d0c7f7071;
    let side_nodes: Array<u256> = array![
        0x2ecd8a6b7d2845546659ad4cf443533cf921b19dc81fa83934e83821b4dfdcb7,
        0x90eeb2c4a04ec33ee4dd2677593331910e4203db4fcc120a6cdb95b13cfe83f0,
        0xfa02d31a63cc11cc624881e52af14af7a1c6ab745efa71021cb24086b9b1793f
    ];
    let key: u256 = 7;
    let num_leaves: u256 = 8;
    let proof: BinaryMerkleProof = BinaryMerkleProof { side_nodes, key, num_leaves };
    let mut data = BytesTrait::new_empty();
    data.append_u8(0x08);
    let (is_valid, error_code) = merkle_tree::verify(root, @proof, @data);
    assert!(
        merkle_tree::is_no_error(error_code), "verify leaf eight of eight test failed with error"
    );
    assert!(is_valid, "verify leaf eight of eight test invalid");
}

#[test]
fn verify_proof_of_five_leaves_test() {
    let root: u256 = 0xb855b42d6c30f5b087e05266783fbd6e394f7b926013ccaa67700a8b0c5a596f;
    let side_nodes: Array<u256> = array![
        0x96a296d224f285c67bee93c30f8a309157f0daa35dc5b87e410b78630a09cfc7,
        0x52c56b473e5246933e7852989cd9feba3b38f078742b93afff1e65ed46797825,
        0x4f35212d12f9ad2036492c95f1fe79baf4ec7bd9bef3dffa7579f2293ff546a4
    ];

    let key: u256 = 1;
    let num_leaves: u256 = 5;
    let proof: BinaryMerkleProof = BinaryMerkleProof { side_nodes, key, num_leaves };
    let mut data = BytesTrait::new_empty();
    data.append_u8(0x01);
    let (is_valid, error_code) = merkle_tree::verify(root, @proof, @data);
    assert!(
        merkle_tree::is_no_error(error_code), "verify proof of five leaves test failed with error"
    );
    assert!(is_valid, "verify proof of five leaves test invalid");
}

#[test]
fn verify_invalid_proof_root_test() {
    // correct root: u256 = 0xb855b42d6c30f5b087e05266783fbd6e394f7b926013ccaa67700a8b0c5a596f;
    let root: u256 = 0xc855b42d6c30f5b087e05266783fbd6e394f7b926013ccaa67700a8b0c5a596f;
    let side_nodes: Array<u256> = array![
        0x96a296d224f285c67bee93c30f8a309157f0daa35dc5b87e410b78630a09cfc7,
        0x52c56b473e5246933e7852989cd9feba3b38f078742b93afff1e65ed46797825,
        0x4f35212d12f9ad2036492c95f1fe79baf4ec7bd9bef3dffa7579f2293ff546a4
    ];

    let key: u256 = 1;
    let num_leaves: u256 = 5;
    let proof: BinaryMerkleProof = BinaryMerkleProof { side_nodes, key, num_leaves };
    let mut data = BytesTrait::new_empty();
    data.append_u8(0x01);
    let (is_valid, error_code) = merkle_tree::verify(root, @proof, @data);
    assert!(
        merkle_tree::is_no_error(error_code), "verify invalid proof root test failed with error"
    );
    assert_eq!(is_valid, false, "verify invalid proof root test should be invalid");
}

#[test]
fn verify_invalid_proof_key_test() {
    let root: u256 = 0xb855b42d6c30f5b087e05266783fbd6e394f7b926013ccaa67700a8b0c5a596f;
    let side_nodes: Array<u256> = array![
        0x96a296d224f285c67bee93c30f8a309157f0daa35dc5b87e410b78630a09cfc7,
        0x52c56b473e5246933e7852989cd9feba3b38f078742b93afff1e65ed46797825,
        0x4f35212d12f9ad2036492c95f1fe79baf4ec7bd9bef3dffa7579f2293ff546a4
    ];

    // correct key: u256 = 1;
    let key: u256 = 2;
    let num_leaves: u256 = 5;
    let proof: BinaryMerkleProof = BinaryMerkleProof { side_nodes, key, num_leaves };
    let mut data = BytesTrait::new_empty();
    data.append_u8(0x01);
    let (is_valid, error_code) = merkle_tree::verify(root, @proof, @data);
    assert!(
        merkle_tree::is_no_error(error_code), "verify invalid proof key test failed with error"
    );
    assert_eq!(is_valid, false, "verify invalid proof key test should be invalid");
}

#[test]
fn verify_invalid_proof_number_of_leaves_test() {
    let root: u256 = 0xb855b42d6c30f5b087e05266783fbd6e394f7b926013ccaa67700a8b0c5a596f;
    let side_nodes: Array<u256> = array![
        0x96a296d224f285c67bee93c30f8a309157f0daa35dc5b87e410b78630a09cfc7,
        0x52c56b473e5246933e7852989cd9feba3b38f078742b93afff1e65ed46797825,
        0x4f35212d12f9ad2036492c95f1fe79baf4ec7bd9bef3dffa7579f2293ff546a4
    ];

    let key: u256 = 1;
    // correct num_leaves: u256 = 5;
    let num_leaves: u256 = 200;
    let proof: BinaryMerkleProof = BinaryMerkleProof { side_nodes, key, num_leaves };
    let mut data = BytesTrait::new_empty();
    data.append_u8(0x01);
    let (is_valid, error_code) = merkle_tree::verify(root, @proof, @data);
    assert_eq!(is_valid, false, "verify invalid proof number of leaves test should be invalid");
}

#[test]
fn verify_invalid_proof_side_nodes_test() {
    let root: u256 = 0xb855b42d6c30f5b087e05266783fbd6e394f7b926013ccaa67700a8b0c5a596f;
    let side_nodes: Array<u256> = array![
        0x96a296d224f285c67bee93c30f8a309157f0daa35dc5b87e410b78630a09cfc7,
        0x52c56b473e5246933e7852989cd9feba3b38f078742b93afff1e65ed46797825,
        // correct 0x4f35212d12f9ad2036492c95f1fe79baf4ec7bd9bef3dffa7579f2293ff546a4
        0x5f35212d12f9ad2036492c95f1fe79baf4ec7bd9bef3dffa7579f2293ff546a4
    ];

    let key: u256 = 1;
    let num_leaves: u256 = 5;
    let proof: BinaryMerkleProof = BinaryMerkleProof { side_nodes, key, num_leaves };
    let mut data = BytesTrait::new_empty();
    data.append_u8(0x01);
    let (is_valid, error_code) = merkle_tree::verify(root, @proof, @data);
    assert!(
        merkle_tree::is_no_error(error_code),
        "verify invalid proof side nodes test failed with error"
    );
    assert_eq!(is_valid, false, "verify invalid proof side nodes test should be invalid");
}

#[test]
fn verify_invalid_proof_data_test() {
    let root: u256 = 0xb855b42d6c30f5b087e05266783fbd6e394f7b926013ccaa67700a8b0c5a596f;
    let side_nodes: Array<u256> = array![
        0x96a296d224f285c67bee93c30f8a309157f0daa35dc5b87e410b78630a09cfc7,
        0x52c56b473e5246933e7852989cd9feba3b38f078742b93afff1e65ed46797825,
        0x4f35212d12f9ad2036492c95f1fe79baf4ec7bd9bef3dffa7579f2293ff546a4
    ];

    let key: u256 = 1;
    let num_leaves: u256 = 5;
    let proof: BinaryMerkleProof = BinaryMerkleProof { side_nodes, key, num_leaves };
    let mut data = BytesTrait::new_empty();
    // correct data.append_u8(0x01);
    data.append_u32(0x012345);
    let (is_valid, error_code) = merkle_tree::verify(root, @proof, @data);
    assert!(
        merkle_tree::is_no_error(error_code), "verify invalid proof data test failed with error"
    );
    assert_eq!(is_valid, false, "verify invalid proof data test should be invalid");
}

#[test]
fn valid_slice_test() {
    let data: Array<u256> = array!['a', 'b', 'c', 'd'];
    let result: Array<u256> = merkle_tree::slice(data.span(), 1, 3);
    assert_eq!(result.at(0), data.at(1), "valid slice test failed with first element");
    assert_eq!(result.at(1), data.at(2), "valid slice test failed with second element");
}

#[test]
fn same_key_and_leaves_number_test() {
    let root: u256 = 0xb855b42d6c30f5b087e05266783fbd6e394f7b926013ccaa67700a8b0c5a596f;
    let side_nodes: Array<u256> = array![];
    let key: u256 = 3;
    let num_leaves: u256 = 3;
    let proof: BinaryMerkleProof = BinaryMerkleProof { side_nodes, key, num_leaves };
    let mut data = BytesTrait::new_empty();
    data.append_u8(0x01);
    let (is_valid, error_code) = merkle_tree::verify(root, @proof, @data);
    assert_eq!(is_valid, false, "same key and leaves number test failed");
}

#[test]
fn consecutive_key_and_number_of_leaves_test() {
    let root: u256 = 0xb855b42d6c30f5b087e05266783fbd6e394f7b926013ccaa67700a8b0c5a596f;
    let side_nodes: Array<u256> = array![];
    let key: u256 = 6;
    let num_leaves: u256 = 7;
    let proof: BinaryMerkleProof = BinaryMerkleProof { side_nodes, key, num_leaves };
    let mut data = BytesTrait::new_empty();
    data.append_u8(0x01);
    let (is_valid, error_code) = merkle_tree::verify(root, @proof, @data);
    assert_eq!(is_valid, false, "consecutive key and number of leaves test failed");
}

#[test]
#[should_panic(expected: ("slice: begin > end",))]
fn invalid_slice_begin_end_test() {
    let data: Array<u256> = array!['a', 'b', 'c', 'd'];
    let result: Array<u256> = merkle_tree::slice(data.span(), 2, 1);
}

#[test]
#[should_panic(expected: ("slice: begin or end out of bounds",))]
fn out_of_bounds_slice_test() {
    let data: Array<u256> = array!['a', 'b', 'c', 'd'];
    let result: Array<u256> = merkle_tree::slice(data.span(), 2, 5);
}
