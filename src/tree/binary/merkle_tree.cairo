use alexandria_bytes::Bytes;
use blobstream_sn::tree::binary::hasher::{leaf_digest, node_digest};
use blobstream_sn::tree::binary::merkle_proof::BinaryMerkleProof;
use blobstream_sn::tree::utils::{path_length_from_key, get_split_point};

#[derive(Copy, Drop, PartialEq, Debug)]
enum ErrorCodes {
    NoError,
    InvalidNumberOfSideNodes,
    KeyNotInTree,
    InvalidNumberOfLeavesInProof,
    UnexpectedInnerHashes,
    ExpectedAtLeastOneInnerHash,
}

// Verify if `data` element exists in the Merkle tree with given `root` and `proof`.
fn verify(root: u256, proof: @BinaryMerkleProof, data: @Bytes) -> (bool, ErrorCodes) {
    // Verify proof length corresponding to given `key` and `num_leaves`.
    if (*proof.num_leaves <= 1) {
        if (proof.side_nodes.len() != 0) {
            return (false, ErrorCodes::InvalidNumberOfSideNodes);
        }
    } else if (proof
        .side_nodes
        .len()
        .into() != path_length_from_key(*proof.key, *proof.num_leaves)) {
        return (false, ErrorCodes::InvalidNumberOfSideNodes);
    }

    // Check `key` is in the tree
    if (*proof.key >= *proof.num_leaves) {
        return (false, ErrorCodes::KeyNotInTree);
    }

    let digest: u256 = leaf_digest(data);

    // Handle the case where the tree has only one leaf.
    if (proof.side_nodes.len() == 0) {
        if (*proof.num_leaves == 1) {
            return (root == digest, ErrorCodes::NoError);
        } else {
            return (false, ErrorCodes::NoError);
        }
    }

    // Recursively compute the root hash of the `proof` with `data` digest.
    let (computed_hash, error) = compute_root_hash(
        *proof.key, *proof.num_leaves, digest, proof.side_nodes.span()
    );
    if (error != ErrorCodes::NoError) {
        return (false, error);
    }

    // Only valid proof if the computed hash matches the given `root`.
    return (computed_hash == root, ErrorCodes::NoError);
}

// Use the `leaf_hash` and `side_nodes` to recusively compute the root hash of the Merkle tree.
fn compute_root_hash(
    key: u256, num_leaves: u256, leaf_hash: u256, side_nodes: Span<u256>
) -> (u256, ErrorCodes) {
    // Handle the base case(s) of the recursion.
    if (num_leaves == 0) {
        return (leaf_hash, ErrorCodes::InvalidNumberOfLeavesInProof);
    }
    if (num_leaves == 1) {
        if (side_nodes.len() != 0) {
            return (leaf_hash, ErrorCodes::UnexpectedInnerHashes);
        }
        return (leaf_hash, ErrorCodes::NoError);
    }
    if (side_nodes.len() == 0) {
        return (leaf_hash, ErrorCodes::ExpectedAtLeastOneInnerHash);
    }

    // Recursively compute the hashes of the subtrees.
    let num_left: u256 = get_split_point(num_leaves);
    let side_nodes_left: Span<u256> = side_nodes.slice(0, side_nodes.len() - 1);
    if (key < num_left) {
        // Left subtree
        let (left_hash, error) = compute_root_hash(key, num_left, leaf_hash, side_nodes_left);
        if (error != ErrorCodes::NoError) {
            return (leaf_hash, error);
        }

        return (node_digest(left_hash, *side_nodes.at(side_nodes.len() - 1)), ErrorCodes::NoError);
    }

    // Right subtree
    let (right_hash, error) = compute_root_hash(
        key - num_left, num_leaves - num_left, leaf_hash, side_nodes_left
    );
    if (error != ErrorCodes::NoError) {
        return (leaf_hash, error);
    }

    return (node_digest(*side_nodes.at(side_nodes.len() - 1), right_hash), ErrorCodes::NoError);
}
