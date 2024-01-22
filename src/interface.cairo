
use starknet::EthAddress;
use starknet::secp256_trait::Signature;

#[starknet::interface]
trait IDAOracle<TContractState> {
    fn verify_sig(self: @TContractState, digest: u256, sig: Signature, signer: EthAddress) -> bool;
}
