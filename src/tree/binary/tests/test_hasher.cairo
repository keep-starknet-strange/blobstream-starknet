use alexandria_bytes::BytesTrait;
use blobstream_sn::tree::binary::hasher::{leafDigest, nodeDigest};

#[test]
fn leaf_digest_empty_test() {
    let exp: u256 = 0x6e340b9cffb37a989ca544e6bb780a2c78901d3fb33738768511a30617afa01d;
    let data = BytesTrait::new_empty();
    let digest = leafDigest(@data);
    assert_eq!(digest, exp, "empty leaf digest");
}

#[test]
fn leaf_digest_test() {
    let exp: u256 = 0x48c90c8ae24688d6bef5d48a30c2cc8b6754335a8db21793cc0a8e3bed321729;
    let mut data = BytesTrait::new_empty();
    data.append_u32(0xdeadbeef);
    let digest = leafDigest(@data);
    assert_eq!(digest, exp, "leaf digest");
}

#[test]
fn node_digest_empty_test() {
    let exp: u256 = 0xfe43d66afa4a9a5c4f9c9da89f4ffb52635c8f342e7ffb731d68e36c5982072a;
    let left: u256 = 0x6e340b9cffb37a989ca544e6bb780a2c78901d3fb33738768511a30617afa01d;
    let right: u256 = 0x6e340b9cffb37a989ca544e6bb780a2c78901d3fb33738768511a30617afa01d;
    let digest = nodeDigest(left, right);
    assert_eq!(digest, exp, "empty node digest");
}

#[test]
fn node_digest_children_test() {
    let exp: u256 = 0x62343bba7c4d6259f0d4863cdf476f1c0ac1b9fbe9244723a9b8b5c8aae72c38;
    let left: u256 = 0xdb55da3fc3098e9c42311c6013304ff36b19ef73d12ea932054b5ad51df4f49d;
    let right: u256 = 0xc75cb66ae28d8ebc6eded002c28a8ba0d06d3a78c6b5cbf9b2ade051f0775ac4;
    let digest = nodeDigest(left, right);
    assert_eq!(digest, exp, "node digest");
}
