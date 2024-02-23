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
    use alexandria_bytes::{Bytes, BytesTrait};
    use blobstream_sn::succinctx::function_registry::interfaces::IFunctionRegistry;
    use core::traits::Into;
    use starknet::info::get_caller_address;
    use starknet::{ContractAddress, contract_address_const};
    use super::errors;

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

    #[embeddable_as(FunctionRegistryImpl)]
    impl FunctionRegistry<
        TContractState, +HasComponent<TContractState>
    > of IFunctionRegistry<ComponentState<TContractState>> {
        fn verifiers(self: @ComponentState<TContractState>, function_id: u256) -> ContractAddress {
            self.verifiers.read(function_id)
        }
        fn verifier_owners(
            self: @ComponentState<TContractState>, function_id: u256
        ) -> ContractAddress {
            self.verifier_owners.read(function_id)
        }
        fn get_function_id(
            self: @ComponentState<TContractState>, owner: ContractAddress, name: felt252
        ) -> u256 {
            let mut function_id_digest: Bytes = BytesTrait::new(0, array![]);
            function_id_digest.append_felt252(owner.into());
            function_id_digest.append_felt252(name);
            function_id_digest.keccak()
        }
        fn register_function(
            ref self: ComponentState<TContractState>,
            owner: ContractAddress,
            verifier: ContractAddress,
            name: felt252
        ) -> u256 {
            assert(verifier.is_non_zero(), errors::VERIFIER_CANNOT_BE_ZERO);

            let mut function_id_digest: Bytes = BytesTrait::new(0, array![]);
            function_id_digest.append_felt252(owner.into());
            function_id_digest.append_felt252(name);
            let function_id = function_id_digest.keccak();

            assert(self.verifiers.read(function_id).is_zero(), errors::FUNCTION_ALREADY_REGISTERED);

            self.verifier_owners.write(function_id, owner);
            self.verifiers.write(function_id, verifier);

            self.emit(FunctionRegistered { function_id, verifier, name, owner, });

            function_id
        }
        fn update_function(
            ref self: ComponentState<TContractState>, verifier: ContractAddress, name: felt252
        ) -> u256 {
            assert(verifier.is_non_zero(), errors::VERIFIER_CANNOT_BE_ZERO);

            let caller = get_caller_address();
            let mut function_id_digest: Bytes = BytesTrait::new(0, array![]);
            function_id_digest.append_felt252(caller.into());
            function_id_digest.append_felt252(name);
            let function_id = function_id_digest.keccak();

            assert(self.verifier_owners.read(function_id) != caller, errors::NOT_FUNCTION_OWNER);
            assert(self.verifiers.read(function_id) == verifier, errors::VERIFIER_ALREADY_UPDATED);

            self.verifiers.write(function_id, verifier);
            self.emit(FunctionVerifierUpdated { function_id, verifier });

            function_id
        }
    }
}
