// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.17;

import {CREATE3Script} from "./base/CREATE3Script.sol";
import {MultiSigWallet} from "../src/MultiSigWallet.sol";

contract DeployScript is CREATE3Script {
    constructor() CREATE3Script(vm.envString("VERSION")) {}

    function run() external returns (MultiSigWallet c) {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));

        vm.startBroadcast(deployerPrivateKey);

        c = MultiSigWallet(
            payable(
                create3.deploy(
                    getCreate3ContractSalt("MultiSigWallet"), bytes.concat(type(MultiSigWallet).creationCode)
                )
            )
        );

        vm.stopBroadcast();
    }
}
