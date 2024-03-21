use alexandria_bytes::{Bytes, BytesTrait};
use alexandria_encoding::sol_abi::{SolBytesTrait, SolAbiEncodeTrait};
use alexandria_math::U256BitShift;
use blobstream_sn::tree::consts::{LEAF_PREFIX, NODE_PREFIX, parity_share_namespace};
use blobstream_sn::tree::namespace::Namespace;
use blobstream_sn::tree::namespace::merkle_tree::{
    NamespaceNode, NamespaceMerkleMultiproof, NamespaceMerkleProof
};

fn leaf_digest(namespace: Namespace, data: @Bytes) -> NamespaceNode {
    let mut bytes = BytesTrait::new_empty()
        .encode_packed(LEAF_PREFIX)
        .encode_packed(namespace.version)
        .encode_packed(SolBytesTrait::bytes28(namespace.id));
    bytes.concat(data);
    return NamespaceNode { min: namespace, max: namespace, digest: bytes.sha256() };
}

fn namespace_min(l: Namespace, r: Namespace) -> Namespace {
    if l < r {
        return l;
    }
    return r;
}

fn namespace_max(l: Namespace, r: Namespace) -> Namespace {
    if l > r {
        return l;
    }
    return r;
}

fn node_digest(left: NamespaceNode, right: NamespaceNode) -> NamespaceNode {
    let mut min: Namespace = namespace_min(left.min, right.min);
    let mut max: Namespace = namespace_max(left.max, right.max);
    if (left.min == parity_share_namespace()) {
        max = parity_share_namespace();
    } else if (right.min == parity_share_namespace()) {
        max = left.max;
    }

    let bytes = BytesTrait::new_empty()
        .encode_packed(NODE_PREFIX)
        .encode_packed(left.min.version)
        .encode_packed(SolBytesTrait::bytes28(left.min.id))
        .encode_packed(left.max.version)
        .encode_packed(SolBytesTrait::bytes28(left.max.id))
        .encode_packed(left.digest)
        .encode_packed(right.min.version)
        .encode_packed(SolBytesTrait::bytes28(right.min.id))
        .encode_packed(right.max.version)
        .encode_packed(SolBytesTrait::bytes28(right.max.id))
        .encode_packed(right.digest);

    return NamespaceNode { min: min, max: max, digest: bytes.sha256() };
}

fn append_bytes28(ref self: Bytes, value: bytes31) {
    let mut value_u256: u256 = value.into();
    value_u256 = U256BitShift::shl(value_u256, 32);
    let mut bytes28Bytes: Bytes = BytesTrait::new(28, array![value_u256.high, value_u256.low]);
    self.concat(@bytes28Bytes);
}
