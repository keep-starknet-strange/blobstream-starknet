use blobstream::tree::consts::{LEAF_PREFIX, MAX_HEIGHT, NODE_PREFIX, parity_share_namespace};
use core::bytes_31::bytes31_const;

#[test]
fn constants_test() {
    assert!(LEAF_PREFIX == 0x00, "leaf prefix");
    assert!(MAX_HEIGHT == 256, "max height");
    assert!(NODE_PREFIX == 0x01, "node prefix");
}

#[test]
fn parity_share_namespace_test() {
    let parity_id = bytes31_const::<0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF>();
    let result = parity_share_namespace();
    assert!(result.version == 0xFF, "parity namespace version");
    assert!(result.id == parity_id, "parity namespace id");
}
