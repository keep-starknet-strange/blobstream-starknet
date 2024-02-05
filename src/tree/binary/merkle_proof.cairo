#[derive(Drop)]
struct BinaryMerkleProof {
    // list of side nodes to verify and calculate tree
    side_nodes: Array<u256>,
    // key of the leaf to verify
    key: u256,
    // number of leaves in the tree
    num_leaves: u256,
}
