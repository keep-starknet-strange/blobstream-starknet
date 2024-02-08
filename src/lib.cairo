mod interfaces;
mod tree;
mod verifier;

#[starknet::contract]
mod BlobstreamX {
    use alexandria_bytes::Bytes;
    use alexandria_bytes::BytesTrait;
    use blobstream_sn::interfaces::{IBlobstreamX, IDAOracle, DataRoot, InitParameters};
    use blobstream_sn::tree::binary::merkle_proof::BinaryMerkleProof;
    use core::starknet::event::EventEmitter;
    use core::traits::Into;
    use openzeppelin::access::ownable::OwnableComponent;
    use openzeppelin::upgrades::{interface::IUpgradeable, upgradeable::UpgradeableComponent};
    use starknet::info::get_block_number;
    use starknet::{ClassHash, ContractAddress};

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);
    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    component!(path: UpgradeableComponent, storage: upgradeable, event: UpgradeableEvent);
    impl UpgradeableInternalImpl = UpgradeableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        // CONTRACT STORAGE
        DATA_COMMITMENT_MAX: u64,
        gateway: ContractAddress,
        latest_block: u64,
        state_proof_nonce: u64,
        state_data_commitments: LegacyMap::<u64, u256>,
        block_height_to_header_hash: LegacyMap::<u64, u256>,
        header_range_function_id: u256,
        next_header_function_id: u256,
        // COMPONENT STORAGE
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        #[substorage(v0)]
        upgradeable: UpgradeableComponent::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        // CONTRACT EVENTS
        // TODO(#68): impl header range
        DataCommitmentStored: DataCommitmentStored,
        NextHeaderRequested: NextHeaderRequested,
        HeadUpdate: HeadUpdate,
        // COMPONENT EVENTS
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
        /// data commitment for specified block range does not exist
        const DataCommitmentNotFound: felt252 = 'Data commitment not found';
        const TrustedHeaderNotFound: felt252 = 'Trusted header not found';
        const TargetBlockNotInRange: felt252 = 'Target block not in range';
        const LatestHeaderNotFound: felt252 = 'Latest header not found';
    }

    #[constructor]
    fn constructor(ref self: ContractState, gateway: ContractAddress, owner: ContractAddress) {
        self.DATA_COMMITMENT_MAX.write(1000);
        self.gateway.write(gateway);
        self.latest_block.write(get_block_number());
        self.state_proof_nonce.write(1);
        self.ownable.initializer(owner);
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
            let data_root = self.state_data_commitments.read(proof_nonce);

            // return isProofValid;
            // TODO(#69 + #24): BinaryMerkleTree.verify(root, _proof, abi.encode(_tuple));
            false
        }
    }

    #[abi(embed_v0)]
    impl IBlobstreamXImpl of IBlobstreamX<ContractState> {
        fn DATA_COMMITMENT_MAX(self: @ContractState) -> u64 {
            self.DATA_COMMITMENT_MAX.read()
        }
        fn set_gateway(ref self: ContractState, new_gateway: ContractAddress) {
            self.ownable.assert_only_owner();
            self.gateway.write(new_gateway);
        }
        fn get_gateway(self: @ContractState) -> ContractAddress {
            self.gateway.read()
        }
        fn get_latest_block(self: @ContractState) -> u64 {
            self.latest_block.read()
        }
        fn get_state_proof_nonce(self: @ContractState) -> u64 {
            self.state_proof_nonce.read()
        }

        /// @notice Commits the new header at targetBlock and the data commitment for the block range [trustedBlock, targetBlock).
        /// # Arguments 
        /// * `_trustedBlock` -  The latest block when the request was made.
        /// * `_target_block` -  The end block of the header range request
        fn commit_header_range(ref self: ContractState, _trusted_block: u64, _target_block: u64) {
            let trusted_header = self.block_height_to_header_hash.read(_trusted_block);
            let latest_block = self.get_latest_block();
            let state_proof_nonce = self.get_state_proof_nonce();
            assert(trusted_header != 0, Errors::TrustedHeaderNotFound);
            let mut bytes: Bytes = BytesTrait::new(0, array![0]);
            bytes.append_u64(_trusted_block);
            bytes.append_u256(trusted_header);
            bytes.append_u64(_target_block);

            // MOCK INFORMATION FOR NOW 
            //TODO(#73): SunccinctGateway 
            // let request_result = ISuccinctGateway...
            let request_result: Bytes = BytesTrait::new(0, array![0]);
            let (_, data_commitment) = request_result.read_u256(0);
            let (_, target_header) = request_result.read_u256(0);

            assert(_target_block > latest_block, Errors::TargetBlockNotInRange);
            assert(
                _target_block - latest_block <= self.DATA_COMMITMENT_MAX(),
                Errors::TargetBlockNotInRange
            );
            self.block_height_to_header_hash.write(_target_block, target_header);
            self.state_data_commitments.write(state_proof_nonce, data_commitment);

            self
                .emit(
                    DataCommitmentStored {
                        proof_nonce: state_proof_nonce,
                        start_block: _trusted_block,
                        end_block: _target_block,
                        data_commitment: data_commitment
                    }
                );
            self.emit(HeadUpdate { target_block: _trusted_block, target_header: target_header });
            self.state_proof_nonce.write(state_proof_nonce + 1);
            self.latest_block.write(_target_block);
        }


        /// Prove the validity of the next header and a data commitment for the block range [latestBlock, latestBlock + 1).
        fn request_next_header(ref self: ContractState) {
            let latest_block = self.get_latest_block();
            let latest_header = self.block_height_to_header_hash.read(latest_block);
            assert(latest_header != 0, Errors::LatestHeaderNotFound);

            //TODO(#73): SunccinctGateway 
            // ISuccintGateway... 

            self
                .emit(
                    NextHeaderRequested {
                        trusted_block: latest_block, trusted_header: latest_header
                    }
                );
        }


        /// Stores the new header for _trustedBlock + 1 and the data commitment for the block range [_trustedBlock, _trustedBlock + 1).
        /// # Arguments
        /// * `_trusted_block` - The latest block when the request was made.
        fn commit_next_header(ref self: ContractState, _trusted_block: u64) {
            let trusted_header = self.block_height_to_header_hash.read(_trusted_block);
            let state_proof_nonce = self.get_state_proof_nonce();
            let latest_block = self.latest_block.read();
            assert(trusted_header != 0, Errors::TrustedHeaderNotFound);
            let mut bytes: Bytes = BytesTrait::new(0, array![0]);
            bytes.append_u64(_trusted_block);
            bytes.append_u256(trusted_header);

            // MOCK INFORMATION FOR NOW 
            //TODO(#73): SunccinctGateway 
            // let request_result = ISuccinctGateway...

            let request_result: Bytes = BytesTrait::new(0, array![0]);
            let (_, data_commitment) = request_result.read_u256(0);
            let (_, next_header) = request_result.read_u256(0);

            let next_block = _trusted_block + 1;
            assert(next_block > latest_block, Errors::TargetBlockNotInRange);
            self.block_height_to_header_hash.write(next_block, next_header);
            self.state_data_commitments.write(state_proof_nonce, data_commitment);
            self
                .emit(
                    DataCommitmentStored {
                        proof_nonce: state_proof_nonce,
                        start_block: _trusted_block,
                        end_block: next_block,
                        data_commitment: data_commitment
                    }
                );
            self.emit(HeadUpdate { target_block: next_block, target_header: next_header });
            self.state_proof_nonce.write(state_proof_nonce + 1);
            self.latest_block.write(next_block);
        }

        /// Get the header hash for a block height.
        /// # Arguments 
        /// * `_height` - the height to consider
        /// # Returns
        /// The associated hash
        fn get_header_hash(self: @ContractState, _height: u64) -> u256 {
            self.block_height_to_header_hash.read(_height)
        }
    }
}

mod mocks {
    mod upgradeable;
}

#[cfg(test)]
mod tests {
    mod common;
    mod test_blobstreamx;
    mod test_ownable;
    mod test_upgradeable;
}
