// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.17;

import {Certificate} from "../src/Certificate.sol";
import {MainFactory} from "../src/MainFactory.sol";
import {MultiSigWallet} from "../src/MultiSigWallet.sol";
import {IERC5484} from "../src/interfaces/IERC5484.sol";
import "forge-std/Test.sol";
import "forge-std/console2.sol";

contract Deploy is Test {
    function run() external {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));

        vm.startBroadcast(deployerPrivateKey);

        address c = address(new MainFactory());
        address a = address(new Certificate());
        address b = address(new MultiSigWallet());

        MainFactory(c).setMultiSigWalletAddress(b);

        console2.log("Certificate : ", a);
        console2.log("MultiSigWallet : ", b);
        console2.log("MainFactory : ", c);

        vm.stopBroadcast();
    }
}
