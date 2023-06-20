// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {ERC721URIStorage} from "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ERC721Enumerable} from "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {Context} from "openzeppelin-contracts/contracts/utils/Context.sol";
import {Counters} from "openzeppelin-contracts/contracts/utils/Counters.sol";
import {ERC5484} from "./ERC5484.sol";

contract Certificate is Context, ERC721Enumerable, ERC721URIStorage, ERC5484 {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC5484("Certificate", "CRT") {}

    function issueCertificate(address to, string memory tokenURI_) external {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        // TODO: Get approval from the receiver to issue
        // _setIssuanceApproval(tokenId, to, true);
        _issue(_msgSender(), to, tokenId, BurnAuth.OwnerOnly);
        _setTokenURI(tokenId, tokenURI_);
    }

    function deleteCertificate(uint256 tokenId) external {
        _burn(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC5484)
        returns (bool)
    {
        return ERC721Enumerable.supportsInterface(interfaceId) || ERC5484.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return ERC721URIStorage.tokenURI(tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage, ERC5484) {
        ERC5484._burn(tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable, ERC5484)
    {
        ERC5484._beforeTokenTransfer(from, to, tokenId, batchSize);
    }
}
