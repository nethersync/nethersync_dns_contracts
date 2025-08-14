
use core::starknet::ContractAddress;

struct Agent {
    address: ContractAddress,
    endpoint: felt252,  // URL as felt
    is_active: bool,
    total_earned: u256
}

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
    fn get_agents(self: @TContractState, address: ContractAddress) -> Array<Agent>;
}

// define contract
#[starknet::contract]
mod NSAgent {
    use core::starknet::{ContractAddress, get_caller_address};
    use core::starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
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
            // Simple registration - no staking for now
            let caller = get_caller_address();
            agents[caller] = Agent{
                address: caller,
                endpoint: endpoint,
                is_active: true,
                total_earned: 0
            };
        }
        
        fn record_payment(ref self: ContractState, to: ContractAddress, amount: u256, lease_id: felt252) {
            // Record payment on-chain for transparency
            let payment_id = next_payment_id.read();
            payments[payment_id] = Payment{
                from: get_caller_address(),
                to: to,
                amount: amount,
                lease_id: lease_id,
                timestamp: get_block_timestamp()
            };
            next_payment_id.write(payment_id + 1);
            
            // Update agent earnings
            agents[to].total_earned += amount;
        }

        fn get_agent(selt: @ContractState, address: ContractAddress) -> Agent {
            return agents[address];
        }
        
        fn get_agents(self: @ContractState) -> Array<Agent> {
            // Return all active agents
            []
        }
    }
}