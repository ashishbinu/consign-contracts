.PHONY: deploy build abi
build:
	forge build

abi: build
	rm -rf abi
	mkdir -p abi
	mv ./out/MainFactory.sol/MainFactory.json abi/
	mv ./out/NFT.sol/NFT.json abi/
	mv ./out/MultiSigWallet.sol/MultiSigWallet.json abi/

deploy: build abi
	forge script script/DeployAll.s.sol --fork-url ${DEV_URL} --broadcast
