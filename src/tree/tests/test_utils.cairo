use blobstream_sn::tree::utils;

#[test]
fn test_get_starting_bit() {
    assert_eq!(utils::get_starting_bit(0), 0, "starting bit 0 test failed");
    assert_eq!(utils::get_starting_bit(1), 0, "starting bit 1 test failed");
    assert_eq!(utils::get_starting_bit(2), 1, "starting bit 2 test failed");
    assert_eq!(utils::get_starting_bit(4), 2, "starting bit 4 test failed");
    assert_eq!(utils::get_starting_bit(6), 3, "starting bit 6 test failed");
    assert_eq!(utils::get_starting_bit(8), 3, "starting bit 8 test failed");
}

#[test]
fn test_path_length_from_keys() {
    assert_eq!(utils::path_length_from_key(0, 2), 1, "key (0, 2) test failed");
    assert_eq!(utils::path_length_from_key(1, 2), 1, "key (1, 2) test failed");
    assert_eq!(utils::path_length_from_key(0, 8), 3, "key (0, 8) test failed");
    assert_eq!(utils::path_length_from_key(1, 8), 3, "key (1, 8) test failed");
    assert_eq!(utils::path_length_from_key(2, 8), 3, "key (2, 8) test failed");
    assert_eq!(utils::path_length_from_key(3, 8), 3, "key (3, 8) test failed");
    assert_eq!(utils::path_length_from_key(4, 8), 3, "key (4, 8) test failed");
    assert_eq!(utils::path_length_from_key(5, 8), 3, "key (5, 8) test failed");
    assert_eq!(utils::path_length_from_key(6, 8), 3, "key (6, 8) test failed");
    assert_eq!(utils::path_length_from_key(7, 8), 3, "key (7, 8) test failed");
}

#[test]
fn test_bits_len() {
    assert_eq!(utils::bits_len(0), 0, "bits len 0 test failed");
    assert_eq!(utils::bits_len(1), 1, "bits len 1 test failed");
    assert_eq!(utils::bits_len(2), 2, "bits len 2 test failed");
    assert_eq!(utils::bits_len(3), 2, "bits len 3 test failed");
    assert_eq!(utils::bits_len(4), 3, "bits len 4 test failed");
    assert_eq!(utils::bits_len(5), 3, "bits len 5 test failed");
    assert_eq!(utils::bits_len(6), 3, "bits len 6 test failed");
    assert_eq!(utils::bits_len(7), 3, "bits len 7 test failed");
    assert_eq!(utils::bits_len(8), 4, "bits len 8 test failed");
    assert_eq!(utils::bits_len(16), 5, "bits len 16 test failed");
}

#[test]
fn test_get_split_point() {
    assert_eq!(utils::get_split_point(1), 0, "split point 1 test failed");
    assert_eq!(utils::get_split_point(2), 1, "split point 2 test failed");
    assert_eq!(utils::get_split_point(3), 2, "split point 3 test failed");
    assert_eq!(utils::get_split_point(4), 2, "split point 4 test failed");
    assert_eq!(utils::get_split_point(5), 4, "split point 5 test failed");
    assert_eq!(utils::get_split_point(6), 4, "split point 6 test failed");
    assert_eq!(utils::get_split_point(7), 4, "split point 7 test failed");
    assert_eq!(utils::get_split_point(8), 4, "split point 8 test failed");
    assert_eq!(utils::get_split_point(16), 8, "split point 16 test failed");
}
