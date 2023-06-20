// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {Certificate} from "src/Certificate.sol";
import {MultiSigWallet} from "src/MultiSigWallet.sol";
import {MainFactory} from "src/MainFactory.sol";
import {IERC5484} from "src/interfaces/IERC5484.sol";

contract MainFactoryTest is Test {
    MainFactory public mf;
    Certificate public nft;
    MultiSigWallet public msw;

    function setUp() public virtual {
        mf = new MainFactory();
        nft = new Certificate();
        msw = new MultiSigWallet();

        mf.setMultiSigWalletAddress(address(msw));

        // nft.transferOwnership(address(mf));
        // nft.setApprovalForAll(address(mf), true);
    }
}


