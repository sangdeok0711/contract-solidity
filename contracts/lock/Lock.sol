// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Lock is Context, Ownable, IERC721Receiver {

    struct TokenInfo {
        address owner;
        address nftAddress;
        uint256 tokenId;
        string lockInfo;
    }

    struct OwnerIndex {
        address owner;
        uint256 index;
    }

    // Mapping from owner to locked token count
    mapping(address => uint256) private _lockedBalances;

    // Mapping from owner index to locked token
    mapping(address => mapping(uint256 => TokenInfo)) private _ownedTokenInfos;

    // Mapping from nft to owner index
    mapping(address => mapping(uint256 => OwnerIndex)) private _tokenOwnerIndex;

    event NftLock (
        address indexed owner,
        address indexed nftAddress,
        address operator,
        uint256 tokenId
    );

    event NftUnlock (
        address indexed owner,
        address indexed nftAddress,
        uint256 tokenId
    );

    constructor(address owner) {
        _transferOwnership(owner);
    }

    function ownerOf(address nftAddress, uint256 tokenId) public view virtual returns (address) {
        return _tokenOwnerIndex[nftAddress][tokenId].owner;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual returns (TokenInfo memory) {
        require(index < _lockedBalances[owner], "Lock: owner index out of bounds");
        return _ownedTokenInfos[owner][index];
    }

    function lockedBalance(address owner) public view virtual returns (uint256) {
        return _lockedBalances[owner];
    }

    function lockOwner() public view virtual returns (address) {
        return owner();
    }

    function updateLockOwner(address newOwner) public virtual onlyOwner {
        _transferOwnership(newOwner);
    }

    function _lock(address operator, address owner, address nftAddress, uint256 tokenId, bytes memory data) internal virtual {
        IERC721 targetNft = IERC721(nftAddress);
        require(targetNft.ownerOf(tokenId) == address(this), "Lock: not sent token");

        uint256 length = _lockedBalances[owner];
        _ownedTokenInfos[owner][length] = TokenInfo(owner, nftAddress, tokenId, string(data));
        _tokenOwnerIndex[nftAddress][tokenId] = OwnerIndex(owner, length);

        _lockedBalances[owner] += 1;

        emit NftLock(owner, nftAddress, operator, tokenId);
    }

    function unlock(address nftAddress, uint256 tokenId) public virtual onlyOwner {

        OwnerIndex memory ownerIndex = _tokenOwnerIndex[nftAddress][tokenId];
        require(ownerIndex.owner != address(0), "Lock: not found token");

        uint256 lastIndex = lockedBalance(ownerIndex.owner) - 1;
        TokenInfo memory lastTokenInfo = _ownedTokenInfos[ownerIndex.owner][lastIndex];
        if(ownerIndex.index != lastIndex) {
            _ownedTokenInfos[ownerIndex.owner][ownerIndex.index] = lastTokenInfo;
            _tokenOwnerIndex[lastTokenInfo.nftAddress][lastTokenInfo.tokenId] = ownerIndex;
        }

        delete _tokenOwnerIndex[nftAddress][tokenId];
        delete _ownedTokenInfos[ownerIndex.owner][lastIndex];

        _lockedBalances[ownerIndex.owner] -= 1;

        IERC721 targetNft = IERC721(nftAddress);
        targetNft.transferFrom(address(this), ownerIndex.owner, tokenId);

        emit NftUnlock(ownerIndex.owner, nftAddress, tokenId);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external virtual override returns (bytes4) {
        _lock(operator, from, _msgSender(), tokenId, data);
        return IERC721Receiver.onERC721Received.selector;
    }
}
