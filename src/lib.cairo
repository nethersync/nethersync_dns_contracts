
use core::starknet::ContractAddress;

#[derive(Drop, Serde, Copy, starknet::Store)]
struct Agent {
    address: ContractAddress,
    endpoint: felt252,  // URL as felt
    is_active: bool,
    total_earned: u256
}

#[derive(Drop, Serde, Copy, starknet::Store)]
struct Payment {
    from: ContractAddress,
    to: ContractAddress, 
    amount: u256,
    lease_id: felt252,
    timestamp: u64
}

// Define interface
#[starknet::interface]
pub trait INSAgent<TContractState> {
    fn register_agent(ref self: TContractState, endpoint: felt252);
    fn record_payment(ref self: TContractState, to: ContractAddress, amount: u256, lease_id: felt252);
    fn get_agent(self: @TContractState, address: ContractAddress) -> Agent;
    // fn get_agents(self: @TContractState) -> Array<Agent>;
}

// define contract
#[starknet::contract]
mod NSAgent {
    use core::starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use core::num::traits::Zero;
    use starknet::storage::{ Map, StorageMapReadAccess, StorageMapWriteAccess, StoragePointerReadAccess, StoragePointerWriteAccess};
    use super::Agent;
    use super::Payment;

    #[storage]
    struct Storage {
        agents: Map<ContractAddress, Agent>,
        payments: Map<u256, Payment>,
        next_payment_id: u256
    }

    // fntions
    #[abi(embed_v0)]
    impl NSAgentImpl of super::INSAgent<ContractState> {
        fn register_agent(ref self: ContractState, endpoint: felt252) {
            let caller = get_caller_address();
            assert(caller.is_non_zero(), 'Caller address cannot be zero');
            // Simple registration - no staking for now
            // TODO: implement staking
            self.agents.write(caller, Agent{
                address: caller,
                endpoint: endpoint,
                is_active: true,
                total_earned: 0
            });
        }
        
        fn record_payment(ref self: ContractState, to: ContractAddress, amount: u256, lease_id: felt252) {
            // Record payment on-chain for transparency
            let payment_id = self.next_payment_id.read();
            self.payments.write(payment_id, Payment{
                from: get_caller_address(),
                to: to,
                amount: amount,
                lease_id: lease_id,
                timestamp: get_block_timestamp().into()
            });
            self.next_payment_id.write(payment_id + 1);
            
            // Update agent earnings
            let updated_earnings = self.agents.read(to).total_earned + amount;
            let updated_agent = Agent{
                address: self.agents.read(to).address,
                endpoint: self.agents.read(to).endpoint,
                is_active: self.agents.read(to).is_active,
                total_earned: updated_earnings
            };
            self.agents.write(to, updated_agent);
        }

        fn get_agent(self: @ContractState, address: ContractAddress) -> Agent {
            return self.agents.read(address);
        }
    }
}