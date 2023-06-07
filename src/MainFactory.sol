// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Clones} from "openzeppelin-contracts/contracts/proxy/Clones.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {NFT} from "./NFT.sol";
import {MultiSigWallet} from "./MultiSigWallet.sol";

contract MainFactory is Ownable {
    NFT public nft;
    MultiSigWallet public multiSigWallet;

    mapping(address => address[]) public multiSigWalletsOf;

   function setCertificateNFTAddress(address _addr) external onlyOwner {
        nft = NFT(_addr);
    }

    function setMultiSigWalletAddress(address _addr) external onlyOwner {
        multiSigWallet = MultiSigWallet(payable(_addr));
    }

    function issueCertificate(address _to, string memory _uri) external returns (uint256){
        require(_to != address(0), "MainFactory: Can't issue certificate to address(0)");
        uint256 tokenId = nft.safeMint(msg.sender, _uri);
        nft.safeTransferFrom(msg.sender, _to, tokenId);
        return tokenId;
    }

    // TODO: burn certificate
    function deleteCertificate(uint256 tokenId) external {
        nft.burn(tokenId);
    }

    function createMultiSigWallet(address[] memory _owners, uint256 _numConfirmationsRequired)
        external
        returns (address)
    {
        address proxy = Clones.clone(address(multiSigWallet));
        MultiSigWallet(payable(proxy)).initialize(_owners, _numConfirmationsRequired);

        for (uint256 i = 0; i < _owners.length; i++) {
            multiSigWalletsOf[_owners[i]].push(proxy);
        }

        return proxy;
    }
}
