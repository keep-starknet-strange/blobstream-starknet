mod interfaces;
mod tree;
mod verifier;

#[starknet::contract]
mod BlobstreamX {
    use openzeppelin::access::ownable::OwnableComponent;
    use openzeppelin::upgrades::{interface::IUpgradeable, upgradeable::UpgradeableComponent};
    use starknet::ClassHash;
    use starknet::ContractAddress;

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);
    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    component!(path: UpgradeableComponent, storage: upgradeable, event: UpgradeableEvent);
    impl UpgradeableInternalImpl = UpgradeableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        #[substorage(v0)]
        upgradeable: UpgradeableComponent::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        // component events(OZ)
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        #[flat]
        UpgradeableEvent: UpgradeableComponent::Event,
        // contract events
        DataCommitmentStored: DataCommitmentStored,
        NextHeaderRequested: NextHeaderRequested,
    // TODO(#68): impl header range
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
        /// Data commitment for specified block range does not exist
        const DataCommitmentNotFound: felt252 = 'Data commitment not found';
    }

    #[abi(embed_v0)]
    impl Upgradeable of IUpgradeable<ContractState> {
        fn upgrade(ref self: ContractState, new_class_hash: ClassHash) {
            self.ownable.assert_only_owner();
            self.upgradeable._upgrade(new_class_hash);
        }
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self.ownable.initializer(owner);
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
