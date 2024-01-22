use blobstream::tree::consts::{LEAF_PREFIX, MAX_HEIGHT, NODE_PREFIX};

#[test]
fn constants_test() {
    assert!(LEAF_PREFIX == 0x00, "incorrect leaf prefix");
    assert!(MAX_HEIGHT == 256, "incorrect max height");
    assert!(NODE_PREFIX == 0x01,"incorrect node prefix");
}
