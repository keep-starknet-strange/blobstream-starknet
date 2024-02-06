use blobstream_sn::tree::utils::path_length_from_key;

#[test]
fn test_path_length_from_keys() {
    assert_eq!(path_length_from_key(0, 2), 1, "key (0, 2) test failed");
    assert_eq!(path_length_from_key(1, 2), 1, "key (1, 2) test failed");
    assert_eq!(path_length_from_key(0, 8), 3, "key (0, 8) test failed");
    assert_eq!(path_length_from_key(1, 8), 3, "key (1, 8) test failed");
    assert_eq!(path_length_from_key(2, 8), 3, "key (2, 8) test failed");
    assert_eq!(path_length_from_key(3, 8), 3, "key (3, 8) test failed");
    assert_eq!(path_length_from_key(4, 8), 3, "key (4, 8) test failed");
    assert_eq!(path_length_from_key(5, 8), 3, "key (5, 8) test failed");
    assert_eq!(path_length_from_key(6, 8), 3, "key (6, 8) test failed");
    assert_eq!(path_length_from_key(7, 8), 3, "key (7, 8) test failed");
}
