use blobstream_sn::succinctx::fee_vault::succinct_fee_vault;
use blobstream_sn::succinctx::function_registry::erc20_mock::{
    IMockERC20Dispatcher, IMockERC20DispatcherTrait, MockERC20
};
use blobstream_sn::succinctx::interfaces::{IFeeVaultDispatcher, IFeeVaultDispatcherTrait};
use debug::PrintTrait;
use openzeppelin::tests::utils::constants::{OWNER, NEW_OWNER, SPENDER};
use snforge_std::{
    declare, ContractClassTrait, start_prank, stop_prank, CheatTarget, spy_events, SpyOn, EventSpy
};
use starknet::ContractAddress;
use starknet::contract_address_const;
use starknet::get_caller_address;
const TOTAL_SUPPPLY: u256 = 0x100000000000000000000000000000001;


fn setup_contracts() -> (IMockERC20Dispatcher, IFeeVaultDispatcher) {
    let token_class = declare('MockERC20');
    let token_calldata = array!['FeeToken', 'FT'];
    let token_address = token_class.deploy(@token_calldata).unwrap();
    let fee_vault_class = declare('succinct_fee_vault');
    let fee_calldata = array![token_address.into(), OWNER().into()];
    let fee_vault_address = fee_vault_class.deploy(@fee_calldata).unwrap();
    (
        IMockERC20Dispatcher { contract_address: token_address },
        IFeeVaultDispatcher { contract_address: fee_vault_address }
    )
}

#[test]
fn fee_vault_set_native_currency_address() {
    let (_, fee_vault) = setup_contracts();
    let new_currency_address = contract_address_const::<0x12345>();
    start_prank(CheatTarget::One(fee_vault.contract_address), OWNER());
    fee_vault.set_native_currency(new_currency_address);
    assert(
        fee_vault.get_native_currency() == new_currency_address, 'wrong initial native currency'
    );
    stop_prank(CheatTarget::One(fee_vault.contract_address));
}

#[test]
#[should_panic(expected: ('Invalid token',))]
fn fee_vault_set_native_currency_address_fails_null_address() {
    let (_, fee_vault) = setup_contracts();
    start_prank(CheatTarget::One(fee_vault.contract_address), OWNER());
    let new_currency_address = contract_address_const::<0>();
    fee_vault.set_native_currency(new_currency_address);
    stop_prank(CheatTarget::One(fee_vault.contract_address));
}

#[test]
#[should_panic(expected: ('Caller is not the owner',))]
fn test_vault_set_native_currency_fails_not_owner() {
    let (_, fee_vault) = setup_contracts();
    let new_currency_address = contract_address_const::<0x1234>();
    fee_vault.set_native_currency(new_currency_address);
}

#[test]
fn fee_vault_deductor_operations() {
    let (_, fee_vault) = setup_contracts();
    start_prank(CheatTarget::One(fee_vault.contract_address), OWNER());
    // Adding a new deductor
    fee_vault.add_deductor(SPENDER());
    assert(fee_vault.get_deductor_status(SPENDER()), 'deductor status not updated');

    // Removing the same deductor
    fee_vault.remove_deductor(SPENDER());
    assert(!fee_vault.get_deductor_status(SPENDER()), 'deductor status not updated');
    stop_prank(CheatTarget::One(fee_vault.contract_address));
}


#[test]
#[should_panic(expected: ('Caller is not the owner',))]
fn fee_vault_add_deductor_fails_if_not_owner() {
    let (_, fee_vault) = setup_contracts();
    // Adding a new deductor
    fee_vault.add_deductor(SPENDER());
    assert(fee_vault.get_deductor_status(SPENDER()), 'deductor status not updated');
}


#[test]
#[should_panic(expected: ('Caller is not the owner',))]
fn fee_vault_remove_deductor_fails_if_not_owner() {
    let (_, fee_vault) = setup_contracts();
    // Adding a new deductor
    fee_vault.remove_deductor(SPENDER());
    assert(!fee_vault.get_deductor_status(SPENDER()), 'deductor status not updated');
}

#[test]
fn fee_vault_deposit_native() {
    let (erc20, fee_vault) = setup_contracts();
    erc20.mint_to(SPENDER(), 0x10000);
    start_prank(CheatTarget::One(erc20.contract_address), SPENDER());
    let fee = starknet::info::get_tx_info().unbox().max_fee.into();
    erc20.approve(fee_vault.contract_address, fee);
    stop_prank(CheatTarget::One(erc20.contract_address));
    start_prank(CheatTarget::One(fee_vault.contract_address), SPENDER());
    fee_vault.deposit_native(SPENDER());
    assert(
        fee_vault.get_balances_infos(SPENDER(), erc20.contract_address) == fee,
        'balances not updated'
    );
    stop_prank(CheatTarget::One(fee_vault.contract_address));
}

#[test]
fn fee_vault_deposit() {
    let (erc20, fee_vault) = setup_contracts();
    erc20.mint_to(SPENDER(), 0x10000);
    start_prank(CheatTarget::One(erc20.contract_address), SPENDER());
    erc20.approve(fee_vault.contract_address, 0x10000);
    stop_prank(CheatTarget::One(erc20.contract_address));
    start_prank(CheatTarget::One(fee_vault.contract_address), SPENDER());
    fee_vault.deposit(SPENDER(), erc20.contract_address, 0x10000);
    assert(
        fee_vault.get_balances_infos(SPENDER(), erc20.contract_address) == 0x10000,
        'balances deposit not updated'
    );
    stop_prank(CheatTarget::One(fee_vault.contract_address));
}

#[test]
#[should_panic(expected: ('Invalid account',))]
fn fee_vault_deposit_fails_if_null_account() {
    let (erc20, fee_vault) = setup_contracts();
    fee_vault.deposit(contract_address_const::<0>(), erc20.contract_address, 0x10000);
}

#[test]
#[should_panic(expected: ('Invalid token',))]
fn fee_vault_deposit_fails_if_null_token() {
    let (_, fee_vault) = setup_contracts();
    fee_vault.deposit(SPENDER(), contract_address_const::<0>(), 0x10000);
}

#[test]
#[should_panic(expected: ('Insufficent allowance',))]
fn fee_vault_deposit_fails_if_insufficent_allowance() {
    let (erc20, fee_vault) = setup_contracts();
    erc20.mint_to(SPENDER(), 0x10000);
    start_prank(CheatTarget::One(fee_vault.contract_address), SPENDER());
    fee_vault.deposit(SPENDER(), erc20.contract_address, 0x10000);
    assert(
        fee_vault.get_balances_infos(SPENDER(), erc20.contract_address) == 0x10000,
        'balances deposit not updated'
    );
    stop_prank(CheatTarget::One(fee_vault.contract_address));
}

#[test]
fn fee_vault_deduct_native() {
    let (erc20, fee_vault) = setup_contracts();
    let fee = starknet::info::get_tx_info().unbox().max_fee.into();
    start_prank(CheatTarget::One(fee_vault.contract_address), OWNER());
    fee_vault.add_deductor(SPENDER());
    stop_prank(CheatTarget::One(fee_vault.contract_address));
    erc20.mint_to(SPENDER(), 0x10000);
    start_prank(CheatTarget::One(erc20.contract_address), SPENDER());
    erc20.approve(fee_vault.contract_address, 0x10000);
    stop_prank(CheatTarget::One(erc20.contract_address));
    start_prank(CheatTarget::One(fee_vault.contract_address), SPENDER());
    fee_vault.deposit_native(SPENDER());
    assert(
        fee_vault.get_balances_infos(SPENDER(), erc20.contract_address) == fee,
        'balances deposit not updated'
    );
    fee_vault.deduct_native(SPENDER());
    assert(
        fee_vault.get_balances_infos(SPENDER(), erc20.contract_address) == 0,
        'balances deduct not updated'
    );
    stop_prank(CheatTarget::One(fee_vault.contract_address));
}

#[test]
fn fee_vault_deduct() {
    let (erc20, fee_vault) = setup_contracts();
    start_prank(CheatTarget::One(fee_vault.contract_address), OWNER());
    fee_vault.add_deductor(SPENDER());
    stop_prank(CheatTarget::One(fee_vault.contract_address));
    erc20.mint_to(SPENDER(), 0x10000);
    start_prank(CheatTarget::One(erc20.contract_address), SPENDER());
    erc20.approve(fee_vault.contract_address, 0x10000);
    stop_prank(CheatTarget::One(erc20.contract_address));
    start_prank(CheatTarget::One(fee_vault.contract_address), SPENDER());
    fee_vault.deposit(SPENDER(), erc20.contract_address, 0x10000);
    fee_vault.deduct(SPENDER(), erc20.contract_address, 0x8000);
    assert(
        fee_vault.get_balances_infos(SPENDER(), erc20.contract_address) == 0x10000 - 0x8000,
        'balances deduct not updated'
    );
    stop_prank(CheatTarget::One(fee_vault.contract_address));
}

#[test]
#[should_panic(expected: ('Only deductor allowed',))]
fn fee_vault_deduct_fails_if_not_deductor() {
    let (erc20, fee_vault) = setup_contracts();
    erc20.mint_to(SPENDER(), 0x10000);
    start_prank(CheatTarget::One(erc20.contract_address), SPENDER());
    erc20.approve(fee_vault.contract_address, 0x10000);
    stop_prank(CheatTarget::One(erc20.contract_address));
    start_prank(CheatTarget::One(fee_vault.contract_address), SPENDER());
    fee_vault.deposit(SPENDER(), erc20.contract_address, 0x10000);
    fee_vault.deduct(SPENDER(), erc20.contract_address, 0x8000);
    stop_prank(CheatTarget::One(fee_vault.contract_address));
}

#[test]
#[should_panic(expected: ('Insufficent balance',))]
fn fee_vault_deduct_fails_if_insufficent_balance() {
    let (erc20, fee_vault) = setup_contracts();
    start_prank(CheatTarget::One(fee_vault.contract_address), OWNER());
    fee_vault.add_deductor(SPENDER());
    stop_prank(CheatTarget::One(fee_vault.contract_address));
    erc20.mint_to(SPENDER(), 0x10000);
    start_prank(CheatTarget::One(erc20.contract_address), SPENDER());
    erc20.approve(fee_vault.contract_address, 0x10000);
    stop_prank(CheatTarget::One(erc20.contract_address));
    start_prank(CheatTarget::One(fee_vault.contract_address), SPENDER());
    fee_vault.deposit(SPENDER(), erc20.contract_address, 0x1000);
    fee_vault.deduct(SPENDER(), erc20.contract_address, 0x8000);
    stop_prank(CheatTarget::One(fee_vault.contract_address));
}


#[test]
fn fee_vault_collect() {
    let (erc20, fee_vault) = setup_contracts();
    start_prank(CheatTarget::One(fee_vault.contract_address), OWNER());
    fee_vault.add_deductor(SPENDER());
    stop_prank(CheatTarget::One(fee_vault.contract_address));
    erc20.mint_to(SPENDER(), 0x10000);
    start_prank(CheatTarget::One(erc20.contract_address), SPENDER());
    erc20.approve(fee_vault.contract_address, 0x10000);
    stop_prank(CheatTarget::One(erc20.contract_address));
    start_prank(CheatTarget::One(fee_vault.contract_address), SPENDER());
    fee_vault.deposit(SPENDER(), erc20.contract_address, 0x10000);
    fee_vault.deduct(SPENDER(), erc20.contract_address, 0x8000);
    stop_prank(CheatTarget::One(fee_vault.contract_address));
    start_prank(CheatTarget::One(fee_vault.contract_address), OWNER());
    fee_vault.collect(OWNER(), erc20.contract_address, 0x10000);
    assert(erc20.balance_of(OWNER()) == 0x10000, 'balance collect failed');
    stop_prank(CheatTarget::One(fee_vault.contract_address));
}


#[test]
fn fee_vault_collect_native() {
    let (erc20, fee_vault) = setup_contracts();
    start_prank(CheatTarget::One(fee_vault.contract_address), OWNER());
    fee_vault.add_deductor(SPENDER());
    stop_prank(CheatTarget::One(fee_vault.contract_address));
    erc20.mint_to(SPENDER(), 0x10000);
    start_prank(CheatTarget::One(erc20.contract_address), SPENDER());
    erc20.approve(fee_vault.contract_address, 0x10000);
    stop_prank(CheatTarget::One(erc20.contract_address));
    start_prank(CheatTarget::One(fee_vault.contract_address), SPENDER());
    fee_vault.deposit(SPENDER(), erc20.contract_address, 0x10000);
    fee_vault.deduct(SPENDER(), erc20.contract_address, 0x8000);
    stop_prank(CheatTarget::One(fee_vault.contract_address));
    start_prank(CheatTarget::One(fee_vault.contract_address), OWNER());
    fee_vault.collect_native(OWNER(), 0x10000);
    assert(erc20.balance_of(OWNER()) == 0x10000, 'balance collect failed');
    stop_prank(CheatTarget::One(fee_vault.contract_address));
}

#[test]
#[should_panic(expected: ('Caller is not the owner',))]
fn fee_vault_collect_fails_if_not_owner() {
    let (erc20, fee_vault) = setup_contracts();
    start_prank(CheatTarget::One(fee_vault.contract_address), OWNER());
    fee_vault.add_deductor(SPENDER());
    stop_prank(CheatTarget::One(fee_vault.contract_address));
    erc20.mint_to(SPENDER(), 0x10000);
    start_prank(CheatTarget::One(erc20.contract_address), SPENDER());
    erc20.approve(fee_vault.contract_address, 0x10000);
    stop_prank(CheatTarget::One(erc20.contract_address));
    start_prank(CheatTarget::One(fee_vault.contract_address), SPENDER());
    fee_vault.deposit(SPENDER(), erc20.contract_address, 0x10000);
    fee_vault.collect(SPENDER(), erc20.contract_address, 0x10000);
    stop_prank(CheatTarget::One(fee_vault.contract_address));
}

#[test]
#[should_panic(expected: ('Insufficent balance',))]
fn fee_vault_collect_fails_if_insufficent_balance() {
    let (erc20, fee_vault) = setup_contracts();
    start_prank(CheatTarget::One(fee_vault.contract_address), OWNER());
    fee_vault.add_deductor(SPENDER());
    stop_prank(CheatTarget::One(fee_vault.contract_address));
    erc20.mint_to(SPENDER(), 0x10000);
    start_prank(CheatTarget::One(erc20.contract_address), SPENDER());
    erc20.approve(fee_vault.contract_address, 0x10000);
    stop_prank(CheatTarget::One(erc20.contract_address));
    start_prank(CheatTarget::One(fee_vault.contract_address), SPENDER());
    fee_vault.deposit(SPENDER(), erc20.contract_address, 0x1000);
    stop_prank(CheatTarget::One(fee_vault.contract_address));
    start_prank(CheatTarget::One(fee_vault.contract_address), OWNER());
    fee_vault.collect(OWNER(), erc20.contract_address, 0x10000);
    stop_prank(CheatTarget::One(fee_vault.contract_address));
}
