use alexandria_bytes::Bytes;
use alexandria_bytes::BytesTrait;
use blobstream_sn::tree::consts::{LEAF_PREFIX, NODE_PREFIX};

fn nodeDigest(left: u256, right: u256) -> u256 {
    let mut bytes = BytesTrait::new_empty();
    bytes.append_u8(NODE_PREFIX);
    bytes.append_u256(left);
    bytes.append_u256(right);
    bytes.sha256()
}

fn leafDigest(data: @Bytes) -> u256 {
    let mut bytes = BytesTrait::new_empty();
    bytes.append_u8(LEAF_PREFIX);
    bytes.concat(data);
    bytes.sha256()
}
