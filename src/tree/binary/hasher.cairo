use alexandria_bytes::BytesTrait;
use blobstream_sn::tree::consts::{LEAF_PREFIX, NODE_PREFIX};
use blobstream_sn::utils::encode_packed;

fn nodeDigest(left: u256, right: u256) -> u256 {
    let mut bytes = BytesTrait::new(1, array![NODE_PREFIX]);
    bytes.append_u256(left);
    bytes.append_u256(right);
    bytes.sha256()
}

fn leafDigest(data: u256) -> u256 {
    let mut bytes = BytesTrait::new(1, array![LEAF_PREFIX]);
    if data > 0 {
        bytes.append_u256(data);
    }
    bytes.sha256()
}
