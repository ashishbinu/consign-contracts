// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.17;

import {CREATE3Script} from "./base/CREATE3Script.sol";
import {NFT} from "../src/NFT.sol";
import {BurnAuth} from "../src/EnumDeclaration.sol";

contract DeployScript is CREATE3Script {
    constructor() CREATE3Script(vm.envString("VERSION")) {}

    function run() external returns (NFT c) {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));

        string memory name = "Certificate";
        string memory symbol = "CRT";
        string memory baseURI = "https://example.com";
        BurnAuth burnAuth = BurnAuth.ReceiverOnly;

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
