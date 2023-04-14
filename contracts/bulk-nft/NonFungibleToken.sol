// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./interface/IERC5679Ext721.sol";

contract NonFungibleToken is Ownable, ERC721URIStorage, IERC5679Ext721 {
    constructor(
        string memory name_,
        string memory symbol_,
        address minter_
    ) ERC721(name_, symbol_) {
        _transferOwnership(minter_);
    }

    function safeMint(
        address _to,
        uint256 _id,
        bytes calldata _data
    ) public virtual override onlyOwner {
        _safeMint(_to, _id, _data);
        _setTokenURI(_id, string(_data));
    }

    function burn(
        address _from,
        uint256 _id,
        bytes calldata _data
    ) public virtual override {
        require(_from == ownerOf(_id), "From address is not token owner");
        require(_msgSender() == _from || isApprovedForAll(_from, _msgSender()) || getApproved(_id) == _msgSender(),
            "Caller is not token owner or approved");
        _burn(_id);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC5679Ext721).interfaceId || super.supportsInterface(interfaceId);
    }
}
