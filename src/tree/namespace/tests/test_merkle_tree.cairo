/// Implement tests from https://github.com/celestiaorg/blobstream-contracts/blob/master/src/lib/tree/namespace/test/NamespaceMerkleTree.t.sol

use alexandria_bytes::{Bytes, BytesTrait};
use alexandria_encoding::sol_abi::{SolBytesTrait, SolAbiEncodeTrait};
use blobstream_sn::tree::consts;
use blobstream_sn::tree::namespace::Namespace;
use blobstream_sn::tree::namespace::hasher;
use blobstream_sn::tree::namespace::merkle_tree::{
    NamespaceNode, NamespaceMerkleProof, NamespaceMerkleTree
};

#[test]
fn verify_none_test() {
    let nid: Namespace = Default::default();
    let empty = BytesTrait::new_empty();
    let root = NamespaceNode { min: nid, max: nid, digest: empty.sha256() };
    let side_nodes: Array<NamespaceNode> = array![];
    let key: u256 = 0;
    let num_leaves: u256 = 0;
    let proof = NamespaceMerkleProof { side_nodes, key, num_leaves };
    let data = BytesTrait::new_empty();
    let is_valid = NamespaceMerkleTree::verify(root, proof, nid, data);
    assert!(!is_valid, "None proof should not be valid");
}

#[test]
fn verify_one_leaf_empty_test() {
    let nid: Namespace = Default::default();
    let root = NamespaceNode {
        min: nid,
        max: nid,
        digest: 0x0679246d6c4216de0daa08e5523fb2674db2b6599c3b72ff946b488a15290b62
    };
    let side_nodes: Array<NamespaceNode> = array![];
    let key: u256 = 0;
    let num_leaves: u256 = 1;
    let proof = NamespaceMerkleProof { side_nodes, key, num_leaves };
    let data = BytesTrait::new_empty();
    let is_valid = NamespaceMerkleTree::verify(root, proof, nid, data);
    assert!(is_valid, "One leaf empty proof should be valid");
}

#[test]
fn verify_one_leaf_some_test() {
    let nid: Namespace = Default::default();
    let root = NamespaceNode {
        min: nid,
        max: nid,
        digest: 0x56d8381cfe28e8eb21da620145b7b977a74837720da5147b00bfab6f1b4af24d
    };
    let side_nodes: Array<NamespaceNode> = array![];
    let key: u256 = 0;
    let num_leaves: u256 = 1;
    let proof = NamespaceMerkleProof { side_nodes, key, num_leaves };
    let mut data = BytesTrait::new_empty()
    .encode_packed(0xdeadbeef_u32);
    let is_valid = NamespaceMerkleTree::verify(root, proof, nid, data);
    assert!(is_valid, "One leaf some proof should be valid");
}

#[test]
fn verify_one_leaf_01_test() {
    let nid: Namespace = Default::default();
    let root = NamespaceNode {
        min: nid,
        max: nid,
        digest: 0x353857cdb4c745eb9fdebbd8ec44093fabb9f08d437e2298d9e6afa1a409b30c
    };
    let side_nodes: Array<NamespaceNode> = array![];
    let key: u256 = 0;
    let num_leaves: u256 = 1;
    let proof = NamespaceMerkleProof { side_nodes, key, num_leaves };
    let mut data = BytesTrait::new_empty()
    .encode_packed(0x01_u8);
    let is_valid = NamespaceMerkleTree::verify(root, proof, nid, data);
    assert!(is_valid, "One leaf 01 proof should be valid");
}

#[test]
fn verify_leaf_one_of_two_test() {
    let node10 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000010>()
    };
    let node20 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000020>()
    };
    let root = NamespaceNode {
        min: node10,
        max: node20,
        digest: 0x1dae5c3d39a8bf31ea33ba368238a52f816cd50485c580565609554cf360c91f
    };
    let side_nodes: Array<NamespaceNode> = array![
        NamespaceNode {
            min: node20,
            max: node20,
            digest: 0xc5fd5617b70207108c8d9bcf624b1eedf39b763af86f660255947674e043cd2c
        }
    ];
    let key: u256 = 0;
    let num_leaves: u256 = 2;
    let proof = NamespaceMerkleProof { side_nodes, key, num_leaves };
    let mut data = BytesTrait::new_empty()
    .encode_packed(0x01_u8);
    let is_valid = NamespaceMerkleTree::verify(root, proof, node10, data);
    assert!(is_valid, "Leaf one of two proof should be valid");
}

#[test]
fn verify_leaf_one_of_four_test() {
    let node10 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000010>()
    };
    let node20 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000020>()
    };
    let node30 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000030>()
    };
    let node40 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000040>()
    };
    let root = NamespaceNode {
        min: node10,
        max: node40,
        digest: 0xa8dcd9f365fb64aa6d72b5027fe74db0fc7d009c2d75c7b9b9656927281cb35e
    };
    let side_nodes: Array<NamespaceNode> = array![
        NamespaceNode {
            min: node20,
            max: node20,
            digest: 0xc5fd5617b70207108c8d9bcf624b1eedf39b763af86f660255947674e043cd2c
        },
        NamespaceNode {
            min: node30,
            max: node40,
            digest: 0x2aa20c7587b009772a9a88402b7cc8fcb82edc9e31754e95544a670a696f55a7
        }
    ];
    let key: u256 = 0;
    let num_leaves: u256 = 4;
    let proof = NamespaceMerkleProof { side_nodes, key, num_leaves };
    let mut data = BytesTrait::new_empty()
    .encode_packed(0x01_u8);
    let is_valid = NamespaceMerkleTree::verify(root, proof, node10, data);
    assert!(is_valid, "Leaf one of four proof should be valid");
}

#[test]
fn verify_leaf_one_of_eight_test() {
    let node10 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000010>()
    };
    let node20 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000020>()
    };
    let node30 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000030>()
    };
    let node40 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000040>()
    };
    let root = NamespaceNode {
        min: node10,
        max: node40,
        digest: 0x34e6541306dc4e57a5a2a9ef57a46d5705ed09efb8c6a02580d3a972922b6862
    };
    let side_nodes: Array<NamespaceNode> = array![
        NamespaceNode {
            min: node20,
            max: node20,
            digest: 0xc5fd5617b70207108c8d9bcf624b1eedf39b763af86f660255947674e043cd2c
        },
        NamespaceNode {
            min: node30,
            max: node40,
            digest: 0x2aa20c7587b009772a9a88402b7cc8fcb82edc9e31754e95544a670a696f55a7
        },
        NamespaceNode {
            min: consts::parity_share_namespace(),
            max: consts::parity_share_namespace(),
            digest: 0x5aa3e7ea31995fdd38f41015275229b290a8ee4810521db766ad457b9a8373d6
        }
    ];
    let key: u256 = 0;
    let num_leaves: u256 = 8;
    let proof = NamespaceMerkleProof { side_nodes, key, num_leaves };
    let mut data = BytesTrait::new_empty()
    .encode_packed(0x01_u8);
    let is_valid = NamespaceMerkleTree::verify(root, proof, node10, data);
    assert!(is_valid, "Leaf one of eight proof should be valid");
}

#[test]
fn verify_leaf_seven_of_eight_test() {
    let node10 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000010>()
    };
    let node40 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000040>()
    };
    let root = NamespaceNode {
        min: node10,
        max: node40,
        digest: 0x34e6541306dc4e57a5a2a9ef57a46d5705ed09efb8c6a02580d3a972922b6862
    };
    let side_nodes: Array<NamespaceNode> = array![
        NamespaceNode {
            min: consts::parity_share_namespace(),
            max: consts::parity_share_namespace(),
            digest: 0x655790e24d376e9556a3cba9908a5d97f27faa050806ecfcb481861a83240bd5
        },
        NamespaceNode {
            min: consts::parity_share_namespace(),
            max: consts::parity_share_namespace(),
            digest: 0x055a3ea75c438d752aeabbba94ed8fac93e0b32321256a65fde176dba14f5186
        },
        NamespaceNode {
            min: node10,
            max: node40,
            digest: 0xa8dcd9f365fb64aa6d72b5027fe74db0fc7d009c2d75c7b9b9656927281cb35e
        }
    ];
    let key: u256 = 6;
    let num_leaves: u256 = 8;
    let proof = NamespaceMerkleProof { side_nodes, key, num_leaves };
    let mut data = BytesTrait::new_empty()
    .encode_packed(0x07_u8);
    let is_valid = NamespaceMerkleTree::verify(root, proof, consts::parity_share_namespace(), data);
    assert!(is_valid, "Leaf seven of eight proof should be valid");
}

#[test]
fn verify_leaf_eight_of_eight_test() {
    let node10 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000010>()
    };
    let node40 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000040>()
    };
    let root = NamespaceNode {
        min: node10,
        max: node40,
        digest: 0x34e6541306dc4e57a5a2a9ef57a46d5705ed09efb8c6a02580d3a972922b6862
    };
    let side_nodes: Array<NamespaceNode> = array![
        NamespaceNode {
            min: consts::parity_share_namespace(),
            max: consts::parity_share_namespace(),
            digest: 0x2669e36b48e95bd9903300e50c27c53984fc439f6235fade08e3f14e78a42aac
        },
        NamespaceNode {
            min: consts::parity_share_namespace(),
            max: consts::parity_share_namespace(),
            digest: 0x055a3ea75c438d752aeabbba94ed8fac93e0b32321256a65fde176dba14f5186
        },
        NamespaceNode {
            min: node10,
            max: node40,
            digest: 0xa8dcd9f365fb64aa6d72b5027fe74db0fc7d009c2d75c7b9b9656927281cb35e
        }
    ];
    let key: u256 = 7;
    let num_leaves: u256 = 8;
    let proof = NamespaceMerkleProof { side_nodes, key, num_leaves };
    let mut data = BytesTrait::new_empty()
    .encode_packed(0x08_u8);
    let is_valid = NamespaceMerkleTree::verify(root, proof, consts::parity_share_namespace(), data);
    assert!(is_valid, "Leaf eight of eight proof should be valid");
}

#[test]
fn verify_leaf_five_of_eight_test() {
    let node10 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000010>()
    };
    let node40 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000040>()
    };
    let root = NamespaceNode {
        min: node10,
        max: node40,
        digest: 0x34e6541306dc4e57a5a2a9ef57a46d5705ed09efb8c6a02580d3a972922b6862
    };
    let side_nodes: Array<NamespaceNode> = array![
        NamespaceNode {
            min: consts::parity_share_namespace(),
            max: consts::parity_share_namespace(),
            digest: 0x671157a4e268f7060abbdc4b48f091589555a0775a2694e6899833ec98fdb296
        },
        NamespaceNode {
            min: consts::parity_share_namespace(),
            max: consts::parity_share_namespace(),
            digest: 0x1b79ffd74644e8c287fe5f1dd70bc8ea02738697cebf2810ffb2dc5157485c40
        },
        NamespaceNode {
            min: node10,
            max: node40,
            digest: 0xa8dcd9f365fb64aa6d72b5027fe74db0fc7d009c2d75c7b9b9656927281cb35e
        }
    ];
    let key: u256 = 4;
    let num_leaves: u256 = 8;
    let proof = NamespaceMerkleProof { side_nodes, key, num_leaves };
    let mut data = BytesTrait::new_empty()
    .encode_packed(0x05_u8);
    let is_valid = NamespaceMerkleTree::verify(root, proof, consts::parity_share_namespace(), data);
    assert!(is_valid, "Leaf five of eight proof should be valid");
}

#[test]
fn verify_leaf_four_of_eight_test() {
    let node10 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000010>()
    };
    let node20 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000020>()
    };
    let node30 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000030>()
    };
    let node40 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000040>()
    };
    let root = NamespaceNode {
        min: node10,
        max: node40,
        digest: 0x34e6541306dc4e57a5a2a9ef57a46d5705ed09efb8c6a02580d3a972922b6862
    };
    let side_nodes: Array<NamespaceNode> = array![
        NamespaceNode {
            min: node30,
            max: node30,
            digest: 0x35e864d3e196ef0986fcf18eea2782c7e68794c7106dacc2a4f7e40d6d7c7069
        },
        NamespaceNode {
            min: node10,
            max: node20,
            digest: 0x1dae5c3d39a8bf31ea33ba368238a52f816cd50485c580565609554cf360c91f
        },
        NamespaceNode {
            min: consts::parity_share_namespace(),
            max: consts::parity_share_namespace(),
            digest: 0x5aa3e7ea31995fdd38f41015275229b290a8ee4810521db766ad457b9a8373d6
        }
    ];
    let key: u256 = 3;
    let num_leaves: u256 = 8;
    let proof = NamespaceMerkleProof { side_nodes, key, num_leaves };
    let mut data = BytesTrait::new_empty()
    .encode_packed(0x04_u8);
    let is_valid = NamespaceMerkleTree::verify(root, proof, node40, data);
    assert!(is_valid, "Leaf four of eight proof should be valid");
}

#[test]
fn verify_leaf_three_of_eight_test() {
    let node10 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000010>()
    };
    let node20 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000020>()
    };
    let node30 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000030>()
    };
    let node40 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000040>()
    };
    let root = NamespaceNode {
        min: node10,
        max: node40,
        digest: 0x34e6541306dc4e57a5a2a9ef57a46d5705ed09efb8c6a02580d3a972922b6862
    };
    let side_nodes: Array<NamespaceNode> = array![
        NamespaceNode {
            min: node40,
            max: node40,
            digest: 0xecdeb08b04dd92a17fec560e20c53269f65beff5a2626fa64f61bfa45b09119d
        },
        NamespaceNode {
            min: node10,
            max: node20,
            digest: 0x1dae5c3d39a8bf31ea33ba368238a52f816cd50485c580565609554cf360c91f
        },
        NamespaceNode {
            min: consts::parity_share_namespace(),
            max: consts::parity_share_namespace(),
            digest: 0x5aa3e7ea31995fdd38f41015275229b290a8ee4810521db766ad457b9a8373d6
        }
    ];
    let key: u256 = 2;
    let num_leaves: u256 = 8;
    let proof = NamespaceMerkleProof { side_nodes, key, num_leaves };
    let mut data = BytesTrait::new_empty()
    .encode_packed(0x03_u8);
    let is_valid = NamespaceMerkleTree::verify(root, proof, node30, data);
    assert!(is_valid, "Leaf three of eight proof should be valid");
}

#[test]
fn verify_leaf_five_of_seven_test() {
    let node10 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000010>()
    };
    let node40 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000040>()
    };
    let root = NamespaceNode {
        min: node10,
        max: node40,
        digest: 0xfe7100a7170cba2065c48e01cb18772ed93865100bb7610aed3f614829c87a48
    };
    let side_nodes: Array<NamespaceNode> = array![
        NamespaceNode {
            min: consts::parity_share_namespace(),
            max: consts::parity_share_namespace(),
            digest: 0x671157a4e268f7060abbdc4b48f091589555a0775a2694e6899833ec98fdb296
        },
        NamespaceNode {
            min: consts::parity_share_namespace(),
            max: consts::parity_share_namespace(),
            digest: 0x2669e36b48e95bd9903300e50c27c53984fc439f6235fade08e3f14e78a42aac
        },
        NamespaceNode {
            min: node10,
            max: node40,
            digest: 0xa8dcd9f365fb64aa6d72b5027fe74db0fc7d009c2d75c7b9b9656927281cb35e
        }
    ];
    let key: u256 = 4;
    let num_leaves: u256 = 7;
    let proof = NamespaceMerkleProof { side_nodes, key, num_leaves };
    let mut data = BytesTrait::new_empty()
    .encode_packed(0x05_u8);
    let is_valid = NamespaceMerkleTree::verify(root, proof, consts::parity_share_namespace(), data);
    assert!(is_valid, "Leaf five of seven proof should be valid");
}

#[test]
fn verify_leaf_nine_of_ten_test() {
    let node10 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000010>()
    };
    let node60 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000060>()
    };
    let root = NamespaceNode {
        min: node10,
        max: node60,
        digest: 0x21013157ca1c0d454c988665e05894f5cf9422928552349ac3fd359bd1d39ac1
    };
    let side_nodes: Array<NamespaceNode> = array![
        NamespaceNode {
            min: consts::parity_share_namespace(),
            max: consts::parity_share_namespace(),
            digest: 0x8ecd4167595d96b6caf19871584b07f255a4d80037b122c9f1f71acb1366a1ae
        },
        NamespaceNode {
            min: node10,
            max: node60,
            digest: 0xee695202b2d3090a2319e7491483cf50e71a5907cebcf1fed4d02daa02f39827
        }
    ];
    let key: u256 = 8;
    let num_leaves: u256 = 10;
    let proof = NamespaceMerkleProof { side_nodes, key, num_leaves };
    let mut data = BytesTrait::new_empty()
    .encode_packed(0x09_u8);
    let is_valid = NamespaceMerkleTree::verify(root, proof, consts::parity_share_namespace(), data);
    assert!(is_valid, "Leaf nine of ten proof should be valid");
}

#[test]
fn verify_leaf_twelve_of_thirteen_test() {
    let node10 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000010>()
    };
    let node60 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000060>()
    };
    let root = NamespaceNode {
        min: node10,
        max: node60,
        digest: 0xcdf9d9d4b408a7bf1ec5653dcb5f8cda23a329754890b63344e706302ef70e43
    };
    let side_nodes: Array<NamespaceNode> = array![
        NamespaceNode {
            min: consts::parity_share_namespace(),
            max: consts::parity_share_namespace(),
            digest: 0x311733a16ba3f14dca59dcd88e6b64276613cac5a9e20a4b228c520722851b3a
        },
        NamespaceNode {
            min: consts::parity_share_namespace(),
            max: consts::parity_share_namespace(),
            digest: 0x8137f8ca69ccd4d39d47836ace7aa22b010222eaa904e67a6ff9bf05542f7124
        },
        NamespaceNode {
            min: consts::parity_share_namespace(),
            max: consts::parity_share_namespace(),
            digest: 0x3666000822ff8e0e5bf01c170264fe39dc38d887a5ec5e87b4f72b328a323ec5
        },
        NamespaceNode {
            min: node10,
            max: node60,
            digest: 0xee695202b2d3090a2319e7491483cf50e71a5907cebcf1fed4d02daa02f39827
        }
    ];
    let key: u256 = 11;
    let num_leaves: u256 = 13;
    let proof = NamespaceMerkleProof { side_nodes, key, num_leaves };
    let mut data = BytesTrait::new_empty()
    .encode_packed(0x0c_u8);
    let is_valid = NamespaceMerkleTree::verify(root, proof, consts::parity_share_namespace(), data);
    assert!(is_valid, "Leaf twelve of thirteen proof should be valid");
}

#[test]
fn verify_leaf_thirteen_of_thirteen_test() {
    let node10 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000010>()
    };
    let node60 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000060>()
    };
    let root = NamespaceNode {
        min: node10,
        max: node60,
        digest: 0xcdf9d9d4b408a7bf1ec5653dcb5f8cda23a329754890b63344e706302ef70e43
    };
    let side_nodes: Array<NamespaceNode> = array![
        NamespaceNode {
            min: consts::parity_share_namespace(),
            max: consts::parity_share_namespace(),
            digest: 0x31501dc8a114b0aa3cde0f4f99f0643760b3b11303ab1ee568538f3e5769fbfe
        },
        NamespaceNode {
            min: node10,
            max: node60,
            digest: 0xee695202b2d3090a2319e7491483cf50e71a5907cebcf1fed4d02daa02f39827
        }
    ];
    let key: u256 = 12;
    let num_leaves: u256 = 13;
    let proof = NamespaceMerkleProof { side_nodes, key, num_leaves };
    let mut data = BytesTrait::new_empty()
    .encode_packed(0x0d_u8);
    let is_valid = NamespaceMerkleTree::verify(root, proof, consts::parity_share_namespace(), data);
    assert!(is_valid, "Leaf thirteen of thirteen proof should be valid");
}

#[test]
fn verify_internal_node_one_and_two_of_four_test() {
    let node10 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000010>()
    };
    let node20 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000010>()
    };
    let node30 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000010>()
    };
    let node40 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000010>()
    };
    let key: u256 = 1;
    let num_leaves: u256 = 4;
    let starting_height: u256 = 2;
    let mut data = BytesTrait::new_empty()
    .encode_packed(0x01_u8);

    let node1 = hasher::leaf_digest(node10, @data);
    let node2 = hasher::leaf_digest(node20, @data);
    let node3 = hasher::leaf_digest(node30, @data);
    let node4 = hasher::leaf_digest(node40, @data);

    let node1_2 = hasher::node_digest(node1, node2);
    let node3_4 = hasher::node_digest(node3, node4);
    let root = hasher::node_digest(node1_2, node3_4);
    let starting_node = node1_2;

    let side_nodes: Array<NamespaceNode> = array![node3_4];
    let proof = NamespaceMerkleProof { side_nodes, key, num_leaves };
    let is_valid = NamespaceMerkleTree::verify_inner(root, proof, starting_node, starting_height);
    assert!(is_valid, "Internal node one and two of four proof should be valid");
}

#[test]
fn verify_internal_node_one_and_two_of_three_test() {
    let node10 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000010>()
    };
    let node20 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000010>()
    };
    let node30 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000010>()
    };
    let key: u256 = 0;
    let num_leaves: u256 = 3;
    let starting_height: u256 = 2;
    let mut data = BytesTrait::new_empty()
    .encode_packed(0x01_u8);

    let node1 = hasher::leaf_digest(node10, @data);
    let node2 = hasher::leaf_digest(node20, @data);
    let node3 = hasher::leaf_digest(node30, @data);

    let node1_2 = hasher::node_digest(node1, node2);
    let root = hasher::node_digest(node1_2, node3);
    let starting_node = node1_2;

    let side_nodes: Array<NamespaceNode> = array![node3];
    let proof = NamespaceMerkleProof { side_nodes, key, num_leaves };
    let is_valid = NamespaceMerkleTree::verify_inner(root, proof, starting_node, starting_height);
    assert!(is_valid, "Internal node one and two of three proof should be valid");
}

#[test]
fn verify_inner_leaf_is_root_test() {
    let nid: Namespace = Default::default();
    let root = NamespaceNode {
        min: nid,
        max: nid,
        digest: 0xc59fa9c4ec515726c2b342544433f844c7b930cf7a5e7abab593332453ceaf70
    };
    let key: u256 = 0;
    let num_leaves: u256 = 1;
    let proof = NamespaceMerkleProof { side_nodes: array![], key, num_leaves };
    let node = NamespaceNode {
        min: nid,
        max: nid,
        digest: 0xc59fa9c4ec515726c2b342544433f844c7b930cf7a5e7abab593332453ceaf70
    };
    let starting_height: u256 = 1;
    let is_valid = NamespaceMerkleTree::verify_inner(root, proof, node, starting_height);
    assert!(is_valid, "Inner leaf is root proof should be valid");
}

#[test]
fn verify_inner_false_for_starting_height_zero_test() {
    let node20 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000020>()
    };
    let root = NamespaceNode {
        min: node20,
        max: node20,
        digest: 0xc59fa9c4ec515726c2b342544433f844c7b930cf7a5e7abab593332453ceaf70
    };
    let key: u256 = 0;
    let num_leaves: u256 = 1;
    let proof = NamespaceMerkleProof { side_nodes: array![], key, num_leaves };
    let node = NamespaceNode {
        min: node20,
        max: node20,
        digest: 0xc59fa9c4ec515726c2b342544433f844c7b930cf7a5e7abab593332453ceaf70
    };
    let starting_height: u256 = 0;
    let is_valid = NamespaceMerkleTree::verify_inner(root, proof, node, starting_height);
    assert!(!is_valid, "Inner false for starting height zero proof should be invalid");
}

#[test]
fn verify_inner_false_for_too_large_key_test() {
    let node20 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000020>()
    };
    let root = NamespaceNode {
        min: node20,
        max: node20,
        digest: 0xc59fa9c4ec515726c2b342544433f844c7b930cf7a5e7abab593332453ceaf70
    };
    let key: u256 = 3; // key is larger than num_leaves
    let num_leaves: u256 = 1;
    let proof = NamespaceMerkleProof { side_nodes: array![], key, num_leaves };
    let node = NamespaceNode {
        min: node20,
        max: node20,
        digest: 0xc59fa9c4ec515726c2b342544433f844c7b930cf7a5e7abab593332453ceaf70
    };
    let starting_height: u256 = 1;
    let is_valid = NamespaceMerkleTree::verify_inner(root, proof, node, starting_height);
    assert!(!is_valid, "Inner false for too large key proof should be invalid");
}

#[test]
fn verify_inner_false_for_incorrect_proof_length() {
    let node20 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000020>()
    };
    let root = NamespaceNode {
        min: node20,
        max: node20,
        digest: 0xc59fa9c4ec515726c2b342544433f844c7b930cf7a5e7abab593332453ceaf70
    };
    let side_nodes: Array<NamespaceNode> = array![
        NamespaceNode {
            min: consts::parity_share_namespace(),
            max: consts::parity_share_namespace(),
            digest: 0x24ddc56b10cebbf760b3a744ad3a0e91093db34b4d22995f6de6dac918e38ae5
        }
    ];
    let key: u256 = 0;
    let num_leaves: u256 = 1;
    let proof = NamespaceMerkleProof { side_nodes, key, num_leaves };
    let node = NamespaceNode {
        min: node20,
        max: node20,
        digest: 0xc59fa9c4ec515726c2b342544433f844c7b930cf7a5e7abab593332453ceaf70
    };
    let starting_height: u256 = 1;
    let is_valid = NamespaceMerkleTree::verify_inner(root, proof, node, starting_height);
    assert!(!is_valid, "Inner false for incorrect proof length proof should be invalid");
}

#[test]
fn verify_inner_one_of_eight_test() {
    let node10 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000010>()
    };
    let node20 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000020>()
    };
    let node30 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000030>()
    };
    let node40 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000040>()
    };
    let root = NamespaceNode {
        min: node10,
        max: node40,
        digest: 0x34e6541306dc4e57a5a2a9ef57a46d5705ed09efb8c6a02580d3a972922b6862
    };
    let side_nodes: Array<NamespaceNode> = array![
        NamespaceNode {
            min: node30,
            max: node40,
            digest: 0x2aa20c7587b009772a9a88402b7cc8fcb82edc9e31754e95544a670a696f55a7
        },
        NamespaceNode {
            min: consts::parity_share_namespace(),
            max: consts::parity_share_namespace(),
            digest: 0x5aa3e7ea31995fdd38f41015275229b290a8ee4810521db766ad457b9a8373d6
        }
    ];
    let node = NamespaceNode {
        min: node10,
        max: node20,
        digest: 0x1dae5c3d39a8bf31ea33ba368238a52f816cd50485c580565609554cf360c91f
    };
    let key: u256 = 0;
    let num_leaves: u256 = 8;
    let proof = NamespaceMerkleProof { side_nodes, key, num_leaves };
    let is_valid = NamespaceMerkleTree::verify_inner(root, proof, node, 2);
    assert!(is_valid, "Inner one of eight proof should be valid");
}

#[test]
fn verify_inner_seven_of_eight_test() {
    let node10 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000010>()
    };
    let node40 = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000040>()
    };
    let root = NamespaceNode {
        min: node10,
        max: node40,
        digest: 0x34e6541306dc4e57a5a2a9ef57a46d5705ed09efb8c6a02580d3a972922b6862
    };
    let side_nodes: Array<NamespaceNode> = array![
        NamespaceNode {
            min: consts::parity_share_namespace(),
            max: consts::parity_share_namespace(),
            digest: 0x055a3ea75c438d752aeabbba94ed8fac93e0b32321256a65fde176dba14f5186
        },
        NamespaceNode {
            min: node10,
            max: node40,
            digest: 0xa8dcd9f365fb64aa6d72b5027fe74db0fc7d009c2d75c7b9b9656927281cb35e
        }
    ];
    let node = NamespaceNode {
        min: consts::parity_share_namespace(),
        max: consts::parity_share_namespace(),
        digest: 0x1b79ffd74644e8c287fe5f1dd70bc8ea02738697cebf2810ffb2dc5157485c40
    };
    let key: u256 = 6;
    let num_leaves: u256 = 8;
    let proof = NamespaceMerkleProof { side_nodes, key, num_leaves };
    let is_valid = NamespaceMerkleTree::verify_inner(root, proof, node, 2);
    assert!(is_valid, "Inner seven of eight proof should be valid");
}
