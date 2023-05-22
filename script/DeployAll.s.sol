// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.17;

import {CREATE3Script} from "./base/CREATE3Script.sol";
import {MainFactory} from "../src/MainFactory.sol";
import {NFT} from "../src/NFT.sol";
import {MultiSigWallet} from "../src/MultiSigWallet.sol";
import {NFTDeployScript} from "../script/DeployNFT.s.sol";
import {MultiSigWalletDeployScript} from "../script/DeployMultiSigWallet.s.sol";
import "forge-std/console.sol";

contract DeployScript is CREATE3Script {
    constructor() CREATE3Script(vm.envString("VERSION")) {}

    function run() external returns (MainFactory mf) {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));

        NFT nft = new NFTDeployScript().run();
        MultiSigWallet msw = new MultiSigWalletDeployScript().run();

        vm.startBroadcast(deployerPrivateKey);

        mf = MainFactory(
            create3.deploy(
                getCreate3ContractSalt("MainFactory"),
                bytes.concat(type(MainFactory).creationCode, abi.encode(address(nft), address(msw)))
            )
        );

        nft.transferOwnership(address(mf));

        console.log("Certificate : %s", address(nft));
        console.log("MultiSigWallet : %s", address(msw));
        console.log("MainFactory : %s", address(mf));
        vm.stopBroadcast();
    }
}
