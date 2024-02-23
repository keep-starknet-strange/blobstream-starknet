#[starknet::contract]
mod blobstreamx {
    use alexandria_bytes::{Bytes, BytesTrait};
    use blobstream_sn::interfaces::{
        DataRoot, TendermintXErrors, IBlobstreamX, IDAOracle, ITendermintX
    };
    use blobstream_sn::succinctx::interfaces::{
        ISuccinctGatewayDispatcher, ISuccinctGatewayDispatcherTrait
    };
    use blobstream_sn::tree::binary::merkle_proof::BinaryMerkleProof;
    use core::starknet::event::EventEmitter;
    use core::traits::Into;
    use openzeppelin::access::ownable::OwnableComponent;
    use openzeppelin::upgrades::{interface::IUpgradeable, upgradeable::UpgradeableComponent};
    use starknet::info::{get_block_number, get_contract_address};
    use starknet::{ClassHash, ContractAddress};

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
        const DataCommitmentNotFound: felt252 = 'bad data commitment for range';
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
    ) {
        self.data_commitment_max.write(1000);
        self.gateway.write(gateway);
        self.latest_block.write(height);
        self.state_proof_nonce.write(1);
        self.ownable.initializer(owner);
        self.block_height_to_header_hash.write(height, header);
        self.header_range_function_id.write(header_range_function_id);
        self.next_header_function_id.write(next_header_function_id);
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
            self: @ContractState, proof_nonce: u64, root: DataRoot, proof: BinaryMerkleProof
        ) -> bool {
            if (proof_nonce >= self.state_proof_nonce.read()) {
                return false;
            }

            // load the tuple root at the given index from storage.
            let _data_root = self.state_data_commitments.read(proof_nonce);

            // return isProofValid;
            // TODO(#69 + #24): BinaryMerkleTree.verify(root, _proof, abi.encode(_tuple));
            false
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

        /// Prove the validity of the header at the target block and a data commitment for the block range [latestBlock, _targetBlock).
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

            let mut input = BytesTrait::new_empty();
            input.append_u64(latest_block);
            input.append_u256(latest_header);
            input.append_u64(_target_block);

            let mut entry_calldata = BytesTrait::new_empty();
            entry_calldata.append_felt252(selector!("commit_header_range"));
            entry_calldata.append_u64(latest_block);
            entry_calldata.append_u64(_target_block);

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
        ///
        /// # Arguments 
        ///
        /// * `_target_block` -  The end block of the header range request
        fn commit_header_range(ref self: ContractState, _target_block: u64) {
            let latest_block = self.get_latest_block();
            let trusted_header = self.block_height_to_header_hash.read(latest_block);
            assert(trusted_header != 0, TendermintXErrors::TrustedHeaderNotFound);

            assert(_target_block > latest_block, TendermintXErrors::TargetBlockNotInRange);
            assert(
                _target_block - latest_block <= self.data_commitment_max(),
                TendermintXErrors::TargetBlockNotInRange
            );

            let mut input = BytesTrait::new_empty();
            input.append_u64(latest_block);
            input.append_u256(trusted_header);
            input.append_u64(_target_block);

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
            self.emit(HeadUpdate { target_block: latest_block, target_header: target_header });
            self.state_proof_nonce.write(proof_nonce + 1);
            self.latest_block.write(_target_block);
        }


        /// Prove the validity of the next header and a data commitment for the block range [latestBlock, latestBlock + 1).
        fn request_next_header(ref self: ContractState) {
            let latest_block = self.get_latest_block();
            let latest_header = self.block_height_to_header_hash.read(latest_block);
            assert(latest_header != 0, TendermintXErrors::LatestHeaderNotFound);

            let mut input = BytesTrait::new_empty();
            input.append_u64(latest_block);
            input.append_u256(latest_header);

            let mut entry_calldata = BytesTrait::new_empty();
            entry_calldata.append_felt252(selector!("commit_next_header"));
            entry_calldata.append_u64(latest_block);

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
        ///
        /// # Arguments
        ///
        /// * `_trusted_block` - The latest block when the request was made.
        fn commit_next_header(ref self: ContractState, _trusted_block: u64) {
            let trusted_header = self.block_height_to_header_hash.read(_trusted_block);
            assert(trusted_header != 0, TendermintXErrors::TrustedHeaderNotFound);

            let next_block = _trusted_block + 1;
            assert(next_block > self.get_latest_block(), TendermintXErrors::TargetBlockNotInRange);

            let mut input = BytesTrait::new_empty();
            input.append_u64(_trusted_block);
            input.append_u256(trusted_header);

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
    }
}
