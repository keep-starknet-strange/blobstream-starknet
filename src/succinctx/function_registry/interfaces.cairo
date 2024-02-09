use starknet::ContractAddress;

#[starknet::interface]
trait IFunctionRegistry<TContractState> {
    fn verifiers(self: @TContractState, function_id: u256) -> ContractAddress;
    fn verifier_owners(self: @TContractState, function_id: u256) -> ContractAddress;
    fn get_function_id(self: @TContractState, owner: ContractAddress, name: felt252) -> u256;
    fn register_function(
        ref self: TContractState, owner: ContractAddress, verifier: ContractAddress, name: felt252
    ) -> u256;
    fn deploy_and_register_function(
        ref self: TContractState, owner: ContractAddress, bytecode: Span<u8>, name: felt252
    ) -> (u256, ContractAddress);
    fn update_function(ref self: TContractState, verifier: ContractAddress, name: felt252) -> u256;
    fn deploy_and_update_function(
        ref self: TContractState, bytescode: Span<u8>, _name: felt252
    ) -> (u256, ContractAddress);
}
