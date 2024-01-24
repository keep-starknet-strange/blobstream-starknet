mod tree;
mod utils;
mod verifier;

use starknet::EthAddress;
use starknet::secp256_trait::Signature;

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
    data_root: u256
}

#[starknet::interface]
trait IDAOracle<TContractState> {
    fn verify_sig(self: @TContractState, digest: u256, sig: Signature, signer: EthAddress) -> bool;
}


#[starknet::contract]
mod Blobstream {
    use starknet::EthAddress;
    use starknet::eth_signature::verify_eth_signature;
    use starknet::secp256_trait::Signature;

    #[storage]
    struct Storage {
        state_event_nonce: felt252,
        state_power_threshold: felt252,
        state_last_validator_checkpoint: u256, // TODO will need to change type here
    }

    // #[constructor]
    fn initialize(
        ref self: ContractState,
        nonce: felt252,
        power_threshold: felt252,
        validator_checkpoint: u256
    ) {
        self.state_event_nonce.write(nonce);
        self.state_power_threshold.write(power_threshold);
        self.state_last_validator_checkpoint.write(validator_checkpoint);
    }

    #[abi(embed_v0)]
    impl Blobstream of super::IDAOracle<ContractState> {
        fn verify_sig(
            self: @ContractState, digest: u256, sig: Signature, signer: EthAddress,
        ) -> bool {
            verify_eth_signature(digest, sig, signer);
            false
        }
    }
}

#[cfg(test)]
mod tests {
    mod test_blobstream;
    mod test_verifier;
}
