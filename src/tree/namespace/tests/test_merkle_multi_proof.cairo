/// Implement tests from https://github.com/celestiaorg/blobstream-contracts/blob/master/src/lib/tree/namespace/test/NamespaceMerkleMultiproof.t.sol

use alexandria_bytes::{Bytes, BytesTrait};
use alexandria_encoding::sol_abi::{SolAbiEncodeTrait};
use blobstream_sn::tree::consts;
use blobstream_sn::tree::namespace::Namespace;
use blobstream_sn::tree::namespace::merkle_tree::{
    NamespaceNode, NamespaceMerkleTree, NamespaceMerkleMultiproof
};

#[test]
fn verify_multi_01() {
    let nid = Namespace {
        version: 0x00,
        id: bytes31_const::<0x00000000000000000000000000000000000000000000000000000010>()
    };
    let root = NamespaceNode {
        min: nid,
        max: nid,
        digest: 0x5b3328b03a538d627db78668034089cb395f63d05b24fdf99558d36fe991d268
    };
    let side_nodes = array![
        NamespaceNode {
            min: nid,
            max: nid,
            digest: 0xfdb4e3c872666aa9869a1d46c8a5a0e735becdf17c62b9c3ccf4258449475bda
        },
        NamespaceNode {
            min: nid,
            max: nid,
            digest: 0xc350aeddd5ada629057034f15d4545065213a7a28f9f9b77bdc71c4225145920
        },
        NamespaceNode {
            min: consts::parity_share_namespace(),
            max: consts::parity_share_namespace(),
            digest: 0x5aa3e7ea31995fdd38f41015275229b290a8ee4810521db766ad457b9a8373d6
        }
    ];

    let begin_key: u256 = 1;
    let end_key: u256 = 3;
    let proof = NamespaceMerkleMultiproof { begin_key, end_key, side_nodes };
    let data_val1: Bytes = BytesTrait::new_empty().encode_packed(0x02_u8);
    let data_val2: Bytes = BytesTrait::new_empty().encode_packed(0x03_u8);
    let data: Array<Bytes> = array![data_val1, data_val2];
    let is_valid = NamespaceMerkleTree::verify_multi(root, proof, nid, data);
    assert!(is_valid, "verify_multi_01 failed");
}
