// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import {ERC721Enumerable} from "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC721URIStorage} from "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ERC721Burnable} from "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {Counters} from "openzeppelin-contracts/contracts/utils/Counters.sol";
import {ERC2771Context} from "openzeppelin-contracts/contracts/metatx/ERC2771Context.sol";
import {Context} from "openzeppelin-contracts/contracts/utils/Context.sol";
import {IERC5484} from "src/interfaces/IERC5484.sol";
import "forge-std/console2.sol";

// REFERENCE: https://github.com/Bisonai/sbt-contracts/blob/master/contracts/SBT.sol
contract NFT is ERC2771Context, ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Burnable, IERC5484, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    string private __baseURI;
    BurnAuth private immutable __burnAuth;
    mapping(uint256 => bool) private _issued;
    // tokenId -> [issuer, receiver]
    mapping(uint256 => address[2]) private _issuerOwnerOf;

    constructor(
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        BurnAuth burnAuth_,
        address forwarder
    ) ERC2771Context(forwarder) ERC721(name_, symbol_) {
        __baseURI = baseURI_;
        __burnAuth = burnAuth_;
    }

    modifier onlyBurnAuthorised(uint256 tokenId) {
        BurnAuth burnAuthorisation = _burnAuth(tokenId);
        if (burnAuthorisation == BurnAuth.Both) {
            require(
                _msgSender() == _issuerOwnerOf[tokenId][0] || _msgSender() == _issuerOwnerOf[tokenId][1],
                "NFT: Only issuer and owner has burn authorisation"
            );
        } else if (burnAuthorisation == BurnAuth.Neither) {
            require(false, "NFT: No one has the burn authorisation");
        } else if (burnAuthorisation == BurnAuth.OwnerOnly) {
            console2.log("sender :", _msgSender());
            require(_msgSender() == _issuerOwnerOf[tokenId][1], "NFT: Only owner has burn authorisation");
        } else {
            require(_msgSender() == _issuerOwnerOf[tokenId][0], "NFT: Only issuer has burn authorisation");
        }
        _;
    }

    function safeMint(address to, string memory uri) external returns (uint256) {
        console2.log(_msgSender());
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        return tokenId;
    }

    // TODO: Make it better later
    function burnAuth(uint256 tokenId) external view returns (BurnAuth) {
        require(_issued[tokenId], "NFT: Unassigned token id's are invalid");
        return _burnAuth(tokenId);
    }

    // function isApprovedForAll(address owner, address operator) public view override(ERC721, IERC721) returns (bool) {
    //     return msg.sender == super.owner() || super.isApprovedForAll(owner, operator);
    // }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    // TODO: Update it to support the interface like in ERC5484
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

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
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) onlyBurnAuthorised(tokenId) {
        delete _issued[tokenId];
        delete _issuerOwnerOf[tokenId];
        super._burn(tokenId);
    }

    function _baseURI() internal view override returns (string memory) {
        return __baseURI;
    }

    function _msgSender() internal view override(Context, ERC2771Context) returns (address) {
        return ERC2771Context._msgSender();
    }

    function _msgData() internal view override(Context, ERC2771Context) returns (bytes calldata) {
        return ERC2771Context._msgData();
    }

    function _issueToken(address from, address to, uint256 tokenId) private {
        _issued[tokenId] = true;
        _issuerOwnerOf[tokenId] = [from, to];
        emit Issued(from, to, tokenId, __burnAuth);
    }

    function _burnAuth(uint256 tokenId) private view returns (BurnAuth) {
        return __burnAuth;
    }
}
