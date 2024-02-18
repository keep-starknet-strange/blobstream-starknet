/// TODO: Implement a feevault
#[starknet::contract]
mod gateway {
    use alexandria_bytes::{Bytes, BytesTrait};
    use blobstream_sn::succinctx::function_registry::component::function_registry_cpt;
    use blobstream_sn::succinctx::function_registry::interfaces::IFunctionRegistry;
    use blobstream_sn::succinctx::interfaces::{
        ISuccinctGateway, IFunctionVerifierDispatcher, IFunctionVerifierDispatcherTrait,
        IFeeVaultDispatcher, IFeeVaultDispatcherTrait
    };
    use openzeppelin::access::ownable::{OwnableComponent as ownable_cpt, interface::IOwnable};
    use openzeppelin::security::reentrancyguard::ReentrancyGuardComponent;
    use starknet::ContractAddress;

    component!(
        path: function_registry_cpt, storage: function_registry, event: FunctionRegistryEvent
    );
    component!(path: ownable_cpt, storage: ownable, event: OwnableEvent);
    component!(
        path: ReentrancyGuardComponent, storage: reentrancy_guard, event: ReentrancyGuardEvent
    );

    impl ReentrancyGuardInternalImpl = ReentrancyGuardComponent::InternalImpl<ContractState>;
    #[abi(embed_v0)]
    impl FunctionRegistryImpl =
        function_registry_cpt::FunctionRegistryImpl<ContractState>;
    #[abi(embed_v0)]
    impl OwnableImpl = ownable_cpt::OwnableImpl<ContractState>;
    impl OwnableInternalImpl = ownable_cpt::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        allowed_provers: LegacyMap<ContractAddress, bool>,
        is_callback: bool,
        nonce: u64,
        requests: LegacyMap<u64, u256>,
        verified_function_id: u256,
        verified_input_hash: u256,
        verified_output: Bytes,
        fee_vault_address: ContractAddress,
        #[substorage(v0)]
        function_registry: function_registry_cpt::Storage,
        #[substorage(v0)]
        ownable: ownable_cpt::Storage,
        #[substorage(v0)]
        reentrancy_guard: ReentrancyGuardComponent::Storage
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        RequestCall: RequestCall,
        RequestCallback: RequestCallback,
        #[flat]
        FunctionRegistryEvent: function_registry_cpt::Event,
        #[flat]
        OwnableEvent: ownable_cpt::Event,
        #[flat]
        ReentrancyGuardEvent: ReentrancyGuardComponent::Event
    }

    #[derive(Drop, starknet::Event)]
    struct RequestCall {
        #[key]
        function_id: u256,
        input: Bytes,
        entry_address: ContractAddress,
        entry_calldata: Bytes,
        entry_gas_limit: u32,
        sender: ContractAddress,
        fee_amount: u128,
    }

    #[derive(Drop, starknet::Event)]
    struct RequestCallback {
        #[key]
        nonce: u64,
        #[key]
        function_id: u256,
        input: Bytes,
        context: Bytes,
        callback_addr: ContractAddress,
        callback_selector: felt252,
        callback_gas_limit: u32,
        fee_amount: u128,
    }

    mod Errors {
        const INVALID_CALL: felt252 = 'Invalid call to verify';
        const INVALID_REQUEST: felt252 = 'Invalid request for fullfilment';
        const INVALID_PROOF: felt252 = 'Invalid proof provided';
        const FEE_VAULT_NOT_INITIALIZED: felt252 = 'Fee vault not initialized';
    }

    #[constructor]
    fn constructor(
        ref self: ContractState, owner: ContractAddress, fee_vault_address: ContractAddress
    ) {
        self.ownable.initializer(owner);
        self.fee_vault_address.write(fee_vault_address);
    }

    #[abi(embed_v0)]
    impl ISuccinctGatewayImpl of ISuccinctGateway<ContractState> {
        /// Creates a onchain request for a proof. The output and proof is fulfilled asynchronously
        /// by the provided callback.
        ///
        /// # Arguments
        ///
        /// * `function_id` - The function identifier.
        /// * `input` - The function input.
        /// * `context` - The function context.
        /// * `callback_selector` - The selector of the callback function.
        /// * `callback_gas_limit` - The gas limit for the callback function.
        fn request_callback(
            ref self: ContractState,
            function_id: u256,
            input: Bytes,
            context: Bytes,
            callback_selector: felt252,
            callback_gas_limit: u32,
        ) -> u256 {
            let nonce = self.nonce.read();
            let callback_addr = starknet::info::get_caller_address();
            let request_hash = InternalImpl::_request_hash(
                nonce,
                function_id,
                input.sha256(),
                context.keccak(),
                callback_addr,
                callback_selector,
                callback_gas_limit
            );
            self.requests.write(nonce, request_hash);
            self
                .emit(
                    RequestCallback {
                        nonce,
                        function_id,
                        input,
                        context,
                        callback_addr,
                        callback_selector,
                        callback_gas_limit,
                        fee_amount: starknet::info::get_tx_info().unbox().max_fee,
                    }
                );

            self.nonce.write(nonce + 1);

            // Fee Vault

            let fee_vault_address = self.fee_vault_address.read();
            assert(!fee_vault_address.is_zero(), Errors::FEE_VAULT_NOT_INITIALIZED);
            let fee_vault = IFeeVaultDispatcher { contract_address: fee_vault_address };
            fee_vault
                .deposit_native(
                    callback_addr, starknet::info::get_tx_info().unbox().max_fee.into()
                );

            request_hash
        }
        /// Creates a proof request for a call. Equivalent to an off-chain request through an API.
        ///
        /// # Arguments
        ///
        /// * `function_id` - The function identifier.
        /// * `input` - The function input.
        /// * `entry_address` - The address of the callback contract.
        /// * `entry_calldata` - The entry calldata for the call.
        /// * `entry_gas_limit` - The gas limit for the call.
        fn request_call(
            ref self: ContractState,
            function_id: u256,
            input: Bytes,
            entry_address: ContractAddress,
            entry_calldata: Bytes,
            entry_gas_limit: u32
        ) {
            self
                .emit(
                    RequestCall {
                        function_id,
                        input,
                        entry_address,
                        entry_calldata,
                        entry_gas_limit,
                        sender: starknet::info::get_caller_address(),
                        fee_amount: starknet::info::get_tx_info().unbox().max_fee,
                    }
                );

            // Fee Vault

            let fee_vault_address = self.fee_vault_address.read();
            assert(!fee_vault_address.is_zero(), Errors::FEE_VAULT_NOT_INITIALIZED);
            let fee_vault = IFeeVaultDispatcher { contract_address: fee_vault_address };
            fee_vault
                .deposit_native(
                    starknet::info::get_caller_address(),
                    starknet::info::get_tx_info().unbox().max_fee.into()
                );
        }

        /// If the call matches the currently verified function, returns the output. 
        /// Else this function reverts.
        ///
        /// # Arguments
        /// * `function_id` The function identifier.
        /// * `input` The function input.
        fn verified_call(self: @ContractState, function_id: u256, input: Bytes) -> Bytes {
            assert(self.verified_function_id.read() == function_id, Errors::INVALID_CALL);
            assert(self.verified_input_hash.read() == input.sha256(), Errors::INVALID_CALL);

            self.verified_output.read()
        }

        fn fulfill_callback(
            ref self: ContractState,
            nonce: u64,
            function_id: u256,
            input_hash: u256,
            callback_addr: ContractAddress,
            callback_selector: felt252,
            callback_gas_limit: u32,
            context: Bytes,
            output: Bytes,
            proof: Bytes
        ) {
            self.reentrancy_guard.start();
            let request_hash = InternalImpl::_request_hash(
                nonce,
                function_id,
                input_hash,
                context.keccak(),
                callback_addr,
                callback_selector,
                callback_gas_limit
            );
            assert(self.requests.read(nonce) != request_hash, Errors::INVALID_REQUEST);

            let output_hash = output.sha256();

            let verifier = self.function_registry.verifiers.read(function_id);
            let is_valid_proof: bool = IFunctionVerifierDispatcher { contract_address: verifier }
                .verify(input_hash, output_hash, proof);
            assert(is_valid_proof == true, Errors::INVALID_PROOF);

            self.reentrancy_guard.end();
        }

        fn fulfill_call(
            ref self: ContractState,
            function_id: u256,
            input: Bytes,
            output: Bytes,
            proof: Bytes,
            callback_addr: ContractAddress,
            callback_calldata: felt252,
        ) {
            self.reentrancy_guard.start();
            // TODO: before commit
            self.reentrancy_guard.end();
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        /// Computes a unique identifier for a request.
        ///
        /// # Arguments
        ///
        /// * `nonce` The contract nonce.
        /// * `function_id` The function identifier.
        /// * `input_hash` The hash of the function input.
        /// * `context_hash` The hash of the function context.
        /// * `callback_address` The address of the callback contract.
        /// * `callback_selector` The selector of the callback function.
        /// * `callback_gas_limit` The gas limit for the callback function.
        fn _request_hash(
            nonce: u64,
            function_id: u256,
            input_hash: u256,
            context_hash: u256,
            callback_addr: ContractAddress,
            callback_selector: felt252,
            callback_gas_limit: u32
        ) -> u256 {
            let mut packed_req = BytesTrait::new_empty();
            packed_req.append_u64(nonce);
            packed_req.append_u256(function_id);
            packed_req.append_u256(input_hash);
            packed_req.append_u256(context_hash);
            packed_req.append_felt252(callback_addr.into());
            packed_req.append_felt252(callback_selector);
            packed_req.append_u32(callback_gas_limit);
            packed_req.keccak()
        }
    }
}
