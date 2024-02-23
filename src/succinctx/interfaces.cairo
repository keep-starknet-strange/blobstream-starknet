use alexandria_bytes::{Bytes, BytesTrait};
use starknet::ContractAddress;

#[starknet::interface]
trait IFunctionVerifier<TContractState> {
    fn verify(self: @TContractState, input_hash: u256, output_hash: u256, proof: Bytes) -> bool;
    fn verification_key_hash(self: @TContractState) -> u256;
}

#[starknet::interface]
trait ISuccinctGateway<TContractState> {
    fn request_callback(
        ref self: TContractState,
        function_id: u256,
        input: Bytes,
        context: Bytes,
        callback_selector: felt252,
        callback_gas_limit: u32,
    ) -> u256;
    fn request_call(
        ref self: TContractState,
        function_id: u256,
        input: Bytes,
        entry_address: ContractAddress,
        entry_calldata: Bytes,
        entry_gas_limit: u32
    );
    fn verified_call(self: @TContractState, function_id: u256, input: Bytes) -> (u256, u256);
    fn fulfill_callback(
        ref self: TContractState,
        nonce: u32,
        function_id: u256,
        input_hash: u256,
        callback_addr: ContractAddress,
        callback_selector: felt252,
        callback_calldata: Span<felt252>,
        callback_gas_limit: u32,
        context: Bytes,
        output: Bytes,
        proof: Bytes
    );
    fn fulfill_call(
        ref self: TContractState,
        function_id: u256,
        input: Bytes,
        output: Bytes,
        proof: Bytes,
        callback_addr: ContractAddress,
        callback_selector: felt252,
        callback_calldata: Span<felt252>,
    );
}
