mod interfaces;
mod tree;
mod utils;
mod verifier;
use starknet::secp256_trait::Signature;

use starknet::{EthAddress, ClassHash};

/// u256 encoding of the string "checkpoint"
const VALIDATOR_SET_HASH_DOMAIN_SEPARATOR: u256 =
    0x636865636b706f696e7400000000000000000000000000000000000000000000;

/// u256 encoding of the string "transactionBatch"
const DATA_ROOT_TUPLE_ROOT_DOMAIN_SEPARATOR: u256 =
    0x7472616e73616374696f6e426174636800000000000000000000000000000000;

#[derive(Copy, Drop, Serde)]
struct Validator {
    addr: EthAddress,
    power: u256
}

/// Each data root is associated with a Celestia block height. `availableDataRoot` in
/// https://github.com/celestiaorg/celestia-specs/blob/master/src/specs/data_structures.md#header
#[derive(Copy, Drop)]
struct DataRoot {
    // Celestia block height for data root(genesis height = 0)
    height: felt252,
    data_root: u256
}

mod Errors {
    // Malformed current validator set.
    const MALFORMED_CURRENT_VALIDATOR_SET: felt252 = 'Malformed current validator set';
    // Validator signature does not match.
    const INVALID_SIGNATURE: felt252 = 'Invalid signature';
    // Submitted validator set signatures do not have enough power.
    const INSUFFICIENT_VOTING_POWER: felt252 = 'Sub validator inadequate power';
    // New validator set nonce must be greater than the current nonce.
    const INVALID_VALIDATOR_SET_NONCE: felt252 = 'New set nonce > current nonce';
    // Supplied current validators and powers do not match checkpoint.
    const SUPPLIED_VALIDATOR_SET_INVALID: felt252 = 'Validator&power not matching cp';
    // Data root tuple root nonce must be greater than the current nonce.
    const INVALID_DATA_ROOT_TUPLE_ROOT_NONCE: felt252 = 'Data RTR nonce > current nonce';
}

#[starknet::contract]
mod Blobstream {
    use array::SpanTrait;
    use blobstream_sn::interfaces::{IDAOracle, IUpgradeable};
    use openzeppelin::access::ownable::OwnableComponent;
    use openzeppelin::access::ownable::interface::IOwnable;
    use openzeppelin::access::ownable::ownable::OwnableComponent::InternalTrait as OwnableInternalTrait;
    use openzeppelin::upgrades::upgradeable::UpgradeableComponent;
    use starknet::eth_signature::verify_eth_signature;
    use starknet::secp256_trait::Signature;
    use starknet::{EthAddress, ContractAddress, ClassHash};
    use super::{Errors, Validator};

    // Components.
    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);
    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    component!(path: UpgradeableComponent, storage: upgradeable, event: UpgradeableEvent);
    impl UpgradeableInternalImpl = UpgradeableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        // Nonce for bridge events. Must be incremented sequentially.
        state_event_nonce: felt252,
        // Voting power required to submit a new update.
        state_power_threshold: felt252,
        // Domain-separated commitment to the latest validator set.
        state_last_validator_checkpoint: u256,
        // Mapping of data root tuple root nonces to data root tuple roots.
        state_data_root_tuple_roots: LegacyMap::<felt252, u256>,
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
        data_root_tuple_root_event: data_root_tuple_root_event,
        validator_set_updated_event: validator_set_updated_event
    }

    #[derive(Drop, starknet::Event)]
    struct data_root_tuple_root_event {
        #[key]
        nonce: felt252,
        data_root_tuple_root: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct validator_set_updated_event {
        #[key]
        nonce: felt252,
        power_threshold: felt252,
        validator_set_hash: u256
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        nonce: felt252,
        power_threshold: felt252,
        validator_checkpoint: u256,
        owner: ContractAddress
    ) {
        self.state_event_nonce.write(nonce);
        self.state_power_threshold.write(power_threshold);
        self.state_last_validator_checkpoint.write(validator_checkpoint);
        self.ownable.initializer(owner);
    }

    #[abi(embed_v0)]
    impl Upgradeable of IUpgradeable<ContractState> {
        fn upgrade(ref self: ContractState, new_hash: ClassHash) {
            self.ownable.assert_only_owner();
            self.upgradeable._upgrade(new_hash);
        }
    }

    #[abi(embed_v0)]
    impl Blobstream of IDAOracle<ContractState> {
        fn verify_sig(
            self: @ContractState, digest: u256, sig: Signature, signer: EthAddress,
        ) -> bool {
            verify_eth_signature(digest, sig, signer);
            false
        }

        /// This updates the validator set by checking that the validators
        /// in the current validator set have signed off on the new validator set.
        /// The signatures supplied are the signatures of the current validator set
        /// over the checkpoint hash generated from the new validator set. Anyone
        /// can call this function, but they must supply valid signatures of the
        /// current validator set over the new validator set.
        ///
        /// The validator set hash that is signed over is domain separated as per
        /// `domain_separate_validator_set_hash`.
        /// # Arguments
        /// * `_new_nonce` - The new event nonce.
        /// * `_old_nonce` - The nonce of the latest update to the validator set.
        /// * `_new_power_threshold` - At least this much power must have signed.
        /// * `_new_validator_set_hash` - The hash of the new validator set.
        /// * `_current_validator_set`- The current validator set.
        /// * `_sigs` - Signatures
        fn update_validator_set(
            ref self: ContractState,
            _new_nonce: felt252,
            _old_nonce: felt252,
            _new_power_threshold: felt252,
            _new_validator_set_hash: u256,
            _current_validator_set: Span<Validator>,
            _sigs: Span<Signature>
        ) {
            let current_nonce: felt252 = self.state_event_nonce.read();
            let current_power_threshold: felt252 = self.state_power_threshold.read();
            let last_validator_set_checkpoint: u256 = self.state_last_validator_checkpoint.read();

            // Check that the new nonce is one more than the current one.
            assert(_new_nonce == current_nonce + 1, Errors::INVALID_VALIDATOR_SET_NONCE);
            // Check that current validators and signatures are well-formed.
            assert(
                _current_validator_set.len() == _sigs.len(), Errors::MALFORMED_CURRENT_VALIDATOR_SET
            );

            // Check that the supplied current validator set matches the saved checkpoint.
            let current_validator_set_hash: u256 = compute_validator_set_hash(
                _current_validator_set
            );
            let domain_separate_validator_set_hash_val = domain_separate_validator_set_hash(
                _old_nonce, current_power_threshold, current_validator_set_hash
            );
            assert(
                domain_separate_validator_set_hash_val == last_validator_set_checkpoint,
                Errors::SUPPLIED_VALIDATOR_SET_INVALID
            );

            // Check that enough current validators have signed off on the new validator set.
            let new_checkpoint: u256 = domain_separate_validator_set_hash(
                _new_nonce, _new_power_threshold, _new_validator_set_hash
            );
            check_validator_signatures(
                @self, _current_validator_set, _sigs, new_checkpoint, current_power_threshold
            );

            self.state_last_validator_checkpoint.write(new_checkpoint);
            self.state_power_threshold.write(_new_power_threshold);
            self.state_event_nonce.write(_new_nonce);
            self
                .emit(
                    validator_set_updated_event {
                        nonce: _new_nonce,
                        power_threshold: _new_power_threshold,
                        validator_set_hash: _new_validator_set_hash
                    }
                );
        }

        fn submit_data_root_tuple_root(
            ref self: ContractState,
            _new_nonce: felt252,
            _validator_set_nonce: felt252,
            _data_root_tuple_root: u256,
            _current_validator_set: Span<Validator>,
            _sigs: Span<Signature>
        ) {
            let current_nonce: felt252 = self.state_event_nonce.read();
            let current_power_threshold: felt252 = self.state_power_threshold.read();
            let last_validator_set_checkpoint: u256 = self.state_last_validator_checkpoint.read();

            // Check that the new nonce is one more than the current one.
            assert(_new_nonce == current_nonce + 1, Errors::INVALID_DATA_ROOT_TUPLE_ROOT_NONCE);
            // Check that current validators and signatures are well-formed.
            assert(
                _current_validator_set.len() == _sigs.len(), Errors::MALFORMED_CURRENT_VALIDATOR_SET
            );

            // Check that the supplied current validator set matches the saved checkpoint.
            let current_validator_set_hash: u256 = compute_validator_set_hash(
                _current_validator_set
            );

            // Check that the supplied current validator set matches the saved checkpoint.
            let current_validator_set_hash: u256 = compute_validator_set_hash(
                _current_validator_set
            );
            // TODO(#51): Blobstream Funcs 
            let domain_separate_validator_set_hash_val = domain_separate_validator_set_hash(
                _validator_set_nonce, current_power_threshold, current_validator_set_hash
            );
            assert(
                domain_separate_validator_set_hash_val == last_validator_set_checkpoint,
                Errors::SUPPLIED_VALIDATOR_SET_INVALID
            );

            let c: u256 = domain_separate_data_root_tuple_root(_new_nonce, _data_root_tuple_root);
            check_validator_signatures(
                @self, _current_validator_set, _sigs, c, current_power_threshold
            );

            self.state_event_nonce.write(_new_nonce);
            self.state_data_root_tuple_roots.write(_new_nonce, _data_root_tuple_root);

            self
                .emit(
                    data_root_tuple_root_event {
                        nonce: _new_nonce, data_root_tuple_root: _data_root_tuple_root,
                    }
                );
        }
    }

    /// Checks that enough voting power signed over a digest.
    /// It expects the signatures to be in the same order as the _currentValidators.
    /// # Arguments
    /// * `_currentValidators` - The current validators.
    /// *  `_sigs` - The current validators' signatures.
    /// *  `_digest`- This is what we are checking they have signed.
    /// *  `_power_threshold` -  At least this much power must have signed.
    fn check_validator_signatures(
        self: @ContractState,
        _current_validators: Span<Validator>,
        _sigs: Span<Signature>,
        _digest: u256,
        _power_threshold: felt252
    ) {
        let mut cumulative_power: u256 = 0;
        let mut cur_idx: u32 = 0;
        loop {
            if (cur_idx == _current_validators.len()) {
                break ();
            }
            let sig = *_sigs.at(cur_idx);
            if (is_sig_nil(sig)) {
                cur_idx += 1;
                continue;
            }
            let cur_validator = *_current_validators.at(cur_idx);
            assert(self.verify_sig(_digest, sig, cur_validator.addr), Errors::INVALID_SIGNATURE);
            cumulative_power += cur_validator.power;
            if (cumulative_power >= _power_threshold.into()) {
                break ();
            }
            cur_idx += 1;
        };
        assert(cumulative_power >= _power_threshold.into(), Errors::INSUFFICIENT_VOTING_POWER);
    }

    /// Determines if a signature is nil.
    /// If all bytes of the 65-byte signature are zero, and the parity true, then it's a nil signature
    /// # Arguments
    /// * `_sig` - The signature to consider
    /// # Returns
    /// * A boolean
    fn is_sig_nil(_sig: Signature) -> bool {
        return (_sig.r == 0 && _sig.s == 0 && _sig.y_parity == true);
    }


    fn compute_validator_set_hash(_validators: Span<Validator>) -> u256 {
        return 0; // TODO(#51): Blobstream Funcs 
    }

    fn domain_separate_validator_set_hash(
        _nonce: felt252, _power_threshold: felt252, _validator_set_hash: u256
    ) -> u256 {
        return 0; // TODO(#51): Blobstream Funcs 
    }

    fn domain_separate_data_root_tuple_root(_nonce: felt252, _data_root_tuple_root: u256) -> u256 {
        return 0; // TODO(#51): Blobstream Funcs 
    }
}

#[cfg(test)]
mod tests {
    mod test_blobstream;
    mod test_verifier;
}

mod mocks {
    mod upgraded;
}
