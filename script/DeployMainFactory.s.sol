// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.17;

import {CREATE3Script} from "./base/CREATE3Script.sol";
import {MainFactory} from "../src/MainFactory.sol";

contract MainFactoryDeployScript is CREATE3Script {
    constructor() CREATE3Script(vm.envString("VERSION")) {}

    function run() external returns (MainFactory c) {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));

        vm.startBroadcast(deployerPrivateKey);

        c = MainFactory(create3.deploy(getCreate3ContractSalt("NFT"), bytes.concat(type(MainFactory).creationCode)));

        vm.stopBroadcast();
    }
}
