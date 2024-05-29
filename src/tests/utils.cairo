use escrow::escrow::{IEscrowDispatcher, IEscrowDispatcherTrait};
use snforge_std::{ContractClass, ContractClassTrait, CheatTarget, declare, start_prank, stop_prank};
use starknet::{ContractAddress, contract_address_const};


#[starknet::interface]
pub trait IERC20<TContractState> {
    fn balance_of(self: @TContractState, owner: ContractAddress) -> u256;
    fn approve(ref self: TContractState, spender: ContractAddress, amount: u256);
    fn mint(ref self: TContractState, recipient: ContractAddress, amount: u256);
}

pub fn eth_whale() -> ContractAddress {
    contract_address_const::<'eth whale'>()
}

pub fn btc_whale() -> ContractAddress {
    contract_address_const::<'btc whale'>()
}

pub fn deploy_tokens() -> (ContractAddress, ContractAddress) {
    let token_class: ContractClass = declare("erc20").unwrap();

    let eth_supply = 100000000000000000000000000_u256;
    let eth_calldata: Array<felt252> = array![
        'Ethereum',
        'ETH',
        18,
        eth_supply.low.into(), // u256.low
        eth_supply.high.into(), // u256.high
        eth_whale().into(),
    ];
    let (eth_addr, _) = token_class.deploy(@eth_calldata).expect('eth deploy failed');

    let wbtc_supply = 100000000000_u256;
    let wbtc_calldata: Array<felt252> = array![
        'Wrapped Bitcoin',
        'WBTC',
        8,
        wbtc_supply.low.into(), // u256.low
        wbtc_supply.high.into(), // u256.high
        btc_whale().into(),
    ];
    let (wbtc_addr, _) = token_class.deploy(@wbtc_calldata).expect('wbtc deploy failed');

    (eth_addr, wbtc_addr)
}

pub fn deploy_escrow() -> IEscrowDispatcher {
    let escrow_class: ContractClass = declare("escrow").unwrap();
    let (escrow_addr, _) = escrow_class.deploy(Default::default()).expect('escrow deploy failed');
    IEscrowDispatcher { contract_address: escrow_addr }
}

pub fn approve(token: ContractAddress, owner: ContractAddress, spender: ContractAddress, amount: u256) {
    start_prank(CheatTarget::One(token), owner);
    IERC20Dispatcher { contract_address: token }.approve(spender, amount);
    stop_prank(CheatTarget::One(token));
}

pub fn mint_token_to(token: ContractAddress, recipient: ContractAddress, amount: u256) {
    IERC20Dispatcher { contract_address: token }.mint(recipient, amount);
}
