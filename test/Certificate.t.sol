// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import {Certificate} from "src/Certificate.sol";
import {MultiSigWallet} from "src/MultiSigWallet.sol";
import {MainFactory} from "src/MainFactory.sol";
import {IERC5484} from "src/interfaces/IERC5484.sol";

contract CertificateTest is Test {
    MainFactory public mf;
    Certificate public nft;
    MultiSigWallet public msw;
    address public ada;
    address public bob;
    address public caleb;

    function setUp() public {
        nft = new Certificate();
        msw = new MultiSigWallet();
        mf = new MainFactory();

        // nft.transferOwnership(address(mf));
        // nft.setApprovalForAll(address(mf), true);

        ada = address(0xADA);
        bob = address(0xB0B);
        caleb = address(0xCA1EB);
    }
}
