// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import {ERC721Enumerable} from "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC721URIStorage} from "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ERC721Burnable} from "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {Counters} from "openzeppelin-contracts/contracts/utils/Counters.sol";
import {IERC5484} from "src/interfaces/IERC5484.sol";

// REFERENCE: https://github.com/Bisonai/sbt-contracts/blob/master/contracts/SBT.sol
contract NFT is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Burnable, Ownable {
    event Issued(address indexed from, address indexed to, uint256 indexed tokenId, IERC5484.BurnAuth burnAuth);

    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    string private __baseURI;
    IERC5484.BurnAuth private immutable _burnAuth;
    mapping(uint256 => bool) private _issued;

    constructor(string memory name_, string memory symbol_, string memory baseURI_, IERC5484.BurnAuth burnAuth_)
        ERC721(name_, symbol_)
    {
        __baseURI = baseURI_;
        _burnAuth = burnAuth_;
    }

    function safeMint(address to, string memory uri) external onlyOwner returns (uint256) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        return tokenId;
    }

    // TODO: Make it better later
    function burnAuth( /*uint256 tokenId*/ ) external view returns (IERC5484.BurnAuth) {
        return _burnAuth;
    }

    function isApprovedForAll(address owner, address operator) public view override(ERC721, IERC721) returns (bool) {
        return msg.sender == super.owner() || super.isApprovedForAll(owner, operator);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    // TODO: Update it to support the interface like in ERC5484
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _baseURI() internal view override returns (string memory) {
        return __baseURI;
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        // require(from == address(0), "NFT: Token not transferable");
        require(!_issued[tokenId], "NFT: Token is already issued");
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _afterTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721)
    {
        super._afterTokenTransfer(from, to, tokenId, batchSize);
        if (from != address(0)) {
            _issueToken(from, to, tokenId);
        }
    }

    // TODO: do the burning validation later. add modifiers to functions
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        // require(, "NFT: Caller doesn't have burn permission");
        _issued[tokenId] = false;
        super._burn(tokenId);
    }

    function _issueToken(address from, address to, uint256 tokenId) private {
        _issued[tokenId] = true;
        emit Issued(from, to, tokenId, _burnAuth);
    }
}
