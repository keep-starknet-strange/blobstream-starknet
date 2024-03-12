use blobstream_sn::mocks::upgradeable::{
    IMockUpgradeableDispatcher, IMockUpgradeableDispatcherTrait
};
use blobstream_sn::tests::common::{setup_base, setup_spied};
use openzeppelin::tests::utils::constants::OWNER;
use openzeppelin::upgrades::interface::{
    IUpgradeable, IUpgradeableDispatcher, IUpgradeableDispatcherTrait
};
use openzeppelin::upgrades::upgradeable::UpgradeableComponent;
use snforge_std as snf;
use snforge_std::cheatcodes::events::EventAssertions;
use snforge_std::{CheatTarget, EventSpy};

const TEST_VAL: felt252 = 420;

fn setup_upgradeable() -> IUpgradeableDispatcher {
    IUpgradeableDispatcher { contract_address: setup_base() }
}

fn setup_upgradeable_spied() -> (IUpgradeableDispatcher, EventSpy) {
    let (contract_address, spy) = setup_spied();
    (IUpgradeableDispatcher { contract_address }, spy)
}

#[test]
fn blobstreamx_upgrade() {
    let (upgradeable, mut spy) = setup_upgradeable_spied();
    let v2_class = snf::declare('mock_upgradeable');

    snf::start_prank(CheatTarget::One(upgradeable.contract_address), OWNER());
    upgradeable.upgrade(v2_class.class_hash);
    snf::stop_prank(CheatTarget::One(upgradeable.contract_address));

    let expected_event = UpgradeableComponent::Upgraded { class_hash: v2_class.class_hash };
    spy
        .assert_emitted(
            @array![
                (
                    upgradeable.contract_address,
                    UpgradeableComponent::Event::Upgraded(expected_event)
                )
            ]
        );

    let v2 = IMockUpgradeableDispatcher { contract_address: upgradeable.contract_address };
    v2.set_gateway_v2(TEST_VAL.try_into().unwrap());
    assert!(v2.get_gateway_v2().into() == TEST_VAL, "upgraded contract selector incorrect");
}

#[test]
#[should_panic(expected: ('Caller is not the owner',))]
fn blobstreamx_upgrade_not_owner() {
    let upgradeable = setup_upgradeable();

    let v2_class = snf::declare('mock_upgradeable');
    upgradeable.upgrade(v2_class.class_hash);
}
