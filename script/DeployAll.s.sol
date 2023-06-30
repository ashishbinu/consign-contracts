// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {CREATE3Script} from "./base/CREATE3Script.sol";
import {MainFactory} from "../src/MainFactory.sol";
import {Certificate} from "../src/Certificate.sol";
import {MultiSigWallet} from "../src/MultiSigWallet.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {DeterministicDeploy} from "./base/DeterministicDeploy.sol";
import "forge-std/console.sol";

contract DeployScript is CREATE3Script {
    constructor() CREATE3Script(vm.envString("VERSION")) {}

    function run() external returns (MainFactory, Certificate, MultiSigWallet) {
        HelperConfig helperConfig = new HelperConfig();
        uint256 deployerPrivateKey = helperConfig.getPrivateKey();

        vm.startBroadcast(deployerPrivateKey);

        Certificate crt = new Certificate{salt: bytes32(0)}();
        MultiSigWallet msw = new MultiSigWallet{salt: bytes32(0)}();
        MainFactory mf = new MainFactory{salt: bytes32(0)}(address(msw),msg.sender);

        // Certificate crt = Certificate(
        //     create3.deploy(
        //         getCreate3ContractSalt("Certificate"), bytes.concat(type(Certificate).creationCode, abi.encode())
        //     )
        // );
        // MultiSigWallet msw = MultiSigWallet(
        //     payable(
        //         create3.deploy(
        //             getCreate3ContractSalt("MultiSigWallet"),
        //             bytes.concat(type(MultiSigWallet).creationCode, abi.encode())
        //         )
        //     )
        // );
        // MainFactory mf = MainFactory(
        //     create3.deploy(
        //         getCreate3ContractSalt("MainFactory"), bytes.concat(type(MainFactory).creationCode, abi.encode())
        //     )
        // );

        vm.stopBroadcast();

        return (mf, crt, msw);
    }
}
