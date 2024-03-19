use blobstream_sn::tests::common::{setup_base, setup_spied, OWNER, NEW_OWNER};
use openzeppelin::access::ownable::OwnableComponent;
use openzeppelin::access::ownable::interface::{IOwnableDispatcher, IOwnableDispatcherTrait};
use snforge_std as snf;
use snforge_std::cheatcodes::events::EventAssertions;
use snforge_std::{CheatTarget, EventSpy};

fn setup_ownable() -> IOwnableDispatcher {
    IOwnableDispatcher { contract_address: setup_base() }
}

fn setup_ownable_spied() -> (IOwnableDispatcher, EventSpy) {
    let (contract_address, spy) = setup_spied();
    (IOwnableDispatcher { contract_address }, spy)
}

#[test]
fn blobstreamx_transfer_ownership() {
    let (ownable, mut spy) = setup_ownable_spied();
    assert(ownable.owner() == OWNER().into(), 'initial owner wrong');

    snf::start_prank(CheatTarget::One(ownable.contract_address), OWNER());
    ownable.transfer_ownership(NEW_OWNER());
    snf::stop_prank(CheatTarget::One(ownable.contract_address));

    assert(ownable.owner() == NEW_OWNER().into(), 'transfer owner failed');

    let expected_event = OwnableComponent::OwnershipTransferred {
        previous_owner: OWNER(), new_owner: NEW_OWNER()
    };
    spy
        .assert_emitted(
            @array![
                (
                    ownable.contract_address,
                    OwnableComponent::Event::OwnershipTransferred(expected_event)
                )
            ]
        );
}

#[test]
#[should_panic(expected: ('Caller is not the owner',))]
fn blobstreamx_transfer_ownership_no_owner() {
    let ownable = setup_ownable();
    ownable.transfer_ownership(NEW_OWNER());

    assert(ownable.owner() == NEW_OWNER().into(), 'transfer owner failed');
}
