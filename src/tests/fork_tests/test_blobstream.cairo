use snforge_std::{
    declare, ContractClassTrait, start_prank, stop_prank, CheatTarget, start_warp, stop_warp
};
use starknet::{ContractAddress, contract_address_const};

#[test]
#[fork("Mainnet")]
fn test_init() {
    assert(1 == 1, 'cannot fail');
}
