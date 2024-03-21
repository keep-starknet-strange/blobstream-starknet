use alexandria_bytes::{Bytes, BytesTrait};
use alexandria_encoding::sol_abi::{SolAbiEncodeTrait};
use blobstream_sn::tree::consts::{LEAF_PREFIX, NODE_PREFIX};

fn node_digest(left: u256, right: u256) -> u256 {
    let bytes = BytesTrait::new_empty()
        .encode_packed(NODE_PREFIX)
        .encode_packed(left)
        .encode_packed(right);
    bytes.sha256()
}

fn leaf_digest(data: @Bytes) -> u256 {
    let mut bytes = BytesTrait::new_empty().encode_packed(LEAF_PREFIX);
    bytes.concat(data);
    bytes.sha256()
}
