use alexandria_bytes::Bytes;
use blobstream_sn::tree::binary::merkle_proof::BinaryMerkleProof;

#[derive(Drop)]
enum ErrorCodes {
    // TODO: Comment these
    NoError,
    InvalidNumberOfSideNodes,
    KeyNotInTree,
    InvalidNumberOfLeavesInProof,
    UnexpectedInnerHashes,
    ExpectedAtLeastOneInnerHash,
}

// TODO: allow for custom type instead of u256?
fn verify(root: u256, proof: @BinaryMerkleProof, data: @Bytes) -> (bool, ErrorCodes) {
    return (false, ErrorCodes::NoError);
}

fn compute_root_hash(key: u256, num_leaves: u256, leaf_hash: u256,
                     side_nodes: @Array<u256>) -> (u256, ErrorCodes) {
    return (0, ErrorCodes::NoError);
}

fn slice(data: @Array<u256>, begin: u256, end: u256) -> @Array<u256> {
    return @array![];
}
