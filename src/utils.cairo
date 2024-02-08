use core::keccak::{add_padding, u128_split};
use blobstream_sn::tree::consts::{LEAF_PREFIX, NODE_PREFIX, MAX_HEIGHT};
use alexandria_math::{U256BitShift, pow, BitShift};

fn append_packed(ref input: Array::<u64>, v: u256) {
    let (high, low) = u128_split(core::integer::u128_byte_reverse(v.high));
    input.append(low);
    input.append(high);
    let (high, low) = u128_split(core::integer::u128_byte_reverse(v.low));
    input.append(low);
    input.append(high);
}

// The input values are interpreted as big-endian.
// The 32-byte result is represented as a little-endian u256.
fn encode_packed(mut input: Span<u256>) -> Array::<u64> {
    let mut encode_input: Array::<u64> = Default::default();

    loop {
        match input.pop_front() {
            Option::Some(v) => { append_packed(ref encode_input, *v); },
            Option::None => { break (); },
        };
    };

    add_padding(ref encode_input, 0, 0);
    encode_input
}

fn get_split_point(x: u256) -> u256 {
    assert!(x >= 1, "get split point");

    let bit_len: u256 = bits_len(x);
    let mut k: u256 = U256BitShift::shl(1, (bit_len - 1));
    if (x == k) {
        k = U256BitShift::shr(k, 1);
    }
    k
}

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

// fn path_length_from_key(key: u256, num_leaves: u256) -> u256 {
//     if (num_leaves <= 1) {
//         return 0;
//     }

//     let mut path_length = MAX_HEIGHT.into() - get_starting_bit(num_leaves);
//     let num_leaves_left_sub_tree = BitShift::shl(pow::<u256>(1, path_length - 1), 1);
//     if (key <= num_leaves_left_sub_tree - 1) {
//         return path_length;
//     } else if (num_leaves_left_sub_tree == 1) {
//         return 1;
//     } else {
//         return 1
//             + path_length_from_key(
//                 key - num_leaves_left_sub_tree, num_leaves - num_leaves_left_sub_tree
//             );
//     }
// }

fn path_length_from_key(key: u256, num_leaves: u256) -> u256 {
    if (num_leaves <= 1) {
        return 0;
    }

    let mut path_length: u256 = MAX_HEIGHT.into() - get_starting_bit(num_leaves);

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


// fn get_starting_bit(num_leaves: u256) -> u256 {
//     let mut starting_bit = 0;
//     let mut num_leaves = num_leaves;
//     while((BitShift::shl(pow::<u256>(1, starting_bit), 1) < num_leaves))
//     {
//         starting_bit += 1;
//     };

//     return MAX_HEIGHT.into() - starting_bit;
// }
fn get_starting_bit(num_leaves: u256) -> u256 {
    let mut starting_bit: u256 = 0;
    loop {
        if (BitShift::shl(1, starting_bit) < num_leaves) {
            starting_bit += 1;
        } else {
            break;
        }
    };
    MAX_HEIGHT.into() - starting_bit
}

