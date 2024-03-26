use blobstream_sn::tree::namespace::Namespace;

#[derive(Serde, Drop, Copy, PartialEq)]
struct NamespaceNode {
    min: Namespace,
    max: Namespace,
    // Node value.
    digest: u256,
}

#[derive(Drop, PartialEq, PartialOrd)]
struct NamespaceMerkleMultiproof {
    begin_key: u32,
    end_key: u32,
    side_nodes: Array<NamespaceNode>,
}

#[derive(Drop, PartialEq, PartialOrd)]
struct NamespaceMerkleProof {
    side_nodes: Array<NamespaceNode>,
    key: u32,
    num_leaves: u32,
}

mod NamespaceMerkleTree {
    use alexandria_bytes::bytes::Bytes;
    use alexandria_math::U32BitShift;
    use blobstream_sn::tree::namespace::hasher;
    use blobstream_sn::tree::utils;
    use super::{Namespace, NamespaceNode, NamespaceMerkleMultiproof, NamespaceMerkleProof};

    fn verify(
        root: NamespaceNode, proof: NamespaceMerkleProof, namespace: Namespace, data: Bytes
    ) -> bool {
        // Create a sibling leaf at height 1.
        let node: NamespaceNode = hasher::leaf_digest(namespace, @data);

        // Since we're verifying a leaf, height is 1.
        return verify_inner(root, proof, node, 1);
    }

    fn verify_inner(
        root: NamespaceNode,
        proof: NamespaceMerkleProof,
        mut node: NamespaceNode,
        starting_height: u32
    ) -> bool {
        if starting_height < 1 {
            return false;
        }
        let height_offset: u32 = starting_height - 1;

        let proof_side_nodes_len: u32 = proof.side_nodes.len();

        // Check proof is correct length for the key it is proving.
        if proof.num_leaves <= 1 {
            if proof_side_nodes_len != 0 {
                return false;
            }
        } else if proof_side_nodes_len
            + height_offset != utils::path_length_from_key(proof.key, proof.num_leaves) {
            return false;
        }

        // Check key is in tree
        if proof.key >= proof.num_leaves {
            return false;
        }
        // Handle case where proof is empty: i.e, only one leaf exists, so verify hash(data) is root
        if proof_side_nodes_len == 0 {
            if proof.num_leaves == 1 {
                return super::namespace_node_eq(root, node);
            } else {
                return false;
            }
        }

        let mut height: u32 = starting_height;
        let mut stable_end: u32 = proof.key;

        let mut exit_after: bool = false;
        let side_nodes_span: Span<NamespaceNode> = proof.side_nodes.span();
        while true {
            let rounding_factor: u32 = U32BitShift::shl(1, height);
            let sub_tree_start_index: u32 = (proof.key / rounding_factor) * rounding_factor;
            let sub_tree_end_index: u32 = sub_tree_start_index + rounding_factor - 1;

            if sub_tree_end_index >= proof.num_leaves {
                break;
            }
            stable_end = sub_tree_end_index;

            // Check if key is in the first or second half of the sub-tree.
            if proof_side_nodes_len + height_offset <= height - 1 {
                exit_after = true;
                break;
            }
            let side_node: NamespaceNode = *side_nodes_span.at((height - height_offset - 1));
            if proof.key - sub_tree_start_index < rounding_factor / 2 {
                node = hasher::node_digest(node, side_node);
            } else {
                node = hasher::node_digest(side_node, node);
            }

            height += 1;
        };
        if exit_after {
            return false;
        }

        if stable_end != proof.num_leaves - 1 {
            if proof_side_nodes_len <= height - height_offset - 1 {
                return false;
            }
            node = hasher::node_digest(node, *proof.side_nodes.at((height - height_offset - 1)));
            height += 1;
        }

        // All remaining elements in proof set will belong to a left sibling.
        while height
            - height_offset
            - 1 < proof_side_nodes_len {
                node =
                    hasher::node_digest(*proof.side_nodes.at((height - height_offset - 1)), node);
                height += 1;
            };

        return super::namespace_node_eq(root, node);
    }

    fn verify_multi(
        root: NamespaceNode,
        proof: @NamespaceMerkleMultiproof,
        namespace: Namespace,
        data: Span<Bytes>
    ) -> bool {
        // Hash all the leaves to get leaf nodes.
        let mut nodes: Array<NamespaceNode> = array![];
        let mut i: u32 = 0;
        while i < data.len() {
            nodes.append(hasher::leaf_digest(namespace, data.at(i)));
            i += 1;
        };

        // Verify inclusion of leaf nodes.
        return verify_multi_hashes(root, proof, nodes);
    }

    fn verify_multi_hashes(
        root: NamespaceNode, proof: @NamespaceMerkleMultiproof, leaf_nodes: Array<NamespaceNode>
    ) -> bool {
        let mut leaf_index: u32 = 0;
        let mut left_subtrees: Array<NamespaceNode> = array![];

        let mut i: u32 = 0;
        while leaf_index != *proof.begin_key
            && i < proof
                .side_nodes
                .len() {
                    let subtree_size = _next_subtree_size(leaf_index, *proof.begin_key);
                    left_subtrees.append(*proof.side_nodes.at(i));
                    leaf_index += subtree_size;
                    i += 1;
                };

        // estimate the leaf size of the subtree containing the proof range
        let mut proof_range_subtree_estimate = utils::get_split_point(*proof.end_key) * 2;
        if proof_range_subtree_estimate < 1 {
            proof_range_subtree_estimate = 1;
        }

        let (mut root_hash, proof_head, _, _) = _compute_root(
            proof, leaf_nodes.span(), 0, proof_range_subtree_estimate, 0, 0
        );
        let mut i: u32 = proof_head;
        while i < proof
            .side_nodes
            .len() {
                root_hash = hasher::node_digest(root_hash, *proof.side_nodes.at(i));
                i += 1;
            };

        return super::namespace_node_eq(root_hash, root);
    }

    // Gives the size of the subtree adjacent to `begin` that does not overlap `end`.
    fn _next_subtree_size(begin: u32, end: u32) -> u32 {
        let ideal: u32 = _bits_trailing_zeroes(begin);
        let max: u32 = utils::bits_len(end - begin) - 1;
        if ideal > max {
            return U32BitShift::shl(1, max);
        } else {
            return U32BitShift::shl(1, ideal);
        }
    }

    // Returns the number of trailing zero bits in `x`.
    fn _bits_trailing_zeroes(mut x: u32) -> u32 {
        let mask: u32 = 1;
        let mut count: u32 = 0;

        while (x != 0 && mask & x == 0) {
            count += 1;
            x = U32BitShift::shr(x, 1);
        };

        return count;
    }

    // Computes the NMT root recursively.
    fn _compute_root(
        proof: @NamespaceMerkleMultiproof,
        leaf_nodes: Span<NamespaceNode>,
        begin: u32,
        end: u32,
        head_proof: u32,
        head_leaves: u32
    ) -> (NamespaceNode, u32, u32, bool) {
        // Reached a leaf
        if end - begin == 1 {
            if *proof.begin_key <= begin && begin < *proof.end_key {
                return _pop_leaves_if_non_empty(
                    leaf_nodes, head_leaves, leaf_nodes.len(), head_proof
                );
            }

            return _pop_proof_if_non_empty(proof.side_nodes.span(), head_proof, end, head_leaves);
        }

        if end <= *proof.begin_key || begin >= *proof.end_key {
            return _pop_proof_if_non_empty(proof.side_nodes.span(), head_proof, end, head_leaves);
        }

        // Recursively get left and right subtree
        let k: u32 = utils::get_split_point(end - begin);
        let (left, new_head_proof_left, new_head_leaves_left, _) = _compute_root(
            proof, leaf_nodes, begin, begin + k, head_proof, head_leaves
        );
        let (right, new_head_proof, new_head_leaves, right_is_nil) = _compute_root(
            proof, leaf_nodes, begin + k, end, new_head_proof_left, new_head_leaves_left
        );

        if right_is_nil {
            return (left, new_head_proof, new_head_leaves, false);
        }
        let hash = hasher::node_digest(left, right);
        return (hash, new_head_proof, new_head_leaves, false);
    }

    fn _pop_leaves_if_non_empty(
        nodes: Span<NamespaceNode>, head_leaves: u32, end: u32, head_proof: u32
    ) -> (NamespaceNode, u32, u32, bool) {
        let (node, new_head, is_nil) = _pop_if_non_empty(nodes, head_leaves, end);
        return (node, head_proof, new_head, is_nil);
    }

    fn _pop_proof_if_non_empty(
        nodes: Span<NamespaceNode>, head_proof: u32, end: u32, head_leaves: u32
    ) -> (NamespaceNode, u32, u32, bool) {
        let (node, new_head, is_nil) = _pop_if_non_empty(nodes, head_proof, end);
        return (node, new_head, head_leaves, is_nil);
    }

    fn _pop_if_non_empty(
        nodes: Span<NamespaceNode>, head: u32, end: u32
    ) -> (NamespaceNode, u32, bool) {
        if nodes.len() == 0 || head >= nodes.len() || head >= end {
            let nid: Namespace = Default::default();
            let node: NamespaceNode = NamespaceNode { min: nid, max: nid, digest: 0 };
            return (node, head, true);
        }
        return (*nodes.at(head), head + 1, false);
    }
}

fn namespace_node_eq(first: NamespaceNode, second: NamespaceNode) -> bool {
    return first.min == second.min && first.max == second.max && (first.digest == second.digest);
}
