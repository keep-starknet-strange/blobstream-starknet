mod tree;
mod verifier;

use starknet::{EthAddress};

#[cfg(test)]
mod tests {
    mod stub;
}

// u256 encoding of the string "checkpoint"
const VALIDATOR_SET_HASH_DOMAIN_SEPARATOR: u256 =
    0x636865636b706f696e7400000000000000000000000000000000000000000000;

// u256 encoding of the string "transactionBatch"
const DATA_ROOT_TUPLE_ROOT_DOMAIN_SEPARATOR: u256 =
    0x7472616e73616374696f6e426174636800000000000000000000000000000000;


#[derive(Copy, Drop)]
struct Validator {
    addr: EthAddress,
    power: u256
}

// Each data root is associated with a Celestia block height. `availableDataRoot` in
// https://github.com/celestiaorg/celestia-specs/blob/master/src/specs/data_structures.md#header
#[derive(Copy, Drop)]
struct DataRoot {
    // Celestia block height for data root(genesis height = 0)
    height: felt252,
    // Data root
    dataRoot: u256
}

