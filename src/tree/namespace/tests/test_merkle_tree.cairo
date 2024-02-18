use blobstream_sn::tree::namespace::merkle_tree::{NamespaceNode, Namespace, NamespaceMerkleProof};
use blobstream_sn::tree::namespace::merkle_tree::NamespaceMerkleTree::verify;
use alexandria_bytes::BytesTrait;
use debug::PrintTrait;

#[test]
fn testing_partial_ord_and_eq() {
    let b17 = bytes31_const::<0x0102030405060708090a0b0c0d0e0f1011>();
    assert(b17.at(0) > b17.at(1), 'Invalid assertion');
    assert(b17.at(14) == 0x03, 'Invalid assertion');
    assert(b17.at(15) != 0x01, 'Invalid assertion');

    let b31 = bytes31_const::<0x0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f>();
    assert(b31.at(0) > b31.at(1), 'Invalid assertion');
    assert(b31.at(1) < b31.at(0), 'Invalid assertion');
    assert(b31.at(14) >= 0x03, 'Invalid assertion');
    assert(b31.at(17) <= 0x11, 'Invalid assertion');
}
#[test]
fn test_verify_none() {
    let nid: Namespace = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000000>(),
    };

    let root: NamespaceNode = NamespaceNode {
        min: nid, max: nid, digest: BytesTrait::new_empty().sha256()
    };

    let side_nodes: Array<NamespaceNode> = array![];
    let key: u256 = 0;
    let num_leaves: u256 = 0;
    let proof: NamespaceMerkleProof = NamespaceMerkleProof {
        side_nodes: side_nodes, key: key, num_leaves: num_leaves,
    };

    let data = BytesTrait::new_empty();
    let is_valid = verify(root, proof, nid, data);
    is_valid.print();

    assert!(is_valid == true, "Invalid")
}

