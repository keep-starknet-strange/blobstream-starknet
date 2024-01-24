use core::keccak::{add_padding, u128_split};

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
