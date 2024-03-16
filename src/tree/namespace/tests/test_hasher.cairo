use alexandria_bytes::BytesTrait;
use blobstream_sn::tree::consts::{parity_share_namespace};
use blobstream_sn::tree::namespace::hasher;
use blobstream_sn::tree::namespace::merkle_tree::{Namespace, NamespaceNode, namespace_node_eq};
use core::option::OptionTrait;
use core::traits::Into;

#[test]
fn leaf_digest_empty_test() {
    let bytesval: bytes31 = bytes31_const::<
        0x00000000000000000000000000000000000000000000000000000000
    >();

    let nid: Namespace = Namespace { version: 0x00, id: bytesval };

    let expected: NamespaceNode = NamespaceNode {
        min: nid,
        max: nid,
        digest: 0x0679246d6c4216de0daa08e5523fb2674db2b6599c3b72ff946b488a15290b62
    };

    let data = BytesTrait::new_empty();

    let node: NamespaceNode = hasher::leaf_digest(nid, @data);

    let res = namespace_node_eq(node, expected);
    assert!(res, "Not equal to expected digest");
}

#[test]
fn test_leaf_digest_some() {
    let bytesval: bytes31 = bytes31_const::<
        0xadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefde
    >();
    let nid = Namespace { version: 0xde, id: bytesval, };

    let expected = NamespaceNode {
        min: nid,
        max: nid,
        digest: 0x3624c7f7169cb5bbd0d010b851ebd0edca10b2a1b126f5fb1a6d5e0d98356e63
    };

    let mut data = BytesTrait::new_empty();
    data.append_u8(0x69);

    let node = hasher::leaf_digest(nid, @data);
    assert!(node.digest == expected.digest, "Not equal to expected digest");
}

#[test]
fn test_node_digest() {
    let nid_left = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000000>()
    };
    let nid_right = Namespace {
        version: 0xde,
        id: bytes31_const::<0xadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefde>()
    };
    let expected = NamespaceNode {
        min: nid_left,
        max: nid_right,
        digest: 0x95cad48bc181484c851004cf772abe767391e19549d3b8192b55b1d654a71bcd
    };
    let left = NamespaceNode {
        min: nid_left,
        max: nid_left,
        digest: 0xdb55da3fc3098e9c42311c6013304ff36b19ef73d12ea932054b5ad51df4f49d
    };

    let right = NamespaceNode {
        min: nid_right,
        max: nid_right,
        digest: 0xc75cb66ae28d8ebc6eded002c28a8ba0d06d3a78c6b5cbf9b2ade051f0775ac4
    };
    let node = hasher::node_digest(left, right);
    let res = namespace_node_eq(node, expected);
    assert!(res, "Not equal to expected digest");
}

#[test]
fn test_node_parity() {
    let nid_min = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000000>()
    };
    let nid_max = Namespace {
        version: 0xde,
        id: bytes31_const::<0xadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefde>()
    };
    let expected = NamespaceNode {
        min: nid_min,
        max: nid_max,
        digest: 0xc6960f535d4ab0aed075aed34a116725e8035012ceffe5405ae72abe3bcaa28f
    };

    let left = NamespaceNode {
        min: nid_min,
        max: nid_max,
        digest: 0xdb55da3fc3098e9c42311c6013304ff36b19ef73d12ea932054b5ad51df4f49d
    };

    let right = NamespaceNode {
        min: parity_share_namespace(),
        max: parity_share_namespace(),
        digest: 0xc75cb66ae28d8ebc6eded002c28a8ba0d06d3a78c6b5cbf9b2ade051f0775ac4
    };

    let node = hasher::node_digest(left, right);
    let res = namespace_node_eq(node, expected);
    assert!(res, "Not equal to expected digest");
}
