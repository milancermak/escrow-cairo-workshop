use core::num::traits::Zero;
use starknet::ContractAddress;

#[derive(Copy, Drop, Hash)]
struct EscrowId {
    sender: ContractAddress,
    recipient: ContractAddress,
    in_token: ContractAddress
}

#[derive(Copy, Default, Drop, Serde, starknet::Store)]
pub struct EscrowDetails {
    pub in_amount: u256,
    pub out_token: ContractAddress,
    pub out_amount: u256
}

#[starknet::interface]
pub trait IEscrow<TContractState> {
    fn examine(
        self: @TContractState, sender: ContractAddress, recipient: ContractAddress, in_token: ContractAddress
    ) -> EscrowDetails;

    fn enter(
        ref self: TContractState,
        recipient: ContractAddress,
        in_token: ContractAddress,
        in_amount: u256,
        out_token: ContractAddress,
        out_amount: u256
    );

    fn exit(ref self: TContractState, sender: ContractAddress, recipient: ContractAddress, in_token: ContractAddress);

    fn execute(ref self: TContractState, sender: ContractAddress, in_token: ContractAddress);
}

#[starknet::interface]
trait IERC20<TContractState> {
    fn transfer(ref self: TContractState, to: ContractAddress, amount: u256);
    fn transfer_from(
        ref self: TContractState, from: ContractAddress, to: ContractAddress, amount: u256
    );
}

impl ContractAddressDefault of Default<ContractAddress> {
    fn default() -> ContractAddress {
        Zero::zero()
    }
}

impl EscrowDetailsZero of Zero<EscrowDetails> {
    fn zero() -> EscrowDetails {
        EscrowDetails { in_amount: Zero::zero(), out_token: Zero::zero(), out_amount: Zero::zero() }
    }

    fn is_zero(self: @EscrowDetails) -> bool {
        self.in_amount.is_zero() && self.out_token.is_zero() && self.out_amount.is_zero()
    }

    fn is_non_zero(self: @EscrowDetails) -> bool {
        !self.is_zero()
    }
}

#[starknet::contract]
mod escrow {
    use core::num::traits::Zero;
    use starknet::{ContractAddress, get_caller_address, get_contract_address};
    use super::{IEscrow, IERC20Dispatcher, IERC20DispatcherTrait};
    use super::{ContractAddressDefault, EscrowDetails, EscrowId};

    #[storage]
    struct Storage {
        escrows: LegacyMap<EscrowId, EscrowDetails>
    }

    #[abi(embed_v0)]
    impl IEscrowImpl of IEscrow<ContractState> {
        fn examine(
            self: @ContractState, sender: ContractAddress, recipient: ContractAddress, in_token: ContractAddress
        ) -> EscrowDetails {
            self.escrows.read(EscrowId { sender, recipient, in_token })
        }

        fn enter(
            ref self: ContractState,
            recipient: ContractAddress,
            in_token: ContractAddress,
            in_amount: u256,
            out_token: ContractAddress,
            out_amount: u256
        ) {
            // CEI pattern
            // checks effects interactions

            let caller: ContractAddress = get_caller_address();
            let escrow_id = EscrowId { sender: caller, recipient, in_token };
            let escrow_details: EscrowDetails = self.escrows.read(escrow_id);

            // checks
            assert!(escrow_details.is_zero(), "escrow already exists");

            // effects
            self.escrows.write(escrow_id, EscrowDetails { in_amount, out_token, out_amount });

            // interactions
            // transfer in_token from caller to self
            IERC20Dispatcher { contract_address: in_token }
                .transfer_from(caller, get_contract_address(), in_amount);
        }

        fn exit(ref self: ContractState, sender: ContractAddress, recipient: ContractAddress, in_token: ContractAddress) {
            let caller: ContractAddress = get_caller_address();
            let escrow_id = EscrowId { sender: caller, recipient, in_token };
            let escrow_details = self.escrows.read(escrow_id);

            // checks
            assert!(escrow_details.is_non_zero(), "escrow does not exist");

            // effects
            self.escrows.write(escrow_id, Default::default());

            // interactions
            IERC20Dispatcher { contract_address: in_token }.transfer(caller, escrow_details.in_amount);
        }

        fn execute(ref self: ContractState, sender: ContractAddress, in_token: ContractAddress) {
            let caller: ContractAddress = get_caller_address();
            let escrow_id = EscrowId { sender, recipient: caller, in_token };
            let escrow_details: EscrowDetails = self.escrows.read(escrow_id);

            self.escrows.write(escrow_id, Default::default());

            IERC20Dispatcher { contract_address: escrow_id.in_token }.transfer(caller, escrow_details.in_amount);
            IERC20Dispatcher { contract_address: escrow_details.out_token }
                .transfer_from(caller, sender, escrow_details.out_amount);
        }
    }
}
