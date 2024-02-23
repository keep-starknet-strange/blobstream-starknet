#[starknet::contract]
mod function_verifier_mock {
    use alexandria_bytes::Bytes;
    use blobstream_sn::succinctx::interfaces::IFunctionVerifier;

    #[storage]
    struct Storage {
        circuit_digest: u256,
    }

    #[constructor]
    fn constructor(ref self: ContractState, circuit_digest: u256) {
        self.circuit_digest.write(circuit_digest);
    }

    #[abi(embed_v0)]
    impl FunctionVerifier of IFunctionVerifier<ContractState> {
        fn verify(self: @ContractState, input_hash: u256, output_hash: u256, proof: Bytes) -> bool {
            true
        }
        fn verification_key_hash(self: @ContractState) -> u256 {
            self.circuit_digest.read()
        }
    }
}
