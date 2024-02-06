mod interfaces;
mod tree;
mod verifier;

#[starknet::contract]
mod BlobstreamX {
    use blobstream_sn::interfaces::{IBlobstreamX, IDAOracle, DataRoot};
    use blobstream_sn::tree::binary::merkle_proof::BinaryMerkleProof;
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
        proof_nonce: felt252,
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
        trusted_header: u64,
    }

    mod Errors {
        /// data commitment for specified block range does not exist
        const DataCommitmentNotFound: felt252 = 'Data commitment not found';
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
