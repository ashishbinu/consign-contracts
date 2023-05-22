// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.17;

import {CREATE3Script} from "./base/CREATE3Script.sol";
import {NFT} from "../src/NFT.sol";
import {IERC5484} from "../src/interfaces/IERC5484.sol";

contract NFTDeployScript is CREATE3Script {
    constructor() CREATE3Script(vm.envString("VERSION")) {}

    function run() external returns (NFT c) {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));

        string memory name = "Certificate";
        string memory symbol = "CRT";
        string memory baseURI = "https://example.com";
        IERC5484.BurnAuth burnAuth = IERC5484.BurnAuth.OwnerOnly;

        vm.startBroadcast(deployerPrivateKey);

        c = NFT(
            create3.deploy(
                getCreate3ContractSalt("NFT"),
                bytes.concat(type(NFT).creationCode, abi.encode(name, symbol, baseURI, burnAuth))
            )
        );
        // c = new NFT(name,symbol);

        vm.stopBroadcast();
    }
}
