// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {NFT} from "src/NFT.sol";
import {MultiSigWallet} from "src/MultiSigWallet.sol";
import {MainFactory} from "src/MainFactory.sol";
import {IERC5484} from "src/interfaces/IERC5484.sol";

contract MainFactoryTest is Test {
    MainFactory public mf;
    NFT public nft;
    MultiSigWallet public msw;
    string public constant NAME = "Certificate";
    string public constant SYMBOL = "CRT";
    string public constant BASE_URI = "https://example.com/";

    function setUp() public virtual {
        mf = new MainFactory();
        nft = new NFT(NAME, SYMBOL, BASE_URI, IERC5484.BurnAuth.OwnerOnly, address(mf));
        msw = new MultiSigWallet();

        mf.setCertificateNFTAddress(address(nft));
        mf.setMultiSigWalletAddress(address(msw));

        // nft.transferOwnership(address(mf));
        // nft.setApprovalForAll(address(mf), true);
    }
}

contract IssueCertificate is MainFactoryTest {
    /// forge-config: default.fuzz.runs = 1000
    function test_CertificateIsIssued() public {
        address issuer = address(0xBEEF);
        address holder = address(0xB0B);
        string memory uri = "RANDOM_URI";

        vm.prank(issuer);
        uint256 id = mf.issueCertificate(holder, uri);

        assertEq(nft.balanceOf(holder), 1);
        assertEq(nft.ownerOf(id), holder);
        assertEq(nft.tokenURI(id), string.concat(BASE_URI, uri));
    }

    function test_RevertWhen_ToIs0x0() public {
        address issuer = address(0xBEEF);
        address holder = address(0x0);
        string memory uri = "RANDOM_URI";

        vm.expectRevert();
        vm.prank(issuer);
        mf.issueCertificate(holder, uri);
    }
}

contract DeleteCertificate is MainFactoryTest {
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
        id = mf.issueCertificate(owner, uri);
    }

    function test_CertificateIsDeleted() public {
        uint256 _initialBalance = nft.balanceOf(owner);


        // FIX: _msgSender() not working
        vm.prank(owner);
        mf.deleteCertificate(id);

        assertEq(nft.balanceOf(owner), _initialBalance - 1);
        vm.expectRevert("ERC721: invalid token ID");
        nft.ownerOf(id);
    }

    function test_RevertIf_NotOwner() public {
        vm.expectRevert();
        vm.prank(address(0x069));
        mf.deleteCertificate(id);
    }

    /* function test_RevertWhen_CallerIs0x0() public {
        address caller = address(0x0);
        vm.expectRevert("ERC721: mint to the zero address");
        vm.prank(caller);
    } */
}
