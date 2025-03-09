// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract Nft is ERC721URIStorage {
    uint256 number = 0;

    constructor() ERC721("MyNFT", "MNFT") { }

    function mintNFT(string memory tokenURI) public returns (uint256) {
        uint256 newItemId = number += 1;
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
        return newItemId;
    }
}
