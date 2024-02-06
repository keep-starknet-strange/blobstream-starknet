use blobstream_sn::interfaces::{
    IUpgradeableDispatcher, IUpgradeableDispatcherTrait, IDAOracleDispatcher,
    IDAOracleDispatcherTrait
};
use blobstream_sn::tests::mocks::upgradeable::{
    IMockUpgradedDispatcher, IMockUpgradedDispatcherTrait
};
use blobstream_sn::tests::test_blobstreamx::setup_base;
use openzeppelin::tests::utils::constants::OWNER;
use snforge_std::{declare, start_prank, stop_prank, CheatTarget};
use starknet::{ClassHash, contract_address_const};

fn setup_upgradeable() -> IUpgradeableDispatcher {
    IUpgradeableDispatcher { contract_address: setup_base() }
}

#[test]
fn blobstreamx_upgrade() {
    let upgradeable = setup_upgradeable();

    let new_class: ClassHash = declare('MockUpgraded').class_hash;
    start_prank(CheatTarget::One(upgradeable.contract_address), OWNER());
    upgradeable.upgrade(new_class);
    stop_prank(CheatTarget::One(upgradeable.contract_address));

    assert(
        IMockUpgradedDispatcher { contract_address: upgradeable.contract_address }.get_version(),
        'Upgrade failed'
    );
}

#[test]
#[should_panic(expected: ('Caller is not the owner',))]
fn blobstreamx_upgrade_not_owner() {
    let upgradeable = setup_upgradeable();

    let new_class: ClassHash = declare('MockUpgraded').class_hash;
    upgradeable.upgrade(new_class);
}
