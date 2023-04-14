# Bulk NFT Contract
## Simple Summary
Extension of ERC721 for batch creation of NFTs("minting").

## Description
We want to mint NFTs to multiple accounts in one transaction.
1. Minter can mint multiple NFTs to multiple accounts.
2. Data(to, tokenID, tokenURI) required for minting will be received as an array of the same size.

## Specification
```solidity
interface BulkNonFungibleToken /* is ERC721, IERC5679Ext721 */ {
    /// @notice batch creation of NFTs 
    /// @param _tos The owner list
    /// @param _tokenIds The identifier list for NFTs
    /// @param _datas The NFT URI(Metadata JSON Schema) list
    ///  To comply with the ERC5679 specification, the token URI is received as a bytes type.
    function bulkMint(address[] calldata _tos, uint256[] calldata _tokenIds, bytes[] calldata _datas) external;
}
```

## Standard Interface Used
* [ERC-721](https://eips.ethereum.org/EIPS/eip-721)
* [ERC-5679#IERC5679Ext721](https://eips.ethereum.org/EIPS/eip-5679)