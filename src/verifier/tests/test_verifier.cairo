use alexandria_bytes::{Bytes, BytesTrait};
use blobstream_sn::interfaces::{IDAOracleDispatcher, IDAOracleDispatcherTrait};
use blobstream_sn::tests::common::setup_base;
use blobstream_sn::tree::binary::merkle_proof::BinaryMerkleProof;
use blobstream_sn::tree::binary::merkle_tree as binary_merkle_tree;
use blobstream_sn::tree::namespace::Namespace;
use blobstream_sn::tree::namespace::merkle_tree::{
    NamespaceNode, NamespaceMerkleMultiproof, NamespaceMerkleTree
};
use blobstream_sn::verifier::da_verifier::DAVerifier;
use blobstream_sn::verifier::types::DataRoot;
use blobstream_sn::verifier::types::{AttestationProof, SharesProof};
use snforge_std as snf;
use starknet::ContractAddress;

// The data used to generate the proof:

// The block used contains a single share:
// 0x0000000000000000000000000000000000000000000000000000000001010000014500000026c3020a95010a92010a1c2f636f736d6f732e62616e6b2e763162657461312e4d736753656e6412720a2f63656c657374696131746b376c776a77336676616578657770687237687833333472766b67646b736d636537666b66122f63656c65737469613167616b61646d63386a73667873646c676e6d64643867773736346739796165776e32726d386d1a0e0a0475746961120631303030303012670a500a460a1f2f636f736d6f732e63727970746f2e736563703235366b312e5075624b657912230a2103f3e16481ff7c9c2a677f08a30a887e5f9c14313cb624b8c5f7f955d143c81d9212040a020801180112130a0d0a04757469611205323230303010d0e80c1a4068f074601f1bb923f6d6e69d2e3fc3af145c9252eceeb0ac4fba9f661ca0428326f0080478cc969129c0074c3d97ae925de34c5f9d98a458cd47a565a2bb08cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

// The extended block is:
// 0x0000000000000000000000000000000000000000000000000000000001010000014500000026c3020a95010a92010a1c2f636f736d6f732e62616e6b2e763162657461312e4d736753656e6412720a2f63656c657374696131746b376c776a77336676616578657770687237687833333472766b67646b736d636537666b66122f63656c65737469613167616b61646d63386a73667873646c676e6d64643867773736346739796165776e32726d386d1a0e0a0475746961120631303030303012670a500a460a1f2f636f736d6f732e63727970746f2e736563703235366b312e5075624b657912230a2103f3e16481ff7c9c2a677f08a30a887e5f9c14313cb624b8c5f7f955d143c81d9212040a020801180112130a0d0a04757469611205323230303010d0e80c1a4068f074601f1bb923f6d6e69d2e3fc3af145c9252eceeb0ac4fba9f661ca0428326f0080478cc969129c0074c3d97ae925de34c5f9d98a458cd47a565a2bb08cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
// 0x0000000000000000000000000000000000000000000000000000000001010000014500000026c3020a95010a92010a1c2f636f736d6f732e62616e6b2e763162657461312e4d736753656e6412720a2f63656c657374696131746b376c776a77336676616578657770687237687833333472766b67646b736d636537666b66122f63656c65737469613167616b61646d63386a73667873646c676e6d64643867773736346739796165776e32726d386d1a0e0a0475746961120631303030303012670a500a460a1f2f636f736d6f732e63727970746f2e736563703235366b312e5075624b657912230a2103f3e16481ff7c9c2a677f08a30a887e5f9c14313cb624b8c5f7f955d143c81d9212040a020801180112130a0d0a04757469611205323230303010d0e80c1a4068f074601f1bb923f6d6e69d2e3fc3af145c9252eceeb0ac4fba9f661ca0428326f0080478cc969129c0074c3d97ae925de34c5f9d98a458cd47a565a2bb08cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
// 0x0000000000000000000000000000000000000000000000000000000001010000014500000026c3020a95010a92010a1c2f636f736d6f732e62616e6b2e763162657461312e4d736753656e6412720a2f63656c657374696131746b376c776a77336676616578657770687237687833333472766b67646b736d636537666b66122f63656c65737469613167616b61646d63386a73667873646c676e6d64643867773736346739796165776e32726d386d1a0e0a0475746961120631303030303012670a500a460a1f2f636f736d6f732e63727970746f2e736563703235366b312e5075624b657912230a2103f3e16481ff7c9c2a677f08a30a887e5f9c14313cb624b8c5f7f955d143c81d9212040a020801180112130a0d0a04757469611205323230303010d0e80c1a4068f074601f1bb923f6d6e69d2e3fc3af145c9252eceeb0ac4fba9f661ca0428326f0080478cc969129c0074c3d97ae925de34c5f9d98a458cd47a565a2bb08cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
// 0x0000000000000000000000000000000000000000000000000000000001010000014500000026c3020a95010a92010a1c2f636f736d6f732e62616e6b2e763162657461312e4d736753656e6412720a2f63656c657374696131746b376c776a77336676616578657770687237687833333472766b67646b736d636537666b66122f63656c65737469613167616b61646d63386a73667873646c676e6d64643867773736346739796165776e32726d386d1a0e0a0475746961120631303030303012670a500a460a1f2f636f736d6f732e63727970746f2e736563703235366b312e5075624b657912230a2103f3e16481ff7c9c2a677f08a30a887e5f9c14313cb624b8c5f7f955d143c81d9212040a020801180112130a0d0a04757469611205323230303010d0e80c1a4068f074601f1bb923f6d6e69d2e3fc3af145c9252eceeb0ac4fba9f661ca0428326f0080478cc969129c0074c3d97ae925de34c5f9d98a458cd47a565a2bb08cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

// The row roots:
// 0x00000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000001787bf77b567506b6e1d0048bfd89edd352a4fbc102e62f07cc9fe6b4cbe5ee69
// 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7329c7d336d0140840837fc0d8eafa2403f4f6b019b602581cd9f04e28026eae

// The column roots:
// 0x00000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000001787bf77b567506b6e1d0048bfd89edd352a4fbc102e62f07cc9fe6b4cbe5ee69
// 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7329c7d336d0140840837fc0d8eafa2403f4f6b019b602581cd9f04e28026eae

// The data root: 0x55cfc29fc0cd263906122d5cb859091224495b141fc0c51529612d7ab8962950

// The height: 3

// The blocks data roots used to create the commitment:
// 1. 0x3d96b7d238e7e0456f6af8e7cdf0a67bd6cf9c2089ecb559c659dcaa1f880353
// 2. 0x3d96b7d238e7e0456f6af8e7cdf0a67bd6cf9c2089ecb559c659dcaa1f880353
// 3. 0x55cfc29fc0cd263906122d5cb859091224495b141fc0c51529612d7ab8962950
// 4. 0x3d96b7d238e7e0456f6af8e7cdf0a67bd6cf9c2089ecb559c659dcaa1f880353

// The nonce: 2

// The data root tuple root: 0xf89859a09c0f2b1bbb039618d0fe60432b8c247f7ccde97814655f2acffb3434

fn setup() -> ContractAddress {
    let bsx_address = setup_base();

    // store the commitment we verify against
    let proof_nonce: u64 = TestFixture::data_root_tuple_root_nonce().try_into().unwrap();
    let data_commitment: u256 = TestFixture::data_root_tuple_root();
    snf::store(
        bsx_address,
        snf::map_entry_address(
            selector!("state_data_commitments"), array![proof_nonce.into()].span()
        ),
        array![data_commitment.low.into(), data_commitment.high.into()].span(),
    );
    snf::store(bsx_address, selector!("state_proof_nonce"), array![3].span(),);

    bsx_address
}

#[test]
fn test_verify_shares_to_data_root_tuple_root() {
    let bsx_address = setup();
    let bridge = IDAOracleDispatcher { contract_address: bsx_address };

    let data: Array<Bytes> = array![TestFixture::share_data()];
    let share_proofs: Array<NamespaceMerkleMultiproof> = array![
        TestFixture::get_share_to_row_root_proof()
    ];
    let namespace: Namespace = TestFixture::get_namespace();
    let row_roots: Array<NamespaceNode> = array![TestFixture::get_first_row_root_node()];
    let row_proofs: Array<BinaryMerkleProof> = array![
        TestFixture::get_row_root_to_data_root_proof()
    ];
    let attestation_proof = AttestationProof {
        commit_nonce: TestFixture::data_root_tuple_root_nonce(),
        data_root: TestFixture::get_data_root_tuple(),
        proof: TestFixture::get_data_root_tuple_proof()
    };
    let shares_proof = SharesProof {
        data, share_proofs, namespace, row_roots, row_proofs, attestation_proof
    };
    let root: u256 = TestFixture::data_root();

    let (valid, error) = DAVerifier::verify_shares_to_data_root_tuple_root(
        bridge, shares_proof, root
    );
    assert!(valid, "proofs should be valid");
    assert_eq!(error, DAVerifier::Error::NoError, "expected no error");
}

#[test]
fn test_verify_row_root_to_data_root_tuple_root() {
    let bsx_address = setup();
    let bridge = IDAOracleDispatcher { contract_address: bsx_address };

    let attestation_proof = AttestationProof {
        commit_nonce: TestFixture::data_root_tuple_root_nonce(),
        data_root: TestFixture::get_data_root_tuple(),
        proof: TestFixture::get_data_root_tuple_proof()
    };

    let (valid, error) = DAVerifier::verify_row_root_to_data_root_tuple_root(
        bridge: bridge,
        row_root: TestFixture::get_first_row_root_node(),
        row_proof: TestFixture::get_row_root_to_data_root_proof(),
        attestation_proof: attestation_proof,
        root: TestFixture::data_root()
    );
    assert!(valid, "proofs should be valid");
    assert_eq!(error, DAVerifier::Error::NoError, "expected no error");
}

#[test]
fn test_verify_multi_row_roots_to_data_root_tuple_root() {
    let bsx_address = setup();
    let bridge = IDAOracleDispatcher { contract_address: bsx_address };

    let row_roots: Span<NamespaceNode> = array![TestFixture::get_first_row_root_node()].span();
    let row_proofs: Span<BinaryMerkleProof> = array![TestFixture::get_row_root_to_data_root_proof()]
        .span();
    let attestation_proof = AttestationProof {
        commit_nonce: TestFixture::data_root_tuple_root_nonce(),
        data_root: TestFixture::get_data_root_tuple(),
        proof: TestFixture::get_data_root_tuple_proof()
    };
    let root: u256 = TestFixture::data_root();

    let (valid, error) = DAVerifier::verify_multi_row_roots_to_data_root_tuple_root(
        bridge, row_roots, row_proofs, attestation_proof, root
    );
    assert!(valid, "proofs should be valid");
    assert_eq!(error, DAVerifier::Error::NoError, "expected no error");
}

#[test]
fn test_compute_square_size_from_row_proof() {
    // check that the merkle proof is valid
    let (valid_merkle_proof, error) = binary_merkle_tree::verify(
        root: TestFixture::data_root(),
        proof: @TestFixture::get_row_root_to_data_root_proof(),
        data: @TestFixture::first_row_root()
    );
    assert!(valid_merkle_proof, "merkle proof should be valid");
    assert_eq!(error, binary_merkle_tree::ErrorCodes::NoError, "expected no error");

    // check that the computed square size is correct
    let expected_square_size: u256 = 1;
    let (actual_square_size, error) = DAVerifier::compute_square_size_from_row_proof(
        TestFixture::get_row_root_to_data_root_proof()
    );
    assert_eq!(expected_square_size, actual_square_size, "square size mismatch");
    assert_eq!(error, DAVerifier::Error::NoError, "compute square size from row proof failed");
}

#[test]
fn test_compute_square_size_from_share_proof() {
    let data: Span<Bytes> = array![TestFixture::share_data()].span();

    // check that the merkle proof is valid
    let valid_merkle_proof = NamespaceMerkleTree::verify_multi(
        root: TestFixture::get_first_row_root_node(),
        proof: @TestFixture::get_share_to_row_root_proof(),
        namespace: TestFixture::get_namespace(),
        data: data
    );
    assert!(valid_merkle_proof, "merkle proof should be valid");

    // check that the computed square size is correct
    let expected_square_size: u256 = 1;
    let actual_square_size = DAVerifier::compute_square_size_from_share_proof(
        TestFixture::get_share_to_row_root_proof()
    );
    assert_eq!(expected_square_size, actual_square_size, "square size mismatch");
}

#[test]
fn attestation_proof_test() {
    let checkpoint = AttestationProof {
        commit_nonce: 1,
        data_root: DataRoot { height: 2, data_root: 3 },
        proof: BinaryMerkleProof { side_nodes: array![1], key: 4, num_leaves: 5 },
    };
    assert!(checkpoint.commit_nonce == 1, "stub for verifier test");
}

/// Contains the necessary information to create proofs for the token
/// transfer transaction that happened on Celestia. It represents the data mentioned in
/// the comment at the beginning of this file.
mod TestFixture {
    use alexandria_bytes::{Bytes, BytesTrait};
    use alexandria_encoding::sol_abi::{SolBytesTrait, SolAbiEncodeTrait};
    use blobstream_sn::interfaces::DataRoot;
    use blobstream_sn::tree::binary::merkle_proof::BinaryMerkleProof;
    use blobstream_sn::tree::namespace::Namespace;
    use blobstream_sn::tree::namespace::merkle_tree::{NamespaceNode, NamespaceMerkleMultiproof};

    /// The share containing the token transfer transaction on Celestia.
    fn share_data() -> Bytes {
        BytesTrait::new(
            512,
            array![
                0x00000000000000000000000000000000,
                0x00000000000000000000000001010000,
                0x014500000026c3020a95010a92010a1c,
                0x2f636f736d6f732e62616e6b2e763162,
                0x657461312e4d736753656e6412720a2f,
                0x63656c657374696131746b376c776a77,
                0x33667661657865777068723768783333,
                0x3472766b67646b736d636537666b6612,
                0x2f63656c65737469613167616b61646d,
                0x63386a73667873646c676e6d64643867,
                0x773736346739796165776e32726d386d,
                0x1a0e0a04757469611206313030303030,
                0x12670a500a460a1f2f636f736d6f732e,
                0x63727970746f2e736563703235366b31,
                0x2e5075624b657912230a2103f3e16481,
                0xff7c9c2a677f08a30a887e5f9c14313c,
                0xb624b8c5f7f955d143c81d9212040a02,
                0x0801180112130a0d0a04757469611205,
                0x323230303010d0e80c1a4068f074601f,
                0x1bb923f6d6e69d2e3fc3af145c9252ec,
                0xeeb0ac4fba9f661ca0428326f0080478,
                0xcc969129c0074c3d97ae925de34c5f9d,
                0x98a458cd47a565a2bb08cc0000000000,
                0x00000000000000000000000000000000,
                0x00000000000000000000000000000000,
                0x00000000000000000000000000000000,
                0x00000000000000000000000000000000,
                0x00000000000000000000000000000000,
                0x00000000000000000000000000000000,
                0x00000000000000000000000000000000,
                0x00000000000000000000000000000000,
                0x00000000000000000000000000000000,
            ]
        )
    }

    /// The first EDS row root.
    fn first_row_root() -> Bytes {
        BytesTrait::new(
            90,
            array![
                0x00000000000000000000000000000000,
                0x00000000000000000000000001000000,
                0x00000000000000000000000000000000,
                0x00000000000000000001787bf77b5675,
                0x06b6e1d0048bfd89edd352a4fbc102e6,
                0x2f07cc9fe6b4cbe5ee69000000000000,
            ]
        )
    }

    /// The second EDS row root.
    fn second_row_root() -> Bytes {
        BytesTrait::new(
            90,
            array![
                0xffffffffffffffffffffffffffffffff,
                0xffffffffffffffffffffffffffffffff,
                0xffffffffffffffffffffffffffffffff,
                0xffffffffffffffffffff7329c7d336d0,
                0x140840837fc0d8eafa2403f4f6b019b6,
                0x02581cd9f04e28026eae000000000000,
            ]
        )
    }

    /// The first EDS column root.
    fn first_column_root() -> Bytes {
        BytesTrait::new(
            90,
            array![
                0x00000000000000000000000000000000,
                0x00000000000000000000000001000000,
                0x00000000000000000000000000000000,
                0x00000000000000000001787bf77b5675,
                0x06b6e1d0048bfd89edd352a4fbc102e6,
                0x2f07cc9fe6b4cbe5ee69000000000000,
            ]
        )
    }

    /// The second EDS column root.
    fn second_column_root() -> Bytes {
        BytesTrait::new(
            90,
            array![
                0xffffffffffffffffffffffffffffffff,
                0xffffffffffffffffffffffffffffffff,
                0xffffffffffffffffffffffffffffffff,
                0xffffffffffffffffffff7329c7d336d0,
                0x140840837fc0d8eafa2403f4f6b019b6,
                0x02581cd9f04e28026eae000000000000,
            ]
        )
    }

    /// The data root of the block containing the token transfer transaction.
    fn data_root() -> u256 {
        0x55cfc29fc0cd263906122d5cb859091224495b141fc0c51529612d7ab8962950
    }

    /// The height of the block containing the submitted token transfer transaction.
    fn height() -> felt252 {
        3
    }

    /// The data root tuple root committing to the Celestia block.
    fn data_root_tuple_root() -> u256 {
        0xf89859a09c0f2b1bbb039618d0fe60432b8c247f7ccde97814655f2acffb3434
    }

    /// The data root tuple root nonce in the Blobstream contract.
    fn data_root_tuple_root_nonce() -> u256 {
        2
    }

    /// The data root tuple to data root tuple root proof side nodes.
    fn data_root_proof_side_nodes() -> Array<u256> {
        array![
            0xb5d4d27ec6b206a205bf09dde3371ffba62e5b53d27bbec4255b7f4f27ef5d90,
            0x406e22ba94989ca721453057a1391fc531edb342c86a0ab4cc722276b54036ec
        ]
    }

    /// Shares to data root proof side nodes.
    fn share_to_data_root_proof_side_nodes() -> Array<NamespaceNode> {
        let n = Namespace {
            version: 0xff,
            id: bytes31_const::<0xffffffffffffffffffffffffffffffffffffffffffffffffffffffff>()
        };
        array![
            NamespaceNode {
                min: n,
                max: n,
                digest: 0x0ec8148c743a4a4db384f40f487cae2fd1ca0d18442d1f162916bdf1cc61b679
            }
        ]
    }

    /// Row root to data root proof side nodes.
    fn row_root_to_data_root_proof_side_nodes() -> Array<u256> {
        array![
            0x5bc0cf3322dd5c9141a2dcd76947882351690c9aec61015802efc6742992643f,
            0xff576381b02abadc50e414f6b4efcae31091cd40a5aba75f56be52d1bb2efcae
        ]
    }

    /// The share's namespace.
    fn get_namespace() -> Namespace {
        Namespace {
            version: 0x00,
            id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000001>()
        }
    }

    /// The data root tuple of the block containing the token transfer transaction.
    fn get_data_root_tuple() -> DataRoot {
        DataRoot { height: height(), data_root: data_root() }
    }

    /// The data root tuple to data root tuple root proof.
    fn get_data_root_tuple_proof() -> BinaryMerkleProof {
        BinaryMerkleProof { side_nodes: data_root_proof_side_nodes(), key: 2, num_leaves: 4 }
    }

    /// The first EDS row root.
    fn get_first_row_root_node() -> NamespaceNode {
        let n = Namespace {
            version: 0x00,
            id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000001>()
        };
        NamespaceNode {
            min: n,
            max: n,
            digest: 0x787bf77b567506b6e1d0048bfd89edd352a4fbc102e62f07cc9fe6b4cbe5ee69
        }
    }

    /// The second EDS row root.
    fn get_second_row_root_node() -> NamespaceNode {
        let n = Namespace {
            version: 0xff,
            id: bytes31_const::<0xffffffffffffffffffffffffffffffffffffffffffffffffffffffff>()
        };
        NamespaceNode {
            min: n,
            max: n,
            digest: 0x7329c7d336d0140840837fc0d8eafa2403f4f6b019b602581cd9f04e28026eae
        }
    }

    /// The first EDS column root.
    fn get_first_column_root_node() -> NamespaceNode {
        let n = Namespace {
            version: 0x00,
            id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000001>()
        };
        NamespaceNode {
            min: n,
            max: n,
            digest: 0x787bf77b567506b6e1d0048bfd89edd352a4fbc102e62f07cc9fe6b4cbe5ee69
        }
    }

    /// The second EDS column root.
    fn get_second_column_root_node() -> NamespaceNode {
        let n = Namespace {
            version: 0xff,
            id: bytes31_const::<0xffffffffffffffffffffffffffffffffffffffffffffffffffffffff>()
        };
        NamespaceNode {
            min: n,
            max: n,
            digest: 0x7329c7d336d0140840837fc0d8eafa2403f4f6b019b602581cd9f04e28026eae
        }
    }

    /// The shares to row root proof.
    fn get_share_to_row_root_proof() -> NamespaceMerkleMultiproof {
        NamespaceMerkleMultiproof {
            begin_key: 0, end_key: 1, side_nodes: share_to_data_root_proof_side_nodes()
        }
    }

    /// Row root to data root proof.
    fn get_row_root_to_data_root_proof() -> BinaryMerkleProof {
        BinaryMerkleProof {
            side_nodes: row_root_to_data_root_proof_side_nodes(), key: 0, num_leaves: 4
        }
    }
}
