// // Celestia-app namespace ID and its version
// // See: https://celestiaorg.github.io/celestia-app/specs/namespace.html
#[derive(Serde, Drop, Copy, PartialEq)]
struct NamespaceNode {
    min: Namespace,
    max: Namespace,
    // Node value.
    digest: u256,
}

#[derive(Serde, Drop, Copy)]
struct Namespace {
    version: u8,
    id: bytes31, //TODO: #28
}

#[derive(Drop, PartialEq, PartialOrd)]
struct NamespaceMerkleMultiproof {
    begin_key: u256,
    end_key: u256,
    side_nodes: Array<NamespaceNode>,
}

#[derive(Drop, PartialEq, PartialOrd)]
struct NamespaceMerkleProof {
    side_nodes: Array<NamespaceNode>,
    key: u256,
    num_leaves: u256,
}
// mod NamespaceMerkleTree {
//     use super::{Namespace, NamespaceNode, NamespaceMerkleMultiproof, NamespaceMerkleProof};
//     use alexandria_bytes::BytesTrait;
//     use blobstream_sn::tree::binary::hasher::leafDigest;

//     fn verify(
//         root: NamespaceNode,
//         proof: NamespaceMerkleProof,
//         namespace: Namespace,
//         data: alexandria_bytes::bytes::Bytes
//     ) -> bool {

//         node : NamespaceNode = leafDigest(namespace, data);
//         true
//     }
// }
// // TODO: #28
impl NamespacePartialOrd of PartialOrd<Namespace> {
    #[inline(always)]
    fn le(lhs: Namespace, rhs: Namespace) -> bool {
        let lhs_id: u256 = lhs.id.into();
        let rhs_id: u256 = rhs.id.into();
        if (lhs_id <= rhs_id && lhs.version <= rhs.version) {
            return true;
        } else {
            return false;
        }
    }
    #[inline(always)]
    fn ge(lhs: Namespace, rhs: Namespace) -> bool {
        let lhs_id: u256 = lhs.id.into();
        let rhs_id: u256 = rhs.id.into();
        if (lhs_id >= rhs_id && lhs.version >= rhs.version) {
            return true;
        } else {
            return false;
        }
    }
    #[inline(always)]
    fn lt(lhs: Namespace, rhs: Namespace) -> bool {
        let lhs_id: u256 = lhs.id.into();
        let rhs_id: u256 = rhs.id.into();
        if (lhs_id < rhs_id && lhs.version < rhs.version) {
            return true;
        } else {
            return false;
        }
    }
    #[inline(always)]
    fn gt(lhs: Namespace, rhs: Namespace) -> bool {
        let lhs_id: u256 = lhs.id.into();
        let rhs_id: u256 = rhs.id.into();
        if (lhs_id > rhs_id && lhs.version > rhs.version) {
            return true;
        } else {
            return false;
        }
    }
}
impl NamespacePartialEq of PartialEq<Namespace> {
    #[inline(always)]
    fn eq(lhs: @Namespace, rhs: @Namespace) -> bool {
        let lhs_id: u256 = (*lhs.id).into();
        let rhs_id: u256 = (*rhs.id).into();
        if ((lhs_id == rhs_id) && (lhs.version == rhs.version)) {
            return true;
        } else {
            return false;
        }
    }
    #[inline(always)]
    fn ne(lhs: @Namespace, rhs: @Namespace) -> bool {
        let lhs_id: u256 = (*lhs.id).into();
        let rhs_id: u256 = (*rhs.id).into();
        if (lhs_id != rhs_id && lhs.version != rhs.version) {
            return true;
        } else {
            return false;
        }
    }
}


fn namespace_node_eq(first: NamespaceNode, second: NamespaceNode) -> bool {
    return first.min == second.min && first.max == second.max && (first.digest == second.digest);
}

