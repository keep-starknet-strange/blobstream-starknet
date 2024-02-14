use alexandria_bytes::Bytes;
use alexandria_bytes::BytesTrait;
use blobstream_sn::tree::namespace::merkle_tree::{
    Namespace, NamespaceNode, NamespaceMerkleMultiproof, NamespaceMerkleProof
};
use alexandria_math::U256BitShift;
use debug::PrintTrait;
use blobstream_sn::tree::consts::{LEAF_PREFIX, NODE_PREFIX, parity_share_namespace};

fn leaf_digest(namespace: Namespace, data: @Bytes) -> NamespaceNode {
    // let mut bytes = BytesTrait::new(1, array![LEAF_PREFIX]);
    let mut bytes = BytesTrait::new_empty();
    bytes.append_u8(LEAF_PREFIX);
    // let mut bytes2 = BytesTrait::new_empty();
    bytes.append_u8(namespace.version);
    append_bytes31(ref bytes, namespace.id);
    // bytes.concat(@bytes2);
    bytes.concat(data);
    let val = bytes.sha256();
    val.print();
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

impl bytes31PrintImpl of PrintTrait<bytes31> {
    fn print(self: bytes31) {
        Into::<_, felt252>::into(self).print();
    }
}

fn print_byte_array_as_string(self: @Bytes) {
    let mut serialized = array![];
    self.serialize(ref serialized);
    serialized.print();
}
fn node_digest(left: NamespaceNode, right: NamespaceNode) -> NamespaceNode {
    let mut min: Namespace = namespace_min(left.min, right.min);
    let mut max: Namespace = namespace_max(left.max, right.max);
    if (left.min == parity_share_namespace()) {
        max = parity_share_namespace();
    } else if (right.min == parity_share_namespace()) {
        max = left.max;
    } else {
        max = namespace_max(left.max, right.max);
    }

    let mut bytes = BytesTrait::new_empty();
    bytes.append_u8(NODE_PREFIX);
    bytes.append_u8(left.min.version);
    append_bytes31(ref bytes, left.min.id);
    bytes.append_u8(left.max.version);
    append_bytes31(ref bytes, left.max.id);
    bytes.append_u256(left.digest);
    bytes.append_u8(right.min.version);
    append_bytes31(ref bytes, right.min.id);
    bytes.append_u8(right.max.version);
    append_bytes31(ref bytes, right.max.id);
    bytes.append_u256(right.digest);

    return NamespaceNode { min: min, max: max, digest: bytes.sha256() };
}

fn append_bytes31(ref self: Bytes, value: bytes31) {
    let mut value_u256: u256 = value.into();
    value_u256 = U256BitShift::shl(value_u256, 32);
    let mut bytes28Bytes: Bytes = BytesTrait::new(28, array![value_u256.high, value_u256.low]);
    self.concat(@bytes28Bytes);
}

