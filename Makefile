-include .env

deployScript:; forge script script/DeployFundMe.s.sol --rpc-url $(GANACHE_RPC_URL) --private-key $(GANACHE_PRIVATE_KEY_1) --broadcast
deploy-sepolia:
	orge script script/DeployFundMe.s.sol --rpc-url $(SEPOLIA_RPC_URL) --private-key $(GANACHE_PRIVATE_KEY_1) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv