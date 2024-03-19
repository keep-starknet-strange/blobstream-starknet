use openzeppelin::utils::serde::SerializedAppend;
use snforge_std as snf;
use snforge_std::{ContractClassTrait, CheatTarget, SpyOn, EventSpy};
use starknet::{ContractAddress, contract_address_const};
use succinct_sn::fee_vault::succinct_fee_vault;
use succinct_sn::function_registry::interfaces::{
    IFunctionRegistryDispatcher, IFunctionRegistryDispatcherTrait
};
use succinct_sn::interfaces::{IFeeVaultDispatcher, IFeeVaultDispatcherTrait};

// https://sepolia.etherscan.io/tx/0xadced8dc7f4bb01d730ed78daecbf9640417c5bd60b0ada23c9045cc953481a5#eventlog
const TEST_START_BLOCK: u64 = 846054;
const TEST_END_BLOCK: u64 = 846360;
const TEST_HEADER: u256 = 0x47D040565942B111F7CD569BE78CE310644596F3929DF25584F3E5ADFD9F5001;
const HEADER_RANGE_DIGEST: u256 = 0xb646edd6dbb2e5482b2449404cf1888b8f4cd6958c790aa075e99226c2c1d62;
const NEXT_HEADER_DIGEST: u256 = 0xfd6c88812a160ff288fe557111815b3433c539c77a3561086cfcdd9482bceb8;
const TOTAL_SUPPLY: u256 = 0x100000000000000000000000000000001;

fn OWNER() -> ContractAddress {
    contract_address_const::<'OWNER'>()
}

fn NEW_OWNER() -> ContractAddress {
    contract_address_const::<'NEW_OWNER'>()
}

fn setup_base() -> ContractAddress {
    // deploy the token associated with the fee vault
    let mut calldata = array![];
    let token_name: ByteArray = "FeeToken";
    let token_symbol: ByteArray = "FT";
    calldata.append_serde(token_name);
    calldata.append_serde(token_symbol);
    calldata.append_serde(TOTAL_SUPPLY);
    calldata.append_serde(OWNER());
    let token_class = snf::declare("SnakeERC20Mock");
    let token_address = token_class.deploy(@calldata).unwrap();

    // deploy the fee vault 
    let fee_vault_class = snf::declare("succinct_fee_vault");
    let fee_calldata = array![token_address.into(), OWNER().into()];
    let fee_vault_address = fee_vault_class.deploy(@fee_calldata).unwrap();

    // deploy the succinct gateway
    let succinct_gateway_class = snf::declare("succinct_gateway");
    let gateway_addr = succinct_gateway_class
        .deploy(@array![OWNER().into(), fee_vault_address.into()])
        .unwrap();
    let gateway = IFunctionRegistryDispatcher { contract_address: gateway_addr };

    // deploy the mock function verifier
    let func_verifier_class = snf::declare("function_verifier_mock");
    let header_range_verifier = func_verifier_class
        .deploy(@array![HEADER_RANGE_DIGEST.low.into(), HEADER_RANGE_DIGEST.high.into()])
        .unwrap();
    let next_header_verifier = func_verifier_class
        .deploy(@array![NEXT_HEADER_DIGEST.low.into(), NEXT_HEADER_DIGEST.high.into()])
        .unwrap();

    // register verifier functions w/ gateway
    let header_range_func_id = gateway
        .register_function(OWNER(), header_range_verifier, 'HEADER_RANGE');
    let next_header_func_id = gateway
        .register_function(OWNER(), next_header_verifier, 'NEXT_HEADER');

    // deploy blobstreamx
    let blobstreamx_class = snf::declare("blobstreamx");
    let calldata = array![
        gateway_addr.into(),
        OWNER().into(),
        TEST_START_BLOCK.into(),
        TEST_HEADER.low.into(),
        TEST_HEADER.high.into(),
        header_range_func_id.low.into(),
        header_range_func_id.high.into(),
        next_header_func_id.low.into(),
        next_header_func_id.high.into(),
    ];
    blobstreamx_class.deploy(@calldata).unwrap()
}

fn setup_spied() -> (ContractAddress, EventSpy) {
    let blobstreamx = setup_base();
    let mut spy = snf::spy_events(SpyOn::One(blobstreamx));
    (blobstreamx, spy)
}


fn setup_succinct_gateway() -> ContractAddress {
    // deploy the token associated with the fee vault
    let mut calldata = array![];
    calldata.append_serde('FeeToken');
    calldata.append_serde('FT');
    calldata.append_serde(TOTAL_SUPPLY);
    calldata.append_serde(OWNER());
    let token_class = snf::declare("SnakeERC20Mock");
    let token_address = token_class.deploy(@calldata).unwrap();

    // deploy the fee vault 
    let fee_vault_class = snf::declare("succinct_fee_vault");
    let fee_calldata = array![token_address.into(), OWNER().into()];
    let fee_vault_address = fee_vault_class.deploy(@fee_calldata).unwrap();

    let succinct_gateway_class = snf::declare("succinct_gateway");
    let calldata = array![OWNER().into(), fee_vault_address.into()];
    succinct_gateway_class.deploy(@calldata).unwrap()
}
