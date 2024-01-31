#[starknet::interface]
trait IMockUpgraded<TContractState> {
    fn get_version(self: @TContractState) -> bool;
}

#[starknet::contract]
mod MockUpgraded {
    #[storage]
    struct Storage {}
    #[abi(embed_v0)]
    impl MockUpgraded of super::IMockUpgraded<ContractState> {
        fn get_version(self: @ContractState) -> bool {
            return true;
        }
    }
}
