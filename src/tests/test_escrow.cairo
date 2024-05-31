use escrow::escrow::{IEscrowDispatcher, IEscrowDispatcherTrait, EscrowDetails};
use snforge_std::{CheatTarget, start_prank, stop_prank, load};
use starknet::{ContractAddress, contract_address_const};
use super::utils::{IERC20Dispatcher, IERC20DispatcherTrait};
use super::utils;

#[test]
fn test_create_escrow_pass() {
    let escrow: IEscrowDispatcher = utils::deploy_escrow();
    let (eth, wbtc) = utils::deploy_tokens();
    let player1: ContractAddress = contract_address_const::<'player 1'>();
    let player2: ContractAddress = contract_address_const::<'player 2'>();

    let token_in_amount: u256 = 1000;
    let token_out_amount: u256 = 10;

    utils::mint_token_to(eth, player1, token_in_amount);
    utils::approve(eth, player1, escrow.contract_address, token_in_amount);

    assert_eq!(IERC20Dispatcher { contract_address: eth }.balance_of(player1), token_in_amount);
    assert_eq!(IERC20Dispatcher { contract_address: eth }.balance_of(escrow.contract_address), 0);

    start_prank(CheatTarget::One(escrow.contract_address), player1);
    escrow.enter(player2, eth, token_in_amount, wbtc, token_out_amount);

    let escrow_details: EscrowDetails = escrow.examine(player1, player2, eth);
    assert_eq!(escrow_details.in_amount, token_in_amount);
    assert_eq!(escrow_details.out_amount, token_out_amount);
    assert_eq!(escrow_details.out_token, wbtc);

    assert_eq!(IERC20Dispatcher { contract_address: eth }.balance_of(player1), 0);
    assert_eq!(IERC20Dispatcher { contract_address: eth }.balance_of(escrow.contract_address), token_in_amount);
}

#[test]
#[should_panic(expected: ("escrow already exists",))]
fn test_create_escrow_same_fail() {
    let escrow: IEscrowDispatcher = utils::deploy_escrow();
    let (eth, wbtc) = utils::deploy_tokens();
    let player1: ContractAddress = contract_address_const::<'player 1'>();
    let player2: ContractAddress = contract_address_const::<'player 2'>();

    let token_in_amount: u256 = 1000;
    let token_out_amount: u256 = 10;

    utils::mint_token_to(eth, player1, token_in_amount);
    utils::approve(eth, player1, escrow.contract_address, token_in_amount);

    assert_eq!(IERC20Dispatcher { contract_address: eth }.balance_of(player1), token_in_amount);
    assert_eq!(IERC20Dispatcher { contract_address: eth }.balance_of(escrow.contract_address), 0);

    start_prank(CheatTarget::One(escrow.contract_address), player1);
    escrow.enter(player2, eth, token_in_amount, wbtc, token_out_amount);
    escrow.enter(player2, eth, token_in_amount, wbtc, token_out_amount);
}
