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
    use super::{Namespace, NamespaceNode, NamespaceMerkleMultiproof, NamespaceMerkleProof};
    use alexandria_bytes::BytesTrait;
    use blobstream_sn::tree::namespace::hasher::{leaf_digest, node_digest};
    use blobstream_sn::tree::utils::{path_length_from_key, get_split_point, bits_len};
    use super::namespace_node_eq;
    use alexandria_math::U256BitShift;
    use alexandria_bytes::Bytes;
    use clone::Clone;


    fn verify(
        root: NamespaceNode,
        proof: NamespaceMerkleProof,
        namespace: Namespace,
        data: alexandria_bytes::bytes::Bytes
    ) -> bool {
        let node: NamespaceNode = leaf_digest(namespace, @data);
        return verify_inner(root, proof, node, 1);
    }

    fn verify_inner(
        root: NamespaceNode,
        proof: NamespaceMerkleProof,
        mut node: NamespaceNode,
        starting_height: u256
    ) -> bool {
        if (starting_height < 1) {
            return false;
        }
        let height_offset: u256 = starting_height - 1;

        if (proof.num_leaves <= 1) {
            if (proof.side_nodes.len() != 0) {
                return false;
            }
        } else if (proof.side_nodes.len().into()
            + height_offset != path_length_from_key(proof.key, proof.num_leaves)) {
            return false;
        }

        if (proof.key >= proof.num_leaves) {
            return false;
        }

        if (proof.side_nodes.len() == 0) {
            if (proof.num_leaves == 1) {
                return namespace_node_eq(root, node);
            } else {
                return false;
            }
        }

        let mut height: u256 = starting_height;
        let mut stable_end: u256 = proof.key;
        let clone_side_nodes = proof.side_nodes.clone();

        loop {
            let sub_tree_start_index: u256 = (proof.key / (U256BitShift::shl(1, height)))
                * (U256BitShift::shl(1, height));
            let sub_tree_end_index: u256 = sub_tree_start_index
                + (U256BitShift::shl(1, height))
                - 1;

            if (sub_tree_end_index >= proof.num_leaves) {
                break;
            }

            stable_end = sub_tree_end_index;

            if (proof.side_nodes.len().into() + height_offset <= height - 1) {
                break;
            }
            let index: u32 = (height - height_offset - 1).try_into().unwrap();
            if (proof.key - sub_tree_start_index < (U256BitShift::shl(1, (height - 1)))) {
                node = node_digest(node, *proof.side_nodes.at(index));
            } else {
                node = node_digest(*proof.side_nodes.at(index), node);
            }

            height += 1;
        };

        if (clone_side_nodes.len().into() + height_offset <= height - 1) {
            return false;
        }

        if (stable_end != proof.num_leaves - 1) {
            if (clone_side_nodes.len().into() <= height - height_offset - 1) {
                return false;
            }

            node =
                node_digest(
                    node, *clone_side_nodes.at((height - height_offset - 1).try_into().unwrap())
                );
            height += 1;
        }

        while(height - height_offset - 1 < clone_side_nodes.len().into())
        {
            node =
                node_digest(
                    *clone_side_nodes.at((height - height_offset - 1).try_into().unwrap()), node
                );
            height += 1;
        };

        namespace_node_eq(root, node)
    }


    // fn verify_multi(
    //     root: NamespaceNode,
    //     proof: NamespaceMerkleMultiproof,
    //     namespace: Namespace,
    //     data: Array<Bytes>
    // ) -> bool {
    //     let mut nodes: Array<NamespaceNode> = ArrayTrait::new();
    //     let mut i = 0;
    //     loop {
    //         if (i == data.len()) {
    //             break;
    //         }
    //         nodes.append(leaf_digest(namespace, data.at(i)));
    //         i += 1;
    //     };

    //     return verify_multi_hashes(root, proof, nodes);
    // }

    // fn verify_multi_hashes(
    //     root: NamespaceNode, proof: NamespaceMerkleMultiproof, leaf_nodes: Array<NamespaceNode>
    // ) -> bool {
    //     let mut leaf_index: u256 = 0;
    //     let mut left_sub_trees: Array<NamespaceNode> = ArrayTrait::new();
    //     let begin_key_clone = proof.begin_key.clone();
    //     let end_key_clone = proof.end_key.clone();
    //     let side_nodes_clone = proof.side_nodes.clone();

    //     let cloned_proof: NamespaceMerkleMultiproof = NamespaceMerkleMultiproof {
    //         begin_key: begin_key_clone, end_key: end_key_clone, side_nodes: side_nodes_clone
    //     };

    //     let mut i = 0;
    //     loop {
    //         if (leaf_index == proof.begin_key && i == proof.side_nodes.len()) {
    //             break;
    //         }
    //         let sub_tree_size = next_sub_tree_size(leaf_index, proof.end_key);
    //         left_sub_trees.append(*cloned_proof.side_nodes.at(i));
    //         leaf_index += sub_tree_size;

    //         i += 1;
    //     };

    //     let mut proof_range_sub_tree_estimate = get_split_point(proof.end_key) * 2;
    //     if (proof_range_sub_tree_estimate < 1) {
    //         proof_range_sub_tree_estimate = 1;
    //     }

    //     let (mut root_hash, proof_head, _, _) = compute_root(
    //         cloned_proof, leaf_nodes, 0, proof_range_sub_tree_estimate, 0, 0
    //     );

    //     let mut j = proof_head;
    //     loop {
    //         if (j == proof.side_nodes.len().into()) {
    //             break;
    //         }
    //         root_hash = node_digest(root_hash, *proof.side_nodes.at(j.try_into().unwrap()));
    //         j += 1;
    //     };

    //     return namespace_node_eq(root_hash, root);
    // }

    fn next_sub_tree_size(begin: u256, end: u256) -> u256 {
        let mut ideal = bits_trailing_zeroes(begin);
        let max = bits_len(end - begin) - 1;
        if (ideal > max) {
            return U256BitShift::shl(1, max);
        }
        return U256BitShift::shl(1, ideal);
    }


    fn bits_trailing_zeroes(mut x: u256) -> u256 {
        let mask: u256 = 1;
        let mut count: u256 = 0;

        while(x != 0 && mask & x == 0)
        {
            count += 1;
            x = U256BitShift::shr(x, 1);
        };

        return count;
    }

    fn compute_root(
        proof: NamespaceMerkleMultiproof,
        leaf_nodes: Array<NamespaceNode>,
        begin: u256,
        end: u256,
        head_proof: u256,
        head_leaves: u256
    ) -> (NamespaceNode, u256, u256, bool) {
        let clone_leaf_nodes = leaf_nodes.clone();
        let clone_begin_key = proof.begin_key.clone();
        let clone_end_key = proof.end_key.clone();
        let clone_side_nodes = proof.side_nodes.clone();
        let clone_proof = NamespaceMerkleMultiproof {
            begin_key: clone_begin_key, end_key: clone_end_key, side_nodes: clone_side_nodes
        };
        if (end - begin == 1) {
            if (proof.begin_key <= begin.into() && begin.into() < proof.end_key) {
                return pop_leaves_if_non_empty(
                    leaf_nodes, head_leaves, clone_leaf_nodes.len().into(), head_proof
                );
            }

            return pop_proof_if_non_empty(proof.side_nodes, head_proof, end, head_leaves);
        }

        if (end <= proof.begin_key || begin >= proof.end_key) {
            return pop_proof_if_non_empty(proof.side_nodes, head_proof, end, head_leaves);
        }

        let k = get_split_point(end - begin);

        let (left, new_head_proof_left, new_head_leaves_left, _) = compute_root(
            proof, clone_leaf_nodes, begin, begin + k, head_proof, head_leaves
        );

        let (right, new_head_proof, new_head_leaves, right_is_nil) = compute_root(
            clone_proof, leaf_nodes, begin + k, end, new_head_proof_left, new_head_leaves_left
        );

        if (right_is_nil == true) {
            return (left, new_head_proof, new_head_leaves, false);
        }

        let hash: NamespaceNode = node_digest(left, right);

        return (hash, new_head_proof, new_head_leaves, false);
    }

    fn pop_leaves_if_non_empty(
        nodes: Array<NamespaceNode>, head_leaves: u256, end: u256, head_proof: u256
    ) -> (NamespaceNode, u256, u256, bool) {
        let (node, new_head, is_nil): (NamespaceNode, u256, bool) = pop_if_non_empty(
            nodes, head_leaves, end
        );
        return (node, head_proof, new_head, is_nil);
    }

    fn pop_proof_if_non_empty(
        nodes: Array<NamespaceNode>, head: u256, end: u256, head_leaves: u256
    ) -> (NamespaceNode, u256, u256, bool) {
        let (node, new_head, is_nil): (NamespaceNode, u256, bool) = pop_if_non_empty(
            nodes, head, end
        );
        return (node, new_head, head_leaves, is_nil);
    }

    fn pop_if_non_empty(
        nodes: Array<NamespaceNode>, head: u256, end: u256
    ) -> (NamespaceNode, u256, bool) {
        let empty_bytes_31: bytes31 = 0_u8.into();
        let empty: Namespace = Namespace { version: 0, id: empty_bytes_31 };

        let empty_namespace_node: NamespaceNode = NamespaceNode {
            min: empty, max: empty, digest: 0
        };
        if (nodes.len() == 0 || head >= nodes.len().into() || head >= end) {
            return (empty_namespace_node, head, true);
        }

        return (*nodes.at(head.try_into().unwrap()), head + 1, false);
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
