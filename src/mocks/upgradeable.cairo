use starknet::{ClassHash, ContractAddress};

#[starknet::interface]
trait IMockUpgradeable<TState> {
    fn upgrade(ref self: TState, new_class_hash: ClassHash);
    fn set_gateway_v2(ref self: TState, new_gateway: ContractAddress);
    fn get_gateway_v2(self: @TState) -> ContractAddress;
}


#[starknet::contract]
mod MockUpgradeable {
    use openzeppelin::upgrades::UpgradeableComponent;
    use starknet::{ClassHash, ContractAddress};

    component!(path: UpgradeableComponent, storage: upgradeable, event: UpgradeableEvent);
    impl InternalImpl = UpgradeableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        upgradeable: UpgradeableComponent::Storage,
        gateway: ContractAddress
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        UpgradeableEvent: UpgradeableComponent::Event
    }

    #[abi(embed_v0)]
    impl MockUpgradeable of super::IMockUpgradeable<ContractState> {
        fn upgrade(ref self: ContractState, new_class_hash: ClassHash) {
            self.upgradeable._upgrade(new_class_hash);
        }
        fn set_gateway_v2(ref self: ContractState, new_gateway: ContractAddress) {
            self.gateway.write(new_gateway);
        }

        fn get_gateway_v2(self: @ContractState) -> ContractAddress {
            self.gateway.read()
        }
    }
}
