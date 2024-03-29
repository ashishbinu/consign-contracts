// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {Certificate} from "src/Certificate.sol";
import {MultiSigWallet} from "src/MultiSigWallet.sol";
import {MainFactory} from "src/MainFactory.sol";
import {DeployScript} from "../script/DeployAll.s.sol";

contract MultiSigWalletTest is Test {
    MainFactory public mf;
    Certificate public crt;
    MultiSigWallet public msw;

    address public issuer;
    address receiver = address(0xB0B);
    string uri = "RANDOM_URI";

    address[] owners;
    address owner1 = address(0xBEEF1);
    address owner2 = address(0xBEEF2);
    address owner3 = address(0xBEEF3);

    function setUp() public virtual {
        (mf, crt, msw) = new DeployScript().run();

        owners = new address[](3);
        owners[0] = owner1;
        owners[1] = owner2;
        owners[2] = owner3;

        issuer = mf.createMultiSigWallet(owners, 2);
    }
}

contract TransactionSubmission is MultiSigWalletTest {
    MultiSigWallet wallet;
    bytes data;

    event SubmitTransaction(
        address indexed owner, uint256 indexed txIndex, address indexed to, uint256 value, bytes data
    );

    function setUp() public override {
        super.setUp();

        wallet = MultiSigWallet(payable(issuer));
        data = abi.encodeWithSignature("issueCertificate(address,string)", receiver, uri);
    }

    function test_SubmitTransaction() public {
        vm.expectEmit();
        emit SubmitTransaction(owner1, 0, address(crt), 0, data);

        vm.prank(owner1);
        wallet.submitTransaction(address(crt), 0, data);

        uint256 transactionCount = wallet.getTransactionCount();
        assertEq(transactionCount, 1);
    }

    function test_RevertIf_CallerNotOwner() public {
        vm.expectRevert("MultiSigWallet: caller is not the owner of the wallet.");

        vm.prank(address(0x69));
        wallet.submitTransaction(address(crt), 0, data);
    }
}

contract TransactionConfirmation is MultiSigWalletTest {
    MultiSigWallet wallet;
    bytes data;

    event ConfirmTransaction(address indexed owner, uint256 indexed txIndex);

    function setUp() public override {
        super.setUp();

        wallet = MultiSigWallet(payable(issuer));
        data = abi.encodeWithSignature("issueCertificate(address,string)", receiver, uri);

        vm.prank(owner1);
        wallet.submitTransaction(address(crt), 0, data);
    }

    function test_ConfirmTransaction() public {
        uint256 _txIndex = 0;
        vm.expectEmit();
        emit ConfirmTransaction(owner2, _txIndex);

        vm.prank(owner2);
        wallet.confirmTransaction(_txIndex);

        (,,,, uint256 confirmationCount) = wallet.getTransaction(_txIndex);
        assertEq(confirmationCount, 1);

        vm.prank(owner1);
        wallet.confirmTransaction(_txIndex);

        (,,,, confirmationCount) = wallet.getTransaction(_txIndex);
        assertEq(confirmationCount, 2);
    }

    function test_RevertIf_CallerReConfirmsTransaction() public {
        uint256 _txIndex = 0;

        vm.prank(owner2);
        wallet.confirmTransaction(_txIndex);

        vm.expectRevert("MultiSigWallet: Transaction already confirmed");

        vm.prank(owner2);
        wallet.confirmTransaction(_txIndex);
    }

    function test_RevertIf_CallerNotOwner() public {
        vm.expectRevert("MultiSigWallet: caller is not the owner of the wallet.");

        vm.prank(address(0x69));
        wallet.confirmTransaction(0);
    }

    function test_RevertIf_TransactionNotExist() public {
        uint256 _txIndex = 1;

        vm.expectRevert("MultiSigWallet: Transaction does not exist");
        vm.prank(owner1);
        wallet.confirmTransaction(_txIndex);
    }
}

contract ConfirmationRevoke is MultiSigWalletTest {
    MultiSigWallet wallet;
    bytes data;
    uint256 txIndex;

    event RevokeConfirmation(address indexed owner, uint256 indexed txIndex);

    function setUp() public override {
        super.setUp();

        wallet = MultiSigWallet(payable(issuer));
        data = abi.encodeWithSignature("issueCertificate(address,string)", receiver, uri);

        vm.prank(owner1);
        wallet.submitTransaction(address(crt), txIndex, data);

        vm.prank(owner1);
        wallet.confirmTransaction(txIndex);

        vm.prank(owner2);
        wallet.confirmTransaction(txIndex);
    }

    function test_RevokeConfirmation() public {
        vm.expectEmit();
        emit RevokeConfirmation(owner2, txIndex);

        (,,,, uint256 numConfirmationsBefore) = wallet.transactions(txIndex);

        vm.prank(owner2);
        wallet.revokeConfirmation(txIndex);

        assertEq(wallet.isConfirmed(txIndex, owner2), false);

        (,,,, uint256 numConfirmationsAfter) = wallet.transactions(txIndex);

        assertEq(numConfirmationsAfter, numConfirmationsBefore - 1);
    }

    function test_RevertIf_CallerReRevokeConfirmation() public {
        vm.startPrank(owner2);
        wallet.revokeConfirmation(txIndex);

        vm.expectRevert("MultiSigWallet: Transaction not confirmed");
        wallet.revokeConfirmation(txIndex);

        vm.stopPrank();
    }

    function test_RevertIf_CallerNotOwner() public {
        vm.expectRevert("MultiSigWallet: caller is not the owner of the wallet.");

        vm.prank(address(0x69));
        wallet.revokeConfirmation(txIndex);
    }

    function test_RevertIf_TransactionNotExist() public {
        uint256 _txIndex = 1;

        vm.expectRevert("MultiSigWallet: Transaction does not exist");
        vm.prank(owner1);
        wallet.revokeConfirmation(_txIndex);
    }
}

contract TransactionExecution is MultiSigWalletTest {
    MultiSigWallet wallet;
    bytes data;
    uint256 txIndex;

    event ExecuteTransaction(address indexed owner, uint256 indexed txIndex);

    function setUp() public override {
        super.setUp();

        wallet = MultiSigWallet(payable(issuer));
        data = abi.encodeWithSignature("issueCertificate(address,string)", receiver, uri);

        txIndex = 0;
        vm.prank(owner1);
        wallet.submitTransaction(address(crt), txIndex, data);

        vm.prank(owner1);
        wallet.confirmTransaction(txIndex);
        vm.prank(owner2);
        wallet.confirmTransaction(txIndex);
    }

    function test_ExecuteTransaction() public {
        vm.expectEmit();
        emit ExecuteTransaction(owner3, txIndex);

        vm.prank(owner3);
        wallet.executeTransaction(txIndex);

        (,,, bool executed,) = wallet.transactions(txIndex);
        assert(executed);
    }

    function test_RevertIf_CallerReExecutesTransaction() public {
        vm.prank(owner3);
        wallet.executeTransaction(txIndex);

        vm.expectRevert("MultiSigWallet: Transaction already executed");

        vm.prank(owner2);
        wallet.executeTransaction(txIndex);
    }

    function test_RevertIf_CallerNotOwner() public {
        vm.expectRevert("MultiSigWallet: caller is not the owner of the wallet.");

        vm.prank(address(0x69));
        wallet.executeTransaction(txIndex);
    }

    function test_RevertIf_TransactionNotExist() public {
        uint256 _txIndex = 1;

        vm.expectRevert("MultiSigWallet: Transaction does not exist");
        vm.prank(owner1);
        wallet.executeTransaction(_txIndex);
    }
}
