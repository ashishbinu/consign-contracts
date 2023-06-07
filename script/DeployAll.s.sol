// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.17;

import {CREATE3Script} from "./base/CREATE3Script.sol";
import {MainFactory} from "../src/MainFactory.sol";
import {NFT} from "../src/NFT.sol";
import {MultiSigWallet} from "../src/MultiSigWallet.sol";
import {NFTDeployScript} from "../script/DeployNFT.s.sol";
import {MultiSigWalletDeployScript} from "../script/DeployMultiSigWallet.s.sol";
import {MainFactoryDeployScript} from "../script/DeployMainFactory.s.sol";
import "forge-std/console.sol";

contract DeployScript is CREATE3Script {
    constructor() CREATE3Script(vm.envString("VERSION")) {}

    function run() external {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));

        NFT nft = new NFTDeployScript().run();
        MultiSigWallet msw = new MultiSigWalletDeployScript().run();
        MainFactory mf = new MainFactoryDeployScript().run();

        vm.startBroadcast(deployerPrivateKey);

        mf.setCertificateNFTAddress(address(nft));
        mf.setMultiSigWalletAddress(address(msw));

        // nft.transferOwnership(address(mf));

        console.log("Certificate : %s", address(nft));
        console.log("MultiSigWallet : %s", address(msw));
        console.log("MainFactory : %s", address(mf));
        vm.stopBroadcast();
    }
}
