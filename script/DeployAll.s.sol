// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.17;

import {CREATE3Script} from "./base/CREATE3Script.sol";
import {MainFactory} from "../src/MainFactory.sol";
import {NFTDeployScript} from "../script/DeployNFT.s.sol";
import {MultiSigWalletDeployScript} from "../script/DeployMultiSigWallet.s.sol";
import "forge-std/console.sol";

contract DeployScript is CREATE3Script {
    constructor() CREATE3Script(vm.envString("VERSION")) {}

    function run() external returns (MainFactory c) {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));

        address certficateAddress = address(new NFTDeployScript().run());
        address multiSigWalletAddress = address(new MultiSigWalletDeployScript().run());

        vm.startBroadcast(deployerPrivateKey);

        c = MainFactory(
            create3.deploy(
                getCreate3ContractSalt("MainFactory"),
                bytes.concat(type(MainFactory).creationCode, abi.encode(certficateAddress, multiSigWalletAddress))
            )
        );

        console.log("Certificate : %s", certficateAddress);
        console.log("MultiSigWallet : %s", multiSigWalletAddress);
        console.log("MainFactory : %s", address(c));
        vm.stopBroadcast();
    }
}
