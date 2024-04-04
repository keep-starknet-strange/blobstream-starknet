use cainome::rs::abigen;

abigen!(
    BlobstreamX,
    "../target/dev/blobstream_sn_blobstreamx.contract_class.json",
     type_aliases {
        blobstream_sn::blobstreamx::blobstreamx::Event as BlobstreamXEvent;
        openzeppelin::access::ownable::ownable::OwnableComponent::Event as OwnableCptEvent;
        openzeppelin::upgrades::upgradeable::UpgradeableComponent::Event as UpgradeableCptEvent;
     },
    output_path("src/bindings.rs")
);

mod bindings;

pub use bindings::{
    BlobstreamX, 
    BlobstreamXReader, 
    BinaryMerkleProof,
    DataRoot,
};

pub mod events {
    pub use super::bindings::{
        BlobstreamXEvent,
        OwnableCptEvent,
        UpgradeableCptEvent,
        HeadUpdate, 
        HeaderRangeRequested, 
        Upgraded, 
        OwnershipTransferStarted,
        OwnershipTransferred,
        DataCommitmentStored,
        NextHeaderRequested,
    };
}
