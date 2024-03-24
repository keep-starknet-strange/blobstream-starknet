/// The DAVerifier verifies that some shares, which were posted on Celestia, were committed to
/// by the BlobstreamX smart contract.
mod DAVerifier {
    use alexandria_bytes::{Bytes, BytesTrait};
    use blobstream_sn::interfaces::{IDAOracleDispatcher, IDAOracleDispatcherTrait};
    use blobstream_sn::tree::binary::merkle_proof::BinaryMerkleProof;
    use blobstream_sn::tree::binary::merkle_tree;
    use blobstream_sn::tree::namespace::merkle_tree::{
        NamespaceMerkleMultiproof, NamespaceMerkleTree, NamespaceNode
    };
    use blobstream_sn::tree::namespace::{Namespace, NamespaceValueTrait};
    use blobstream_sn::verifier::types::{SharesProof, AttestationProof};

    // TODO: Error naming & other naming: to enum?
    // TODO: data_root_tuple -> data_root & data_root_tuple_root -> data_root?
    mod Error {
        const NoError: felt252 = 'NoError';
        // The shares to the rows proof is invalid.
        const InvalidSharesToRowsProof: felt252 = 'InvalidSharesToRowsProof';
        // The rows to the data root proof is invalid.
        const InvalidRowsToDataRootProof: felt252 = 'InvalidRowsToDataRootProof';
        // The row to the data root proof is invalid.
        const InvalidRowToDataRootProof: felt252 = 'InvalidRowToDataRootProof';
        // The data root tuple to the data root tuple roof proof is invalid.
        const InvalidDataRootTupleToDataRootTupleRootProof: felt252 = 'InvalidDRTtoDRTRProof';
        // The number of share proofs isn't equal to the number of rows roots.
        const UnequalShareProofsAndRowRootsNumber: felt252 = 'UnequalSPandRowRootsNumber';
        // The number of rows proofs isn't equal to the number of rows roots.
        const UnequalRowProofsAndRowRootsNumber: felt252 = 'UnequalRPandRowRootsNumber';
        // The verifier data length isn't equal to the number of shares in the shares proofs.
        const UnequalDataLengthAndNumberOfSharesProofs: felt252 = 'UnequalDLandNSP';
        // The number of leaves in the binary merkle proof is not divisible by 4.
        const InvalidNumberOfLeavesInProof: felt252 = 'InvalidNumberOfLeavesInProof';
        // The provided range is invalid.
        const InvalidRange: felt252 = 'InvalidRange';
        // The provided range is out of bounds.
        const OutOfBoundsRange: felt252 = 'OutOfBoundsRange';
    }

    /// Verifies that the shares, which were posted to Celestia, were committed to by the Blobstream smart contract.
    ///
    /// # Arguments
    ///
    /// * `bridge` - The Blobstream smart contract instance.
    /// * `shares_proof` - The proof of the shares to the data root tuple root.
    /// * `root` - The data root of the block that contains the shares.
    ///
    /// # Returns
    ///
    /// * `true` if the proof is valid, `false` otherwise.
    /// * An error code if the proof is invalid, Error::NoError otherwise.
    fn verify_shares_to_data_root_tuple_root(
        bridge: IDAOracleDispatcher, shares_proof: SharesProof, root: u256
    ) -> (bool, felt252) {
        // check that the data root was committed to by the Blobstream smart contract.
        let (success, error) = verify_multi_row_roots_to_data_root_tuple_root(
            bridge,
            shares_proof.row_roots.span(),
            shares_proof.row_proofs.span(),
            shares_proof.attestation_proof,
            root
        );
        if !success {
            return (false, error);
        }
        return verify_shares_to_data_root_tuple_root_proof(
            shares_proof.data.span(),
            shares_proof.share_proofs.span(),
            shares_proof.namespace,
            shares_proof.row_roots.span(),
            shares_proof.row_proofs.span(),
            root
        );
    }

    /// Verifies the shares to data root tuple root proof.
    ///
    /// # Arguments
    ///
    /// * `data` - The data that needs to be proven.
    /// * `share_proofs` - The share to the row roots proof.
    /// * `namespace` - The namespace of the shares.
    /// * `row_roots` - The row roots where the shares belong.
    /// * `row_proofs` - The proofs of the rowRoots to the data root.
    /// * `root` - The data root of the block that contains the shares.
    ///
    /// # Returns
    ///
    /// * `true` if the proof is valid, `false` otherwise.
    /// * An error code if the proof is invalid, Error::NoError otherwise.
    fn verify_shares_to_data_root_tuple_root_proof(
        data: Span<Bytes>,
        share_proofs: Span<NamespaceMerkleMultiproof>,
        namespace: Namespace,
        row_roots: Span<NamespaceNode>,
        row_proofs: Span<BinaryMerkleProof>,
        root: u256
    ) -> (bool, felt252) {
        // check that the rows roots commit to the data root
        let (success, error) = verify_multi_row_roots_to_data_root_tuple_root_proof(
            row_roots, row_proofs, root
        );
        if !success {
            return (false, error);
        }

        if share_proofs.len() != row_roots.len() {
            return (false, Error::UnequalShareProofsAndRowRootsNumber);
        }

        //TODO: to u32?
        let mut number_of_shares_in_proofs: u256 = 0;
        let mut i: u32 = 0;
        while i < share_proofs
            .len() {
                number_of_shares_in_proofs += *share_proofs.at(i).end_key
                    - *share_proofs.at(i).begin_key;
                i += 1;
            };

        if data.len().into() != number_of_shares_in_proofs {
            return (false, Error::UnequalDataLengthAndNumberOfSharesProofs);
        }

        let mut cursor: u32 = 0;
        i = 0;
        let mut error: felt252 = Error::NoError;
        while i < share_proofs
            .len() {
                let shares_used: u256 = *share_proofs.at(i).end_key - *share_proofs.at(i).begin_key;
                // TODO: Do i need to check for errors here & Span
                let s: Span<Bytes> = data.slice(cursor, cursor + shares_used.try_into().unwrap());
                if !NamespaceMerkleTree::verify_multi(
                    *row_roots.at(i), share_proofs.at(i), namespace, s
                ) {
                    error = Error::InvalidSharesToRowsProof;
                    break;
                }
                cursor += shares_used.try_into().unwrap();

                i += 1;
            };
        if error != Error::NoError {
            return (false, error);
        }

        return (true, Error::NoError);
    }

    /// Verifies that a row/column root, from a Celestia block, was committed to by the Blobstream smart contract.
    ///
    /// # Arguments
    ///
    /// * `bridge` - The Blobstream smart contract instance.
    /// * `row_root` - The row/column root to be proven.
    /// * `row_proof` - The proof of the row/column root to the data root.
    /// * `attestation_proof` - The proof of the data root tuple to the data root tuple root that was posted to the Blobstream contract.
    /// * `root` - The data root of the block that contains the row.
    ///
    /// # Returns
    ///
    /// * `true` if the proof is valid, `false` otherwise.
    /// * An error code if the proof is invalid, Error::NoError otherwise.
    fn verify_row_root_to_data_root_tuple_root(
        bridge: IDAOracleDispatcher,
        row_root: NamespaceNode,
        row_proof: BinaryMerkleProof,
        attestation_proof: AttestationProof,
        root: u256
    ) -> (bool, felt252) {
        // check that the data root was commited to by the Blobstream smart contract
        // TODO: safe unwrap?
        if !bridge
            .verify_attestation(
                attestation_proof.commit_nonce.try_into().unwrap(),
                attestation_proof.data_root,
                attestation_proof.proof
            ) {
            return (false, Error::InvalidDataRootTupleToDataRootTupleRootProof);
        }

        // check that the row root commits to the data root
        return verify_row_root_to_data_root_tuple_root_proof(row_root, row_proof, root);
    }

    /// Verifies that a row/column root proof, from a Celestia block, to its corresponding data root.
    ///
    /// # Arguments
    ///
    /// * `row_root` - The row/column root to be proven.
    /// * `row_proof` - The proof of the row/column root to the data root.
    /// * `root` - The data root of the block that contains the row.
    ///
    /// # Returns
    ///
    /// * `true` if the proof is valid, `false` otherwise.
    /// * An error code if the proof is invalid, ErrorCodes.NoError otherwise.
    fn verify_row_root_to_data_root_tuple_root_proof(
        row_root: NamespaceNode, row_proof: BinaryMerkleProof, root: u256
    ) -> (bool, felt252) {
        let mut row_root_encoded: Bytes = BytesTrait::new_empty();
        row_root_encoded.concat(@row_root.min.to_bytes());
        row_root_encoded.concat(@row_root.max.to_bytes());
        row_root_encoded.append_u256(row_root.digest);
        let (valid, _) = merkle_tree::verify(root, @row_proof, @row_root_encoded);
        if !valid {
            return (false, Error::InvalidRowToDataRootProof);
        }

        return (true, Error::NoError);
    }

    /// Verifies that a set of rows/columns, from a Celestia block, were committed to by the Blobstream smart contract.
    ///
    /// # Arguments
    ///
    /// * `bridge` - The Blobstream smart contract instance.
    /// * `row_roots` - The set of row/column roots to be proved.
    /// * `row_proofs` - The set of proofs of the _rowRoots in the same order.
    /// * `attestation_proof` - The proof of the data root tuple to the data root tuple root that was posted to the Blobstream contract.
    /// * `root` - The data root of the block that contains the rows.
    ///
    /// # Returns
    ///
    /// * `true` if the proof is valid, `false` otherwise.
    /// * An error code if the proof is invalid, Error::NoError otherwise.
    fn verify_multi_row_roots_to_data_root_tuple_root(
        bridge: IDAOracleDispatcher,
        row_roots: Span<NamespaceNode>,
        row_proofs: Span<BinaryMerkleProof>,
        attestation_proof: AttestationProof,
        root: u256
    ) -> (bool, felt252) {
        // check that the data root was commited to by the Blobstream smart contract
        if !bridge
            .verify_attestation(
                attestation_proof.commit_nonce.try_into().unwrap(),
                attestation_proof.data_root,
                attestation_proof.proof
            ) {
            return (false, Error::InvalidDataRootTupleToDataRootTupleRootProof);
        }

        // check that the rows roots commit to the data root
        return verify_multi_row_roots_to_data_root_tuple_root_proof(row_roots, row_proofs, root);
    }

    /// Verifies the proof of a set of rows/columns, from a Celestia block, to their corresponding data root.
    ///
    /// # Arguments
    ///
    /// * `row_roots` - The set of row/column roots to be proved.
    /// * `row_proofs` - The set of proofs of the _rowRoots in the same order.
    /// * `root` - The data root of the block that contains the rows.
    ///
    /// # Returns
    ///
    /// * `true` if the proof is valid, `false` otherwise.
    /// * An error code if the proof is invalid, Error::NoError otherwise.
    fn verify_multi_row_roots_to_data_root_tuple_root_proof(
        row_roots: Span<NamespaceNode>, row_proofs: Span<BinaryMerkleProof>, root: u256
    ) -> (bool, felt252) {
        if row_roots.len() != row_proofs.len() {
            return (false, Error::UnequalRowProofsAndRowRootsNumber);
        }

        let mut i: u32 = 0;
        let mut error: felt252 = Error::NoError;
        while i < row_proofs
            .len() {
                let mut row_root: Bytes = BytesTrait::new_empty();
                row_root.concat(@row_roots.at(i).min.to_bytes());
                row_root.concat(@row_roots.at(i).max.to_bytes());
                row_root.append_u256(*row_roots.at(i).digest);
                let (valid, _) = merkle_tree::verify(root, row_proofs.at(i), @row_root);
                if !valid {
                    error = Error::InvalidRowToDataRootProof;
                    break;
                }
                i += 1;
            };
        if error != Error::NoError {
            return (false, error);
        }

        return (true, Error::NoError);
    }

    fn compute_square_size_from_row_proof(proof: BinaryMerkleProof) -> (u256, felt252) {
        if proof.num_leaves % 4 != 0 {
            return (0, Error::InvalidNumberOfLeavesInProof);
        }
        return (proof.num_leaves / 4, Error::NoError);
    }

    fn compute_square_size_from_share_proof(proof: NamespaceMerkleMultiproof) -> u256 {
        let extended_square_row_size = proof.side_nodes.len();
        return extended_square_row_size.into() / 2;
    }
}
