use blobstream_sn::tree::namespace::merkle_tree::{NamespaceNode, Namespace};

#[test]
fn testing_partial_ord_and_eq() {
    let b17 = bytes31_const::<0x0102030405060708090a0b0c0d0e0f1011>();
    assert(b17.at(0) > b17.at(1), 'Invalid assertion');
    assert(b17.at(14) == 0x03, 'Invalid assertion');
    assert(b17.at(15) != 0x01, 'Invalid assertion');

    let b31 = bytes31_const::<0x0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f>();
    assert(b31.at(0) > b31.at(1), 'Invalid assertion');
    assert(b31.at(1) < b31.at(0), 'Invalid assertion');
    assert(b31.at(14) >= 0x03, 'Invalid assertion');
    assert(b31.at(17) <= 0x11, 'Invalid assertion');
}
