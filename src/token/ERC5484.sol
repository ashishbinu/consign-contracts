// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {ERC165} from "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";
import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
// import {ERC721URIStorage} from "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Context} from "openzeppelin-contracts/contracts/utils/Context.sol";
import {IERC5484} from "../interfaces/IERC5484.sol";

contract ERC5484 is Context, ERC165, ERC721, IERC5484 {
    mapping(uint256 => BurnAuth) private _burnAuth;

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC5484).interfaceId || super.supportsInterface(interfaceId);
    }

    function burnAuth(uint256 tokenId) public view virtual returns (BurnAuth) {
        return _burnAuthOf(tokenId);
    }

    function _hasBurnAuthorisation(address caller, uint256 tokenId) internal view virtual returns (bool) {}

    function _burn(uint256 tokenId) internal virtual override {
        require(_hasBurnAuthorisation(_msgSender(), tokenId), "ERC5484: caller doesn't have burn authorisation");
        ERC721._burn(tokenId);
    }

    function _burnAuthOf(uint256 tokenId) internal view virtual returns (BurnAuth) {
        return _burnAuth[tokenId];
    }

    function _issue(address from, address to, uint256 tokenId, BurnAuth burnAuth_) internal virtual {
        emit Issued(from, to, tokenId, burnAuth_);
    }
}
