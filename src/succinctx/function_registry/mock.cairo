#[starknet::contract]
mod function_registry_mock {
    use blobstream_sn::succinctx::function_registry::component::function_registry_cpt;
    use blobstream_sn::succinctx::function_registry::interfaces::IFunctionRegistry;
    use starknet::ContractAddress;

    component!(
        path: function_registry_cpt, storage: function_registry, event: FunctionRegistryEvent
    );

    #[abi(embed_v0)]
    impl FunctionRegistryImpl =
        function_registry_cpt::FunctionRegistryImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        function_registry: function_registry_cpt::Storage
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        FunctionRegistryEvent: function_registry_cpt::Event
    }
}
