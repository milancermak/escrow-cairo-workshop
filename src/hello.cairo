#[starknet::interface]
trait IHello<TContractState> {
    fn get_counter(self: @TContractState) -> u128;
    fn increment_counter(ref self: TContractState);
}

#[starknet::contract]
mod hello {
    // imports
    use escrow::hello::IHello;
    use starknet::{ContractAddress, get_caller_address};

    // contract storage
    #[storage]
    struct Storage {
        counter: u128,
        addr_to_value: LegacyMap<ContractAddress, u128>,
    }

    // events
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        CounterUpdated: CounterUpdated
    }

    #[derive(Drop, starknet::Event)]
    struct CounterUpdated {
        counter: u128
    }

    // constructor
    #[constructor]
    fn constructor(ref self: ContractState) {
        self.counter.write(1);
        self.emit(CounterUpdated { counter: 1 });
    }

    // external methods
    impl IHelloImpl of super::IHello<ContractState> {
        fn get_counter(self: @ContractState) -> u128 {
            self.counter.read()
        }

        fn increment_counter(ref self: ContractState) {
            let caller = get_caller_address();
            let new_counter_value: u128 = self.increment_counter_helper();
            self.addr_to_value.write(caller, new_counter_value);
        }
    }

    // internal methods
    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn increment_counter_helper(ref self: ContractState) -> u128 {
            let counter = self.counter.read() + 1;
            self.counter.write(counter);
            self.emit(CounterUpdated { counter });
            counter
        }
    }
}
