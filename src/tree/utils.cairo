use alexandria_math::U256BitShift;
use blobstream_sn::tree::consts::MAX_HEIGHT;

// Calculate the starting bit of the path to a leaf
fn get_starting_bit(num_leaves: u256) -> u256 {
    let mut starting_bit: u256 = 0;
    loop {
        if (U256BitShift::shl(1, starting_bit) < num_leaves) {
            starting_bit += 1;
        } else {
            break;
        }
    };
    starting_bit
}

// Calculate the length of the path to a leaf with a given key
fn path_length_from_key(key: u256, num_leaves: u256) -> u256 {
    if (num_leaves <= 1) {
        return 0;
    }

    let mut path_length: u256 = get_starting_bit(num_leaves);

    let num_leaves_left_sub_tree: u256 = U256BitShift::shl(1, (path_length - 1));

    if (key <= num_leaves_left_sub_tree - 1) {
        return path_length;
    } else if (num_leaves_left_sub_tree == 1) {
        return 1;
    } else {
        return 1
            + path_length_from_key(
                key - num_leaves_left_sub_tree, num_leaves - num_leaves_left_sub_tree
            );
    }
}

// Calculate the minimum number of bits needed to represent `x`
fn bits_len(mut x: u256) -> u256 {
    let mut count: u256 = 0;
    loop {
        if (x == 0) {
            break;
        }

        count += 1;
        x = U256BitShift::shr(x, 1);
    };
    count
}

// Calculate the largest power of 2 less than `x`
fn get_split_point(x: u256) -> u256 {
    assert!(x >= 1, "get split point");

    let bit_len: u256 = bits_len(x);
    let mut k: u256 = U256BitShift::shl(1, (bit_len - 1));
    if (x == k) {
        k = U256BitShift::shr(k, 1);
    }
    k
}
