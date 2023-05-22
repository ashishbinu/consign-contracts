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
    address public ada;
    address public bob;
    address public charlie;

    function setUp() public {
        nft = new NFT("Certificate","CRT","https://example.com",IERC5484.BurnAuth.OwnerOnly);
        msw = new MultiSigWallet();
        mf = new MainFactory(address(nft),address(msw));

        nft.transferOwnership(address(mf));
        nft.setApprovalForAll(address(mf), true);

        ada = address(0xADA);
        bob = address(0xB0B);
        charlie = address(0xC7A81E);
    }

    function testExample() public {
        vm.startPrank(address(0xB0B));
        console2.log("Hello world!");
        assertTrue(true);
    }

    /// forge-config: default.fuzz.runs = 1000
    function testIssueCertificate(address ada) public {
        require(ada != address(msw) && ada != address(nft) && ada != address(0));
        vm.prank(bob);
        mf.issueCertificate(ada, "https://example.com");
        assertEq(nft.balanceOf(ada), 1);
    }
}
