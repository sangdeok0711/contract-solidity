# Lock Contract
## Simple Summary
Implementation for locking NFTs under the contract's custody.

## Description
We want to be able to lock NFTs for specific purposes(e.g. exchange for in-game items).
1. NFT owners can lock their tokens by sending them to this contract.
2. Locked NFTs should only be unlockable by the owner of this contract, because of server-side verification.
3. It is possible to know who the owner of the locked NFT is.

## Specification
```solidity
interface Lock /* is ERC721TokenReceiver */ {

    /// @dev This emits when an NFT are transferred to this contract using safeTransferFrom.
    event NftLock (address indexed owner, address indexed nftAddress, address operator, uint256 tokenId);
    /// @dev This emits when a contract owner returns the NFT to the actual owner.
    event NftUnlock (address indexed owner, address indexed nftAddress, uint256 tokenId);

    /// @notice Find the owner of a locked NFT
    /// @param nftAddress The address of NFT contract
    /// @param tokenId The identifier for an NFT
    /// @return The address of the owner of the locked NFT
    function ownerOf(address nftAddress, uint256 tokenId) external view returns (address);

    /// @notice Enumerate locked NFTs assigned to an owner
    /// @param owner An address where we are interested in locked NFTs owned by them
    /// @param index A counter less than `lockedBalance(owner)`
    /// @return The token information for the `_index`th locked NFT assigned to `_owner`,
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (TokenInfo memory);

    /// @notice Count locked NFTs assigned to an owner
    /// @param owner An address for whom to query the balance
    /// @return The number of locked NFTs owned by `owner`
    function lockedBalance(address owner) external view returns (uint256);

    /// @notice Find the owner of this contract (who has unlock authority)
    /// @return The address of the owner of this contract
    function lockOwner() external view returns (address);

    /// @notice Change the owner of this contract (who has unlock authority)
    /// @param newOwner A new owner address with
    function updateLockOwner(address newOwner) external;

    /// @notice Transfers the ownership of an NFT from this contract to the actual owner
    /// @param nftAddress The address of NFT contract
    /// @param tokenId The identifier for an NFT
    function unlock(address nftAddress, uint256 tokenId) external;

    /// @notice Handle the receipt of an NFT (lock process)
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns (bytes4);
}
```

## Standard Interface Used
* [ERC-721#ERC721TokenReceiver](https://eips.ethereum.org/EIPS/eip-721)
