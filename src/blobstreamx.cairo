#[starknet::contract]
mod blobstreamx {
    use alexandria_bytes::{Bytes, BytesTrait};
    use alexandria_encoding::sol_abi::{SolAbiEncodeTrait};
    use blobstream_sn::interfaces::{
        DataRoot, TendermintXErrors, IBlobstreamX, IDAOracle, ITendermintX
    };
    use blobstream_sn::mocks::evm_facts_registry::{
        IEVMFactsRegistryMockDispatcher, IEVMFactsRegistryMockDispatcherImpl
    };
    use blobstream_sn::tree::binary::merkle_proof::BinaryMerkleProof;
    use blobstream_sn::tree::binary::merkle_tree;
    use core::starknet::event::EventEmitter;
    use core::traits::Into;
    use openzeppelin::access::ownable::OwnableComponent;
    use openzeppelin::upgrades::{interface::IUpgradeable, upgradeable::UpgradeableComponent};
    use starknet::info::get_block_number;
    use starknet::{ClassHash, ContractAddress, get_contract_address};
    use succinct_sn::interfaces::{ISuccinctGatewayDispatcher, ISuccinctGatewayDispatcherTrait};

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);
    component!(path: UpgradeableComponent, storage: upgradeable, event: UpgradeableEvent);

    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;
    impl UpgradeableInternalImpl = UpgradeableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        data_commitment_max: u64,
        gateway: ContractAddress,
        latest_block: u64,
        state_proof_nonce: u64,
        state_data_commitments: LegacyMap::<u64, u256>,
        block_height_to_header_hash: LegacyMap::<u64, u256>,
        header_range_function_id: u256,
        next_header_function_id: u256,
        frozen: bool,
        herodotus_facts_registry: ContractAddress,
        blobstreamx_l1_contract: felt252,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        #[substorage(v0)]
        upgradeable: UpgradeableComponent::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        DataCommitmentStored: DataCommitmentStored,
        HeaderRangeRequested: HeaderRangeRequested,
        HeadUpdate: HeadUpdate,
        NextHeaderRequested: NextHeaderRequested,
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        #[flat]
        UpgradeableEvent: UpgradeableComponent::Event,
    }

    /// Data commitment stored for the block range [startBlock, endBlock] with proof nonce
    #[derive(Drop, starknet::Event)]
    struct DataCommitmentStored {
        // nonce of the proof
        proof_nonce: u64,
        // start block of the block range
        #[key]
        start_block: u64,
        // end block of the block range
        #[key]
        end_block: u64,
        // data commitment for the block range
        #[key]
        data_commitment: u256,
    }

    /// Inputs of a header range request
    #[derive(Drop, starknet::Event)]
    struct HeaderRangeRequested {
        // trusted block for the header range request
        #[key]
        trusted_block: u64,
        // header hash of the trusted block
        #[key]
        trusted_header: u256,
        // target block of the header range request
        target_block: u64
    }

    /// Inputs of a next header request
    #[derive(Drop, starknet::Event)]
    struct NextHeaderRequested {
        // trusted block for the next header request
        #[key]
        trusted_block: u64,
        // header hash of the trusted block
        #[key]
        trusted_header: u256,
    }

    /// Head Update
    #[derive(Drop, starknet::Event)]
    struct HeadUpdate {
        target_block: u64,
        target_header: u256
    }

    mod Errors {
        const DataCommitmentNotFound: felt252 = 'Bad data commitment for range';
        const ContractFrozen: felt252 = 'Contract is frozen';
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        gateway: ContractAddress,
        owner: ContractAddress,
        height: u64,
        header: u256,
        header_range_function_id: u256,
        next_header_function_id: u256,
        herodotus_facts_registry: ContractAddress,
        blobstreamx_l1_contract: felt252
    ) {
        self.data_commitment_max.write(1000);
        self.gateway.write(gateway);
        self.latest_block.write(height);
        self.state_proof_nonce.write(1);
        self.ownable.initializer(owner);
        self.block_height_to_header_hash.write(height, header);
        self.header_range_function_id.write(header_range_function_id);
        self.next_header_function_id.write(next_header_function_id);
        self.frozen.write(false);
        self.herodotus_facts_registry.write(herodotus_facts_registry);
        self.blobstreamx_l1_contract.write(blobstreamx_l1_contract);
    }

    #[abi(embed_v0)]
    impl Upgradeable of IUpgradeable<ContractState> {
        fn upgrade(ref self: ContractState, new_class_hash: ClassHash) {
            self.ownable.assert_only_owner();
            self.upgradeable._upgrade(new_class_hash);
        }
    }

    #[abi(embed_v0)]
    impl IDAOracleImpl of IDAOracle<ContractState> {
        fn verify_attestation(
            self: @ContractState, proof_nonce: u64, data_root: DataRoot, proof: BinaryMerkleProof
        ) -> bool {
            assert(!self.frozen.read(), Errors::ContractFrozen);

            if (proof_nonce >= self.state_proof_nonce.read()) {
                return false;
            }

            // load the tuple root at the given index from storage.
            let root: u256 = self.state_data_commitments.read(proof_nonce);

            let data_root_bytes = BytesTrait::new_empty()
                .encode_packed(data_root.height)
                .encode_packed(data_root.data_root);

            let (is_proof_valid, _) = merkle_tree::verify(root, @proof, @data_root_bytes);
            is_proof_valid
        }
    }

    #[abi(embed_v0)]
    impl ITendermintXImpl of ITendermintX<ContractState> {
        /// Get the header hash for a block height.
        /// # Arguments 
        /// * `_height` - the height to consider
        /// # Returns
        /// The associated hash
        fn get_header_hash(self: @ContractState, _height: u64) -> u256 {
            self.block_height_to_header_hash.read(_height)
        }
        fn get_latest_block(self: @ContractState) -> u64 {
            self.latest_block.read()
        }
    }

    #[abi(embed_v0)]
    impl IBlobstreamXImpl of IBlobstreamX<ContractState> {
        fn data_commitment_max(self: @ContractState) -> u64 {
            self.data_commitment_max.read()
        }
        fn set_gateway(ref self: ContractState, new_gateway: ContractAddress) {
            self.ownable.assert_only_owner();
            self.gateway.write(new_gateway);
        }
        fn get_gateway(self: @ContractState) -> ContractAddress {
            self.gateway.read()
        }

        fn get_state_proof_nonce(self: @ContractState) -> u64 {
            self.state_proof_nonce.read()
        }

        fn get_state_data_commitment(self: @ContractState, state_nonce: u64) -> u256 {
            self.state_data_commitments.read(state_nonce)
        }

        fn get_header_range_id(self: @ContractState) -> u256 {
            self.header_range_function_id.read()
        }

        fn set_header_range_id(ref self: ContractState, _function_id: u256) {
            self.ownable.assert_only_owner();
            self.header_range_function_id.write(_function_id);
        }

        fn get_next_header_id(self: @ContractState) -> u256 {
            self.next_header_function_id.read()
        }

        fn set_next_header_id(ref self: ContractState, _function_id: u256) {
            self.ownable.assert_only_owner();
            self.next_header_function_id.write(_function_id);
        }
        fn get_frozen(self: @ContractState) -> bool {
            self.frozen.read()
        }
        fn set_frozen(ref self: ContractState, _frozen: bool) {
            self.ownable.assert_only_owner();
            self.frozen.write(_frozen);
        }

        fn get_herodotus_facts_registry(self: @ContractState) -> ContractAddress {
            self.herodotus_facts_registry.read()
        }
        fn set_herodotus_facts_registry(ref self: ContractState, facts_registry: ContractAddress) {
            self.ownable.assert_only_owner();
            self.herodotus_facts_registry.write(facts_registry);
        }
        fn get_blobstreamx_l1_contract(self: @ContractState) -> felt252 {
            self.blobstreamx_l1_contract.read()
        }
        fn set_blobstreamx_l1_contract(ref self: ContractState, l1_contract: felt252) {
            self.ownable.assert_only_owner();
            self.blobstreamx_l1_contract.write(l1_contract);
        }

        /// Request a header_range proof for the next header hash and a data commitment for the block range [latest_block, _target_block).
        /// Used to skip from the latest block to the target block.
        ///
        /// # Arguments
        ///
        /// * `_target_block` - The end block of the header range proof.
        fn request_header_range(ref self: ContractState, _target_block: u64) {
            let latest_block = self.get_latest_block();
            let latest_header = self.block_height_to_header_hash.read(latest_block);
            assert(latest_header != 0, TendermintXErrors::LatestHeaderNotFound);
            // A request can be at most data_commitment_max blocks ahead of the latest block.
            assert(_target_block > latest_block, TendermintXErrors::TargetBlockNotInRange);
            assert(
                _target_block - latest_block <= self.data_commitment_max(),
                TendermintXErrors::TargetBlockNotInRange
            );

            let input = BytesTrait::new_empty()
                .encode_packed(latest_block)
                .encode_packed(latest_header)
                .encode_packed(_target_block);

            let entry_calldata = BytesTrait::new_empty()
                .encode_packed(selector!("commit_header_range"))
                .encode_packed(_target_block);

            ISuccinctGatewayDispatcher { contract_address: self.gateway.read() }
                .request_call(
                    self.header_range_function_id.read(),
                    input,
                    get_contract_address(),
                    entry_calldata,
                    500000
                );

            self
                .emit(
                    HeaderRangeRequested {
                        trusted_block: latest_block,
                        trusted_header: latest_header,
                        target_block: _target_block
                    }
                );
        }

        /// Commits the new header at targetBlock and the data commitment for the block range [trustedBlock, targetBlock).
        /// This is called as a callback from the gateway after a request_header_range.
        ///
        /// # Arguments 
        ///
        /// * `_target_block` -  The end block of the header range request
        fn commit_header_range(ref self: ContractState, _target_block: u64) {
            assert(!self.frozen.read(), Errors::ContractFrozen);

            let latest_block = self.get_latest_block();
            let trusted_header = self.block_height_to_header_hash.read(latest_block);
            assert(trusted_header != 0, TendermintXErrors::TrustedHeaderNotFound);

            assert(_target_block > latest_block, TendermintXErrors::TargetBlockNotInRange);
            assert(
                _target_block - latest_block <= self.data_commitment_max(),
                TendermintXErrors::TargetBlockNotInRange
            );

            let input = BytesTrait::new_empty()
                .encode_packed(latest_block)
                .encode_packed(trusted_header)
                .encode_packed(_target_block);

            // Get the output of the header_range proof from the gateway.
            let (target_header, data_commitment) = ISuccinctGatewayDispatcher {
                contract_address: self.get_gateway()
            }
                .verified_call(self.get_header_range_id(), input);

            let proof_nonce = self.get_state_proof_nonce();
            self.block_height_to_header_hash.write(_target_block, target_header);
            self.state_data_commitments.write(proof_nonce, data_commitment);
            self
                .emit(
                    DataCommitmentStored {
                        proof_nonce,
                        data_commitment,
                        start_block: latest_block,
                        end_block: _target_block,
                    }
                );
            self.emit(HeadUpdate { target_block: _target_block, target_header: target_header });
            self.state_proof_nonce.write(proof_nonce + 1);
            self.latest_block.write(_target_block);
        }


        /// Request a next_header proof for the next header hash and a data commitment for the block range [latest_block, latest_block + 1).
        /// Rarely used, only if the validator set changes by more than 2/3 in a single block.
        fn request_next_header(ref self: ContractState) {
            let latest_block = self.get_latest_block();
            let latest_header = self.block_height_to_header_hash.read(latest_block);
            assert(latest_header != 0, TendermintXErrors::LatestHeaderNotFound);

            let input = BytesTrait::new_empty()
                .encode_packed(latest_block)
                .encode_packed(latest_header);

            let entry_calldata = BytesTrait::new_empty()
                .encode_packed(selector!("commit_next_header"))
                .encode_packed(latest_block);

            ISuccinctGatewayDispatcher { contract_address: self.gateway.read() }
                .request_call(
                    self.next_header_function_id.read(),
                    input,
                    get_contract_address(),
                    entry_calldata,
                    500000
                );

            self
                .emit(
                    NextHeaderRequested {
                        trusted_block: latest_block, trusted_header: latest_header
                    }
                );
        }


        /// Stores the new header for _trustedBlock + 1 and the data commitment for the block range [_trustedBlock, _trustedBlock + 1).
        /// This is called as a callback from the gateway after a request_next_header.
        ///
        /// # Arguments
        ///
        /// * `_trusted_block` - The latest block when the request was made.
        fn commit_next_header(ref self: ContractState, _trusted_block: u64) {
            assert(!self.frozen.read(), Errors::ContractFrozen);

            let trusted_header = self.block_height_to_header_hash.read(_trusted_block);
            assert(trusted_header != 0, TendermintXErrors::TrustedHeaderNotFound);

            let next_block = _trusted_block + 1;
            assert(next_block > self.get_latest_block(), TendermintXErrors::TargetBlockNotInRange);

            let input = BytesTrait::new_empty()
                .encode_packed(_trusted_block)
                .encode_packed(trusted_header);

            // Get the output of the next_header proof from the gateway.
            let (next_header, data_commitment) = ISuccinctGatewayDispatcher {
                contract_address: self.gateway.read()
            }
                .verified_call(self.next_header_function_id.read(), input);

            let proof_nonce = self.get_state_proof_nonce();
            self.block_height_to_header_hash.write(next_block, next_header);
            self.state_data_commitments.write(proof_nonce, data_commitment);
            self
                .emit(
                    DataCommitmentStored {
                        proof_nonce,
                        data_commitment,
                        start_block: _trusted_block,
                        end_block: next_block
                    }
                );
            self.emit(HeadUpdate { target_block: next_block, target_header: next_header });
            self.state_proof_nonce.write(proof_nonce + 1);
            self.latest_block.write(next_block);
        }

        /// This assumes all existing data_commitments mappings match L1 Blobstream
        fn update_data_commitments_from_facts(ref self: ContractState, l1_block: u256) {
            assert(!self.frozen.read(), Errors::ContractFrozen);

            let herodotus_facts_registry = IEVMFactsRegistryMockDispatcher {
                contract_address: self.get_herodotus_facts_registry()
            };

            // Get the proof nonce for the new state data commitments
            let blobstreamx_l1_proof_nonce_slot: u256 = 0xfc;
            let new_state_proof_nonce = herodotus_facts_registry
                .get_slot_value(
                    self.blobstreamx_l1_contract.read(), l1_block, blobstreamx_l1_proof_nonce_slot
                );
            assert!(new_state_proof_nonce.is_some(), "No proof nonce found for block {}", l1_block);
            let new_state_proof_nonce: u64 = new_state_proof_nonce.unwrap().try_into().unwrap();
            assert!(
                new_state_proof_nonce > self.get_state_proof_nonce(),
                "State proof nonce does not increase on block {}",
                l1_block
            );

            // Loop though all the new state data commitments
            let blobstreamx_l1_data_commitment_map_slot: u256 = 0xfe;
            let mut current_proof_nonce = self.get_state_proof_nonce();
            while current_proof_nonce < new_state_proof_nonce {
                let dc_slot: u256 = BytesTrait::new_empty()
                    .encode(current_proof_nonce)
                    .encode(blobstreamx_l1_data_commitment_map_slot)
                    .keccak();
                let data_commitment = herodotus_facts_registry
                    .get_slot_value(self.blobstreamx_l1_contract.read(), l1_block, dc_slot);
                assert!(
                    data_commitment.is_some(),
                    "No data commitment found for block {} and proof nonce {}",
                    l1_block,
                    current_proof_nonce
                );
                self.state_data_commitments.write(current_proof_nonce, data_commitment.unwrap());
                current_proof_nonce += 1;
            };
            self.state_proof_nonce.write(new_state_proof_nonce);
        }
    }
}
