use alexandria_bytes::Bytes;

use blobstream_sn::interfaces::DataRoot;
use blobstream_sn::tree::binary::merkle_proof::BinaryMerkleProof;
use blobstream_sn::tree::namespace::Namespace;
use blobstream_sn::tree::namespace::merkle_tree::{NamespaceNode, NamespaceMerkleMultiproof};

// Data needed to verify that some shares, posted to the Celestia 
// network, were committed to by the Blobstream smart contract.
struct SharesProof {
    // The shares that were committed to.
    data: Array<Bytes>,
    // The shares proof to the row roots. If the shares span multiple rows, we will have multiple nmt proofs.
    share_proofs: Array<NamespaceMerkleMultiproof>,
    // The namespace of the shares.
    namespace: Namespace,
    // The rows where the shares belong. If the shares span multiple rows, we will have multiple rows.
    row_roots: Array<NamespaceNode>,
    // The proofs of the rowRoots to the data root.
    row_proofs: Array<BinaryMerkleProof>,
    // The proof of the data root tuple to the data root tuple root that was posted to the Blobstream contract.
    attestation_proof: AttestationProof
}

// Data needed to verify that a data root tuple was committed to
// by the Blobstream smart contract, at some specific nonce
#[derive(Drop)]
struct AttestationProof {
    // attestation nonce that commits to the data root tuple
    commit_nonce: u256,
    //data root tuple that was committed to
    data_root: DataRoot,
    // binary merkle proof of the tuple to the commitment
    proof: BinaryMerkleProof,
}
