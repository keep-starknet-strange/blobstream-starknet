mod errors {
    const EMPTY_BYTECODE: felt252 = 'EMPTY_BYTECODE';
    const FAILED_DEPLOY: felt252 = 'FAILED_DEPLOY';
    const VERIFIER_CANNOT_BE_ZERO: felt252 = 'VERIFIER_CANNOT_BE_ZERO';
    const VERIFIER_ALREADY_UPDATED: felt252 = 'VERIFIER_ALREADY_UPDATED';
    const FUNCTION_ALREADY_REGISTERED: felt252 = 'FUNCTION_ALREADY_REGISTERED';
    const NOT_FUNCTION_OWNER: felt252 = 'NOT_FUNCTION_OWNER';
}

#[starknet::component]
mod function_registry_cpt {
    use blobstream_sn::succinctx::function_registry::interfaces::IFunctionRegistry;
    use starknet::{ContractAddress, contract_address_const};

    #[storage]
    struct Storage {
        verifiers: LegacyMap<u256, ContractAddress>,
        verifier_owners: LegacyMap<u256, ContractAddress>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        FunctionRegistered: FunctionRegistered,
        FunctionVerifierUpdated: FunctionVerifierUpdated,
        Deployed: Deployed,
    }

    #[derive(Drop, starknet::Event)]
    struct FunctionRegistered {
        #[key]
        function_id: u256,
        verifier: ContractAddress,
        name: felt252,
        owner: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct FunctionVerifierUpdated {
        #[key]
        function_id: u256,
        verifier: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct Deployed {
        #[key]
        bytecode_hash: u256,
        #[key]
        salt: u256,
        #[key]
        deployed_address: ContractAddress,
    }

    #[embeddable_as(FunctionRegistryImpl)]
    impl FunctionRegistry<
        TContractState, +HasComponent<TContractState>
    > of IFunctionRegistry<ComponentState<TContractState>> {
        fn verifiers(self: @ComponentState<TContractState>, function_id: u256) -> ContractAddress {
            contract_address_const::<1>()
        }
        fn verifier_owners(
            self: @ComponentState<TContractState>, function_id: u256
        ) -> ContractAddress {
            contract_address_const::<1>()
        }
        fn get_function_id(
            self: @ComponentState<TContractState>, owner: ContractAddress, name: felt252
        ) -> u256 {
            1
        }
        fn register_function(
            ref self: ComponentState<TContractState>,
            owner: ContractAddress,
            verifier: ContractAddress,
            name: felt252
        ) -> u256 {
            1
        }
        fn deploy_and_register_function(
            ref self: ComponentState<TContractState>,
            owner: ContractAddress,
            bytecode: Span<u8>,
            name: felt252
        ) -> (u256, ContractAddress) {
            (1, contract_address_const::<1>())
        }
        fn update_function(
            ref self: ComponentState<TContractState>, verifier: ContractAddress, name: felt252
        ) -> u256 {
            1
        }
        fn deploy_and_update_function(
            ref self: ComponentState<TContractState>, bytescode: Span<u8>, _name: felt252
        ) -> (u256, ContractAddress) {
            (1, contract_address_const::<1>())
        }
    }
}
