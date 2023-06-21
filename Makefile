.PHONY: build test format lint abi deploy deploy-dryrun
build:
	forge build

test:
	forge test -vvvv

format:
	forge fmt

lint:
	solhint src/**/*.sol && solhint src/*.sol

abi: build
	rm -rf abi
	mkdir -p abi
	mv ./out/MainFactory.sol/MainFactory.json abi/
	mv ./out/Certificate.sol/Certificate.json abi/
	mv ./out/MultiSigWallet.sol/MultiSigWallet.json abi/

deploy-dryrun: build abi
	forge script script/DeployAll.s.sol --fork-url ${DEV_URL}

deploy: build abi
	forge script script/DeployAll.s.sol --fork-url ${DEV_URL} --broadcast

deploy-with-private-key: build abi
	forge script script/DeployAll.s.sol --fork-url ${DEV_URL} --broadcast --private-key ${PRIVATE_KEY} --legacy
