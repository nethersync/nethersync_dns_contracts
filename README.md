declare command
sncast --profile=sepolia declare \
     --contract-name=NSAgent
declare hash = 0x016f6a9833d17efa5420644b787cd66417ea5652ae3df1d24bc93ff281b1e5ee

deploy command
sncast --profile=sepolia deploy \
--class-hash 0x016f6a9833d17efa5420644b787cd66417ea5652ae3df1d24bc93ff281b1e5ee 

deploy address = 0x00d7ab1e702c61c3eb468f7c7436bff133a6e8669b4cb8ed7bd05f0b9a86480a

register_agent command
sncast --profile=sepolia invoke \
--contract-address 0x00d7ab1e702c61c3eb468f7c7436bff133a6e8669b4cb8ed7bd05f0b9a86480a \
--function 'register_agent' \
--arguments '"http::localhost:8000/api/v1/dns_agents"'