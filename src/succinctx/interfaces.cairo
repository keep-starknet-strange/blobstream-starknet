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


#[starknet::interface]
trait IFeeVault<TContractState> {
    fn get_native_currency(self: @TContractState) -> ContractAddress;
    fn set_native_currency(ref self: TContractState, _new_native_address: ContractAddress);
    fn get_deductor_status(self: @TContractState, _deductor: ContractAddress) -> bool;
    fn get_balances_infos(
        self: @TContractState, _account: ContractAddress, _token: ContractAddress
    ) -> u256;
    fn add_deductor(ref self: TContractState, _deductor: ContractAddress);
    fn remove_deductor(ref self: TContractState, _deductor: ContractAddress);
    fn deposit_native(ref self: TContractState, _account: ContractAddress);
    fn deposit(
        ref self: TContractState, _account: ContractAddress, _token: ContractAddress, _amount: u256
    );
    fn deduct_native(ref self: TContractState, _account: ContractAddress);
    fn deduct(
        ref self: TContractState, _account: ContractAddress, _token: ContractAddress, _amount: u256
    );
    fn collect_native(ref self: TContractState, _to: ContractAddress, _amount: u256);
    fn collect(
        ref self: TContractState, _to: ContractAddress, _token: ContractAddress, _amount: u256
    );
}
