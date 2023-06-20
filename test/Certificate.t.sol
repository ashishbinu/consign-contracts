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
    address public ada;
    address public bob;
    address public caleb;

    function setUp() public virtual {
        crt = new Certificate();
        msw = new MultiSigWallet();
        mf = new MainFactory();

        // crt.transferOwnership(address(mf));
        // crt.setApprovalForAll(address(mf), true);

        ada = address(0xADA);
        bob = address(0xB0B);
        caleb = address(0xCA1EB);
    }
}

contract IssueCertificate is CertificateTest {
    /// forge-config: default.fuzz.runs = 1000
    function test_CertificateIsIssued() public {
        address issuer = address(0xBEEF);
        address holder = address(0xB0B);
        string memory uri = "RANDOM_URI";

        vm.prank(issuer);
        uint256 id = crt.issueCertificate(holder, uri);

        assertEq(crt.balanceOf(holder), 1);
        assertEq(crt.ownerOf(id), holder);
        assertEq(crt.tokenURI(id), uri);
    }

    function test_RevertWhen_ToIs0x0() public {
        address issuer = address(0xBEEF);
        address holder = address(0x0);
        string memory uri = "RANDOM_URI";

        vm.expectRevert();
        vm.prank(issuer);
        crt.issueCertificate(holder, uri);
    }
}

contract DeleteCertificate is CertificateTest {
    address public issuer;
    address public owner;
    string public uri;
    uint256 public id;

    function setUp() public override {
        super.setUp();

        issuer = address(0xBEEF);
        owner = address(0xB0B);
        uri = "RANDOM_URI";

        vm.prank(issuer);
        id = crt.issueCertificate(owner, uri);
    }

    function test_CertificateIsDeleted() public {
        uint256 _initialBalance = crt.balanceOf(owner);

        // FIX: _msgSender() not working
        vm.prank(owner);
        crt.deleteCertificate(id);

        assertEq(crt.balanceOf(owner), _initialBalance - 1);
        vm.expectRevert("ERC721: invalid token ID");
        crt.ownerOf(id);
    }

    function test_RevertIf_NotOwner() public {
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
