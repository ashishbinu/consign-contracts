// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MultiSigWallet} from "./MultiSigWallet.sol";

contract MainFactory is Ownable {
    MultiSigWallet public multiSigWallet;

    mapping(address => address[]) private _multiSigWalletsOf;

    event MultiSigWalletCreated(address indexed wallet, address[] indexed owners);

    constructor(address _addr, address owner) {
        multiSigWallet = MultiSigWallet(payable(_addr));
        transferOwnership(owner);
    }

    function setMultiSigWalletAddress(address _addr) external onlyOwner {
        multiSigWallet = MultiSigWallet(payable(_addr));
    }

    function createMultiSigWallet(address[] memory _owners, uint256 _numConfirmationsRequired)
        external
        returns (address)
    {
        address proxy = Clones.clone(address(multiSigWallet));
        MultiSigWallet(payable(proxy)).initialize(_owners, _numConfirmationsRequired);

        for (uint256 i = 0; i < _owners.length; i++) {
            _multiSigWalletsOf[_owners[i]].push(proxy);
        }

        emit MultiSigWalletCreated(proxy, _owners);
        return proxy;
    }

    function multiSigWalletsOf(address owner) public view returns (address[] memory) {
        return _multiSigWalletsOf[owner];
    }
}
