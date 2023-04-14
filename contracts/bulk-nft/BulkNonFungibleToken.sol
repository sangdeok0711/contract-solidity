// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./NonFungibleToken.sol";

contract BulkNonFungibleToken is NonFungibleToken {
    uint16 private immutable _maxBatchSize = 200;

    constructor(
        string memory name_,
        string memory symbol_,
        address minter_
    ) NonFungibleToken(name_, symbol_, minter_) {}

    function bulkMint(
        address[] calldata _tos,
        uint256[] calldata _tokenIds,
        bytes[] calldata _datas
    ) external virtual onlyOwner {
        uint batchSize = _tos.length;

        require(_maxBatchSize >= batchSize, "Batch too large");
        require(_tokenIds.length == batchSize, "Mismatched number of parameters");
        require(_datas.length == batchSize, "Mismatched number of parameters");

        for(uint i = 0; i < batchSize; i++) {
            safeMint(_tos[i], _tokenIds[i], _datas[i]);
        }
    }
}
