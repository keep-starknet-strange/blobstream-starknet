mod interfaces;
mod tree;
mod utils;
mod verifier;


#[starknet::contract]
mod BlobstreamX {
    use blobstream_sn::interfaces::{IUpgradeable};
    use openzeppelin::access::ownable::OwnableComponent;
    use openzeppelin::access::ownable::interface::IOwnable;
    use openzeppelin::access::ownable::ownable::OwnableComponent::InternalTrait as OwnableInternalTrait;
    use openzeppelin::upgrades::upgradeable::UpgradeableComponent;
    use starknet::ClassHash;
    use starknet::ContractAddress;

    // Components.
    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);
    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    component!(path: UpgradeableComponent, storage: upgradeable, event: UpgradeableEvent);
    impl UpgradeableInternalImpl = UpgradeableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        // Ownable component for access controlled methods.
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        // Upgradeable component for upgrade utility.
        #[substorage(v0)]
        upgradeable: UpgradeableComponent::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        #[flat]
        UpgradeableEvent: UpgradeableComponent::Event,
    }

    #[abi(embed_v0)]
    impl Upgradeable of IUpgradeable<ContractState> {
        fn upgrade(ref self: ContractState, new_hash: ClassHash) {
            self.ownable.assert_only_owner();
            self.upgradeable._upgrade(new_hash);
        }
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self.ownable.initializer(owner);
    }
}

#[cfg(test)]
mod tests {
    mod common;
    mod test_blobstreamx;
    mod test_ownable;
    mod test_upgradeable;
    mod mocks {
        mod upgradeable;
    }
}
