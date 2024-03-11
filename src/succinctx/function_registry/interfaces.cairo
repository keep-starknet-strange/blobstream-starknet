use starknet::ContractAddress;

#[starknet::interface]
trait IFunctionRegistry<TContractState> {
    fn get_verifier(self: @TContractState, function_id: u256) -> ContractAddress;
    fn get_verifier_owner(self: @TContractState, function_id: u256) -> ContractAddress;
    fn get_function_id(self: @TContractState, owner: ContractAddress, name: felt252) -> u256;
    fn register_function(
        ref self: TContractState, owner: ContractAddress, verifier: ContractAddress, name: felt252
    ) -> u256;
    fn update_function(ref self: TContractState, verifier: ContractAddress, name: felt252) -> u256;
}
