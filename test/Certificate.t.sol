// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import {Certificate} from "src/Certificate.sol";
import {MultiSigWallet} from "src/MultiSigWallet.sol";
import {MainFactory} from "src/MainFactory.sol";
import {IERC5484} from "src/interfaces/IERC5484.sol";

contract CertificateTest is Test {
    MainFactory public mf;
    Certificate public crt;
    MultiSigWallet public msw;

    address public issuer;
    address public receiver;
    string public uri;

    function setUp() public virtual {
        crt = new Certificate();
        msw = new MultiSigWallet();
        mf = new MainFactory();

        // crt.transferreceivership(address(mf));
        // crt.setApprovalForAll(address(mf), true);
        issuer = address(0xBEEF);
        receiver = address(0xB0B);
        uri = "RANDOM_URI";
    }
}

contract IssueCertificate is CertificateTest {

    /// forge-config: default.fuzz.runs = 1000
    function test_CertificateIsIssued() public {
        vm.prank(issuer);
        uint256 id = crt.issueCertificate(receiver, uri);

        assertEq(crt.balanceOf(receiver), 1);
        assertEq(crt.ownerOf(id), receiver);
        assertEq(crt.tokenURI(id), uri);
    }

    function test_RevertWhen_CertificateIsIssuedTo0x0() public {
        address receiver = address(0x0);

        vm.expectRevert();
        vm.prank(issuer);
        crt.issueCertificate(receiver, uri);
    }
}

contract DeleteCertificate is CertificateTest {
    uint256 public id;

    function setUp() public override {
        super.setUp();

        vm.prank(issuer);
        id = crt.issueCertificate(receiver, uri);
    }

    function test_CertificateIsDeleted() public {
        uint256 _initialBalance = crt.balanceOf(receiver);

        vm.prank(receiver);
        crt.deleteCertificate(id);

        assertEq(crt.balanceOf(receiver), _initialBalance - 1);
        vm.expectRevert("ERC721: invalid token ID");
        crt.ownerOf(id);
    }

    function test_RevertIf_Notreceiver() public {
        vm.expectRevert();
        vm.prank(address(0x069));
        crt.deleteCertificate(id);
    }

    /* function test_RevertWhen_CallerIs0x0() public {
        address caller = address(0x0);
        vm.expectRevert("ERC721: mint to the zero address");
        vm.prank(caller);
    } */
}
