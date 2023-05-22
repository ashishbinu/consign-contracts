// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {Clones} from "openzeppelin-contracts/contracts/proxy/Clones.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";

interface INFT {
    function safeMint(address _to, string memory _uri) external returns (uint256);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external;
    function approve(address _to, uint256 _tokenId) external;
    function owner() external returns (address);
}

interface IMultiSigWallet {
    function initialize(address[] memory _owners, uint256 _numConfirmationsRequired) external;
    function submitTransaction(address _to, uint256 _value, bytes memory _data) external;
    function executeTransaction(uint256 _txIndex) external;
    function revokeConfirmation(uint256 _txIndex) external;
    function getOwners() external view returns (address[] memory);
    function getTransactionCount() external view returns (uint256);
}

contract MainFactory is Ownable {
    address public certificateNFTAddress;
    address public multiSigWalletAddress;

    mapping(address => address[]) public multiSigWalletsOf;

    constructor(address _certificateNFTAddress, address _multiSigWalletAddress) {
        certificateNFTAddress = _certificateNFTAddress;
        multiSigWalletAddress = _multiSigWalletAddress;
    }

    function setCertificateNFTAddress(address _addr) external onlyOwner {
        certificateNFTAddress = _addr;
    }

    function setMultiSigWalletAddress(address _addr) external onlyOwner {
        multiSigWalletAddress = _addr;
    }

    function issueCertificate(address _to, string memory _uri) external {
        require(_to != address(0), "MainFactory: Can't issue certificate to address(0)");
        uint256 tokenId = INFT(certificateNFTAddress).safeMint(msg.sender, _uri);
        INFT(certificateNFTAddress).safeTransferFrom(msg.sender, _to, tokenId);
    }

    // TODO: burn certificate
    function deleteCertificate(uint256 tokenId) external {}

    function createMultiSigWallet(address[] memory _owners, uint256 _numConfirmationsRequired)
        external
        returns (address)
    {
        address proxy = Clones.clone(multiSigWalletAddress);
        IMultiSigWallet(proxy).initialize(_owners, _numConfirmationsRequired);

        for (uint256 i = 0; i < _owners.length; i++) {
            multiSigWalletsOf[_owners[i]].push(proxy);
        }

        return proxy;
    }
}
