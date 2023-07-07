// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {Certificate} from "src/Certificate.sol";
import {MultiSigWallet} from "src/MultiSigWallet.sol";
import {MainFactory} from "src/MainFactory.sol";
import {DeployScript} from "../script/DeployAll.s.sol";
import "forge-std/Test.sol";

contract MainFactoryTest is Test {
    MainFactory public mf;
    Certificate public crt;
    MultiSigWallet public msw;
    address[] owners;
    address owner1 = address(0xBEEF1);
    address owner2 = address(0xBEEF2);
    address owner3 = address(0xBEEF3);
    address owner4 = address(0xBEEF4);
    address owner5 = address(0xBEEF5);
    address owner6 = address(0xBEEF6);
    address owner7 = address(0xBEEF7);

    address public walletProxy1;
    address public walletProxy2;
    address[] owners2;

    function setUp() public virtual {
        (mf, crt, msw) = new DeployScript().run();

        owners = new address[](5);
        owners[0] = owner1;
        owners[1] = owner2;
        owners[2] = owner3;
        owners[3] = owner4;
        owners[4] = owner5;

        owners2 = new address[](3);
        owners2[0] = owner5;
        owners2[1] = owner6;
        owners2[2] = owner7;

        walletProxy1 = mf.createMultiSigWallet(owners, 3);
        walletProxy2 = mf.createMultiSigWallet(owners2, 2);
    }
}

contract MainFactoryConstructor is MainFactoryTest {
    function setUp() public override {}

    function test_MainFactoryConstructor() public {
        MainFactory mf = new MainFactory(address(0xADD69), address(0xBEEF));
        assertEq(mf.owner(), address(0xBEEF));
    }
}

contract CreateMultiSigWallet is MainFactoryTest {
    function test_MultiSigWalletCreation() public {
        address proxy = mf.createMultiSigWallet(owners, 3);
        MultiSigWallet wallet = MultiSigWallet(payable(proxy));
        assertEq(wallet.getOwners(), owners);
    }
}

contract MultiSigWalletsOf is MainFactoryTest {
    function test_MultiSigWalletOf() public {
        address[] memory wallets = new address[](2);
        wallets[0] = walletProxy1;
        wallets[1] = walletProxy2;

        assertEq(mf.multiSigWalletsOf(owner5), wallets);
    }
}
