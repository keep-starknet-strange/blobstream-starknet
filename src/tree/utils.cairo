use alexandria_math::U32BitShift;
use blobstream_sn::tree::consts::MAX_HEIGHT;

// Calculate the starting bit of the path to a leaf
fn get_starting_bit(num_leaves: u32) -> u32 {
    let mut starting_bit: u32 = 0;
    loop {
        if (U32BitShift::shl(1, starting_bit) < num_leaves) {
            starting_bit += 1;
        } else {
            break;
        }
    };
    starting_bit
}

// Calculate the length of the path to a leaf with a given key
fn path_length_from_key(key: u32, num_leaves: u32) -> u32 {
    if (num_leaves <= 1) {
        return 0;
    }

    let mut path_length: u32 = get_starting_bit(num_leaves);

    let num_leaves_left_sub_tree: u32 = U32BitShift::shl(1, (path_length - 1));

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
fn bits_len(mut x: u32) -> u32 {
    let mut count: u32 = 0;
    loop {
        if (x == 0) {
            break;
        }

        count += 1;
        x = U32BitShift::shr(x, 1);
    };
    count
}

// Calculate the largest power of 2 less than `x`
fn get_split_point(x: u32) -> u32 {
    assert!(x >= 1, "get split point");

    let bit_len: u32 = bits_len(x);
    let mut k: u32 = U32BitShift::shl(1, (bit_len - 1));
    if (x == k) {
        k = U32BitShift::shr(k, 1);
    }
    k
}
