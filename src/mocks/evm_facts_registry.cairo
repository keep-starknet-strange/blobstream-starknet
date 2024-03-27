// Mock contract for the herodotus-on-starknet EVMFactsRegistry contract
// Only mocking the slot_values portion, the rest can be treated as a black box
// https://github.com/HerodotusDev/herodotus-on-starknet/blob/develop/src/core/evm_facts_registry.cairo

#[starknet::interface]
trait IEVMFactsRegistryMock<TContractState> {
    // @notice Returns a proven storage slot value
    // @param account: The account to query
    // @param block: The block number
    // @param slot: The slot to query
    // @return The value of the slot, if the slot is not proven, returns None
    fn get_slot_value(
        self: @TContractState, account: felt252, block: u256, slot: u256
    ) -> Option<u256>;

    // Testing only function, not safe nor included in the actual contract
    fn set_slot_value(
        ref self: TContractState, account: felt252, block: u256, slot: u256, value: u256
    );
}

#[starknet::contract]
mod EVMFactsRegistryMock {
    #[storage]
    struct Storage {
        // (account_address, block_number, slot) => value
        slot_values: LegacyMap::<(felt252, u256, u256), Option<u256>>
    }

    #[constructor]
    fn constructor(ref self: ContractState) {}

    #[abi(embed_v0)]
    impl EVMFactsRegistryMockImpl of super::IEVMFactsRegistryMock<ContractState> {
        fn get_slot_value(
            self: @ContractState, account: felt252, block: u256, slot: u256
        ) -> Option<u256> {
            self.slot_values.read((account, block, slot))
        }

        fn set_slot_value(
            ref self: ContractState, account: felt252, block: u256, slot: u256, value: u256
        ) {
            self.slot_values.write((account, block, slot), Option::Some(value));
        }
    }
}
