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
    id: bytes31,
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
mod NamespaceMerkleTree {
    use alexandria_bytes::BytesTrait;
    use alexandria_bytes::bytes::Bytes;
    use alexandria_math::U256BitShift;
    use alexandria_math::{pow, BitShift};
    use blobstream_sn::tree::namespace::hasher::{leaf_digest, node_digest};
    use blobstream_sn::tree::utils::{path_length_from_key, get_split_point};
    use super::namespace_node_eq;
    use super::{Namespace, NamespaceNode, NamespaceMerkleMultiproof, NamespaceMerkleProof};
    fn verify(
        root: NamespaceNode,
        proof: NamespaceMerkleProof,
        namespace: Namespace,
        data: alexandria_bytes::bytes::Bytes
    ) -> bool {
        // let node: NamespaceNode = leaf_digest(namespace, data);

        // return ()
        true
    }
    // fn verify_inner(
    //     root: NamespaceNode,
    //     proof: NamespaceMerkleProof,
    //     mut node: NamespaceNode,
    //     starting_height: u256
    // ) -> bool {
    //     if (starting_height < 1) {
    //         return false;
    //     }
    //     let height_offset: u256 = starting_height - 1;

    //     if (proof.num_leaves <= 1) {
    //         if (proof.side_nodes.len() != 0) {
    //             return false;
    //         }
    //     } else if (proof.side_nodes.len().into()
    //         + height_offset != path_length_from_key(proof.key, proof.num_leaves)) {
    //         return false;
    //     }

    //     if (proof.key >= proof.num_leaves) {
    //         return false;
    //     }

    //     if (proof.side_nodes.len() == 0) {
    //         if (proof.num_leaves == 1) {
    //             return namespace_node_eq(root, node);
    //         } else {
    //             return false;
    //         }
    //     }

    //     let mut height: u256 = starting_height;
    //     let mut stable_end: u256 = proof.key;

    //     loop {
    //         let sub_tree_start_index: u256 = (proof.key / (U256BitShift::shl(1, height)))
    //             * (U256BitShift::shl(1, height));
    //         let sub_tree_end_index: u256 = sub_tree_start_index
    //             + (U256BitShift::shl(1, height))
    //             - 1;

    //         if (sub_tree_end_index >= proof.num_leaves) {
    //             break;
    //         }

    //         stable_end = sub_tree_end_index;

    //         if (proof.side_nodes.len().into() + height_offset <= height - 1) {
    //             break;
    //         }

    //         if (proof.key - sub_tree_start_index < (U256BitShift::shl(1, (height - 1)))) {
    //             node = node_digest(node, proof.side_nodes[height - height_offset - 1]);
    //         } else {
    //             node = node_digest(proof.side_nodes[height - height_offset - 1], node);
    //         }

    //         height += 1;
    //     };

    //     if (stable_end != proof.num_leaves - 1) {
    //         if (proof.side_nodes.len().into() <= height - height_offset - 1) {
    //             return false;
    //         }

    //         node = node_digest(node, proof.side_nodes[height - height_offset - 1]);
    //     }

    //     loop {
    //         if (height - height_offset - 1 < proof.side_nodes.len().into()) {
    //             break;
    //         }
    //         node = node_digest(node, proof.side_nodes[height - height_offset - 1]);
    //         height += 1;
    //     };

    //     return namespace_node_eq(root, node);
    // }
    fn verify_multi(
        root: NamespaceNode,
        proof: NamespaceMerkleMultiproof,
        namespace: Namespace,
        data: Array<Bytes>
    ) -> bool {
        let mut nodes: Array<NamespaceNode> = ArrayTrait::new();
        let mut i = 0;
        loop {
            if (i == data.len()) {
                break;
            }
            nodes.append(leaf_digest(namespace, data.at(i)));
            i += 1;
        };

        // return verify_multi_hashes(root, proof, nodes);
        false
    }


    fn pop_proof_if_non_empty(
        nodes: Array<NamespaceNode>, head: u256, end: u256, head_leaves: u256
    ) -> (NamespaceNode, u256, bool) {
        let empty_bytes_31: bytes31 = 0_u8.into();
        let empty: Namespace = Namespace { version: 0, id: empty_bytes_31 };

        let empty_namespace_node: NamespaceNode = NamespaceNode {
            min: empty, max: empty, digest: 0_u8.into()
        };
        if (nodes.len() == 0 || head >= end || head >= head_leaves) {
            return (empty_namespace_node, head, true);
        }

        // return (*nodes.at(head.into()), head + 1, false);
        return (empty_namespace_node, 0_u256, false);
    }

    fn pop_if_non_empty(
        nodes: Array<NamespaceNode>, head: u256, end: u256
    ) -> (NamespaceNode, u256, bool) {
        let empty_bytes_31: bytes31 = 0_u8.into();
        let empty: Namespace = Namespace { version: 0, id: empty_bytes_31 };

        let empty_namespace_node: NamespaceNode = NamespaceNode {
            min: empty, max: empty, digest: 0_u8.into()
        };
        if (nodes.len() == 0 || head >= end || head >= nodes.len().into()) {
            return (empty_namespace_node, head, true);
        }

        // let mut head_u32: u32 = head.into();

        // return (*nodes.at(head_u32), head + 1, false);
        return (empty_namespace_node, 0_u256, false);
    }
}

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
// for (uint256 height = initialHeight; height < maxHeight; height++) {
//     uint256 subTreeStartIndex = (proof.key / (1 << height)) * (1 << height);
//     uint256 subTreeEndIndex = subTreeStartIndex + (1 << height) - 1;

//     if (subTreeEndIndex >= proof.numLeaves) {
//         // This breaks the loop when a complete subtree is not found.
//         break;
//     }
//     stableEnd = subTreeEndIndex;

//     if (proof.sideNodes.length + heightOffset <= height - 1) {
//         return false;
//     }
//     if (proof.key - subTreeStartIndex < (1 << (height - 1))) {
//         node = nodeDigest(node, proof.sideNodes[height - heightOffset - 1]);
//     } else {
//         node = nodeDigest(proof.sideNodes[height - heightOffset - 1], node);
//     }

//     // The original loop incremented height at the end, so we let the for loop's incrementation handle this.
// }


