use blobstream_sn::tree::namespace::Namespace;
use core::bytes_31::bytes31_const;

const MAX_HEIGHT: u256 = 256;
const LEAF_PREFIX: u8 = 0x00;
const NODE_PREFIX: u8 = 0x01;

// utility function to provide the parity share namespace as a Namespace struct
fn parity_share_namespace() -> Namespace {
    Namespace {
        version: 0xFF,
        id: bytes31_const::<0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF>(),
    }
}
