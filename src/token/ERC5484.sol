// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {IERC5484} from "../interfaces/IERC5484.sol";

/* {
    name: "Name of NFT",
    description: "Detailed description of nft",
    image: "https://example.com/1",
} */

contract ERC5484 is Context, ERC165, ERC721, IERC5484 {
    bool private _isIssuing;
    mapping(uint256 => BurnAuth) private _burnAuth;
    mapping(uint256 => address) private _issuer;
    mapping(uint256 => bool) private _issued;
    mapping(uint256 => mapping(address => bool)) private _issuanceApprovalOf;

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}

    modifier isIssuing() {
        _isIssuing = true;
        _;
        _isIssuing = false;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC5484).interfaceId || super.supportsInterface(interfaceId);
    }

    function burnAuth(uint256 tokenId) public view virtual returns (BurnAuth) {
        return _burnAuthOf(tokenId);
    }

    function _hasBurnAuthorisation(address caller, uint256 tokenId) internal view virtual returns (bool) {
        bool isIssuer = caller == _issuerOf(tokenId);
        bool isOwner = caller == ERC721.ownerOf(tokenId);
        if (_burnAuthOf(tokenId) == BurnAuth.IssuerOnly && isIssuer) return true;
        if (_burnAuthOf(tokenId) == BurnAuth.OwnerOnly && isOwner) return true;
        if (_burnAuthOf(tokenId) == BurnAuth.Both && (isIssuer || isOwner)) return true;
        return false;
    }

    function _burn(uint256 tokenId) internal virtual override {
        require(_issued[tokenId], "ERC5484: unassigned token can't be burned");
        require(_hasBurnAuthorisation(_msgSender(), tokenId), "ERC5484: caller doesn't have burn authorisation");
        ERC721._burn(tokenId);
        delete _burnAuth[tokenId];
        delete _issuer[tokenId];
        delete _issued[tokenId];
    }

    function _burnAuthOf(uint256 tokenId) internal view virtual returns (BurnAuth) {
        return _burnAuth[tokenId];
    }

    function _issuerOf(uint256 tokenId) internal view virtual returns (address) {
        return _issuer[tokenId];
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        virtual
        override(ERC721)
    {
        require(_isIssuing || to == address(0), "ERC5484: token is not transferrable");
        ERC721._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // NOTE: Need to reconsider the parameters for this
    function _issuePermit(address from, address to, uint256 tokenId, BurnAuth burnAuth_, uint8 v, bytes32 r, bytes32 s)
        internal
        view
        virtual
        returns (bool)
    {
        // NOTE: give approval to from
        // NOTE: give issuanceApproval to caller
    }

    function _issue(address from, address to, uint256 tokenId, BurnAuth burnAuth_) internal virtual isIssuing {
        require(to != address(0), "ERC5484: token can't be issued to 0x0");
        require(!_issued[tokenId], "ERC5484: token is already issued");
        // FIX: require(_issuanceApprovalOf[tokenId][to], "ERC5484: token is not approved for issuance by receiver");

        // TODO: burnAuth SHALL be presented to receiver before issuance.
        // TODO: The issuer SHALL present token metadata to the receiver and acquire receiver’s signature before issuance.
        // TODO: burnAuth SHALL be Immutable after issuance.
        // TODO: The issuer SHALL NOT change metadata after issuance.

        ERC721._safeMint(from, tokenId);
        _burnAuth[tokenId] = burnAuth_;

        ERC721.safeTransferFrom(from, to, tokenId);

        _issued[tokenId] = true;
        _issuer[tokenId] = from;

        emit Issued(from, to, tokenId, burnAuth_);
    }

    // TODO: convert this to equivalent of approvals and operators in NFT
    function _setIssuanceApproval(uint256 tokenId, address to, bool approve) internal virtual {
        address owner = ownerOf(tokenId);
        require(owner == _msgSender(), "ERC5484: caller is the not the receiver of the token");
        _issuanceApprovalOf[tokenId][to] = approve;
    }
}
