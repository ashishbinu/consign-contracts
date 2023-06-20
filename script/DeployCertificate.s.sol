// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.17;

import {CREATE3Script} from "./base/CREATE3Script.sol";
import {Certificate} from "../src/Certificate.sol";
import {IERC5484} from "../src/interfaces/IERC5484.sol";
import {MainFactoryDeployScript} from "./DeployMainFactory.s.sol";

contract CertificateDeployScript is CREATE3Script {
    constructor() CREATE3Script(vm.envString("VERSION")) {}

    function run() external returns (Certificate c) {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));

        vm.startBroadcast(deployerPrivateKey);

        c = Certificate(
            create3.deploy(getCreate3ContractSalt("Certificate"), bytes.concat(type(Certificate).creationCode))
        );

        vm.stopBroadcast();
    }
}
