.PHONY: build test node format lint deploy deploy-dryrun
build:
	forge build

test:
	forge test -vvvv

node-fork:
	anvil --fork-url ${RPC_URL_MUMBAI}

node-local:
	anvil --chain-id 69420

format:
	forge fmt

lint:
	solhint src/**/*.sol && solhint src/*.sol

deploy-dryrun:
	forge script script/DeployAll.s.sol --fork-url ${DEV_URL}

deploy:
	forge script script/DeployAll.s.sol --fork-url ${DEV_URL} --broadcast

deploy-with-private-key:
	forge script script/DeployAll.s.sol --fork-url ${DEV_URL} --broadcast --private-key ${PRIVATE_KEY} --legacy
