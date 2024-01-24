use blobstream_sn::tree::namespace::merkle_tree::Namespace;
use core::bytes_31::bytes31_const;

const MAX_HEIGHT: felt252 = 256;
const LEAF_PREFIX: u128 = 0x00;
const NODE_PREFIX: u128 = 0x01;

// utility function to provide the parity share namespace as a Namespace struct
fn parity_share_namespace() -> Namespace {
    Namespace {
        version: 0xFF,
        id: bytes31_const::<0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF>(),
    }
}
