// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.17;

import {NFT} from "../src/NFT.sol";
import {MainFactory} from "../src/MainFactory.sol";
import {MultiSigWallet} from "../src/MultiSigWallet.sol";
import {IERC5484} from "../src/interfaces/IERC5484.sol";
import "forge-std/Test.sol";
import "forge-std/console2.sol";

contract Deploy is Test {
    function run() external {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));

        string memory name = "Certificate";
        string memory symbol = "CRT";
        string memory baseURI = "https://example.com";
        IERC5484.BurnAuth burnAuth = IERC5484.BurnAuth.OwnerOnly;

        vm.startBroadcast(deployerPrivateKey);

        address c = address(new MainFactory());
        address a = address(new NFT(name,symbol,baseURI,burnAuth,c));
        address b = address(new MultiSigWallet());

        console2.log("NFT : ", a);
        console2.log("MultiSigWallet : ", b);
        console2.log("MainFactory : ", c);

        vm.stopBroadcast();
    }
}
