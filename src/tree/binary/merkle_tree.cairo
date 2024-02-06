use alexandria_bytes::Bytes;
use blobstream_sn::tree::binary::hasher::{leaf_digest, node_digest};
use blobstream_sn::tree::binary::merkle_proof::BinaryMerkleProof;
use blobstream_sn::tree::utils::{path_length_from_key, get_split_point};

#[derive(Copy, Drop)]
enum ErrorCodes {
    NoError,
    InvalidNumberOfSideNodes,
    KeyNotInTree,
    InvalidNumberOfLeavesInProof,
    UnexpectedInnerHashes,
    ExpectedAtLeastOneInnerHash,
}

fn is_no_error(error: ErrorCodes) -> bool {
    //match error {
    //    ErrorCodes::NoError => true,
    //    _ => false,
    //}
    match error {
        ErrorCodes::NoError => true,
        ErrorCodes::InvalidNumberOfSideNodes => false,
        ErrorCodes::KeyNotInTree => false,
        ErrorCodes::InvalidNumberOfLeavesInProof => false,
        ErrorCodes::UnexpectedInnerHashes => false,
        ErrorCodes::ExpectedAtLeastOneInnerHash => false,
    }
}

fn verify(root: u256, proof: @BinaryMerkleProof, data: @Bytes) -> (bool, ErrorCodes) {
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

    if (*proof.key >= *proof.num_leaves) {
        return (false, ErrorCodes::KeyNotInTree);
    }

    let digest: u256 = leaf_digest(data);

    if (proof.side_nodes.len() == 0) {
        if (*proof.num_leaves == 1) {
            return (root == digest, ErrorCodes::NoError);
        } else {
            return (false, ErrorCodes::NoError);
        }
    }

    let (computed_hash, error) = compute_root_hash(
        *proof.key, *proof.num_leaves, digest, proof.side_nodes.span()
    );

    //match error {
    //    ErrorCodes::NoError => (),
    //    _ => { return (false, error); }
    //}
    match error {
        ErrorCodes::NoError => (),
        ErrorCodes::InvalidNumberOfSideNodes => { return (false, error); },
        ErrorCodes::KeyNotInTree => { return (false, error); },
        ErrorCodes::InvalidNumberOfLeavesInProof => { return (false, error); },
        ErrorCodes::UnexpectedInnerHashes => { return (false, error); },
        ErrorCodes::ExpectedAtLeastOneInnerHash => { return (false, error); },
    }

    return (computed_hash == root, ErrorCodes::NoError);
}

fn compute_root_hash(
    key: u256, num_leaves: u256, leaf_hash: u256, side_nodes: Span<u256>
) -> (u256, ErrorCodes) {
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

    let num_left: u256 = get_split_point(num_leaves);
    let side_nodes_left: Array<u256> = slice(side_nodes, 0, side_nodes.len().into() - 1);
    if (key < num_left) {
        let (left_hash, error) = compute_root_hash(
            key, num_left, leaf_hash, side_nodes_left.span()
        );
        //match error {
        //    ErrorCodes::NoError => (),
        //    _ => { return (leaf_hash, error); }
        //}
        match error {
            ErrorCodes::NoError => (),
            ErrorCodes::InvalidNumberOfSideNodes => { return (leaf_hash, error); },
            ErrorCodes::KeyNotInTree => { return (leaf_hash, error); },
            ErrorCodes::InvalidNumberOfLeavesInProof => { return (leaf_hash, error); },
            ErrorCodes::UnexpectedInnerHashes => { return (leaf_hash, error); },
            ErrorCodes::ExpectedAtLeastOneInnerHash => { return (leaf_hash, error); },
        }
        return (node_digest(left_hash, *side_nodes.at(side_nodes.len() - 1)), ErrorCodes::NoError);
    }

    let (right_hash, error) = compute_root_hash(
        key - num_left, num_leaves - num_left, leaf_hash, side_nodes_left.span()
    );
    //match error {
    //    ErrorCodes::NoError => (),
    //    _ => { return (leaf_hash, error); }
    //}
    match error {
        ErrorCodes::NoError => (),
        ErrorCodes::InvalidNumberOfSideNodes => { return (leaf_hash, error); },
        ErrorCodes::KeyNotInTree => { return (leaf_hash, error); },
        ErrorCodes::InvalidNumberOfLeavesInProof => { return (leaf_hash, error); },
        ErrorCodes::UnexpectedInnerHashes => { return (leaf_hash, error); },
        ErrorCodes::ExpectedAtLeastOneInnerHash => { return (leaf_hash, error); },
    }
    return (node_digest(*side_nodes.at(side_nodes.len() - 1), right_hash), ErrorCodes::NoError);
}

fn slice(mut data: Span<u256>, begin: u256, end: u256) -> Array<u256> {
    if (begin > end) {
        panic!("slice: begin > end");
    }
    if (begin > data.len().into() || end > data.len().into()) {
        panic!("slice: begin or end out of bounds");
    }

    let mut out: Array<u256> = array![];
    let mut i: u256 = 0;
    loop {
        if (i == begin) {
            break;
        }
        data.pop_front().unwrap();
        i += 1;
    };
    loop {
        if (i == end) {
            break;
        }
        out.append(*data.pop_front().unwrap());
        i += 1;
    };

    return out;
}
