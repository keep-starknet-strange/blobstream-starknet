use starknet::secp256_trait::Signature;
use starknet::{EthAddress, ContractAddress, ClassHash};

#[derive(Copy, Drop, Serde)]
struct Validator {
    addr: EthAddress,
    power: u256
}

#[starknet::interface]
trait IDAOracle<TContractState> {
    fn verify_sig(self: @TContractState, digest: u256, sig: Signature, signer: EthAddress) -> bool;
    fn submit_data_root_tuple_root(
        ref self: TContractState,
        _new_nonce: felt252,
        _validator_set_nonce: felt252,
        _data_root_tuple_root: u256,
        _current_validator_set: Span<Validator>,
        _sigs: Span<Signature>
    );
    fn update_validator_set(
        ref self: TContractState,
        _new_nonce: felt252,
        _old_nonce: felt252,
        _new_power_threshold: felt252,
        _new_validator_set_hash: u256,
        _current_validator_set: Span<Validator>,
        _sigs: Span<Signature>
    );
}
