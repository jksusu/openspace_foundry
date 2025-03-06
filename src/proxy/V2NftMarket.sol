// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract V2NftMarket is UUPSUpgradeable, OwnableUpgradeable {
    struct NftInfo {
        address nftAddress; //nft地址
        uint256 tokenId; //nft tokenId
        uint256 price; //nft价格
        address owner; //nft所有者
    }

    mapping(uint256 => NftInfo) public Listings; // tokenId => NftInfo

    event Debug(address owner);
    event List(address owner, uint256 tokenId, address nftAddress, uint256 price);

    function initialize(address owner) public initializer {
        emit Debug(owner);
        __Ownable_init(owner);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner { }

    // 普通上架，不进行检查
    function list(uint256 tokenId, address nftAddress, uint256 price) public {
        emit Debug(msg.sender);
        Listings[tokenId] = NftInfo(nftAddress, tokenId, price, msg.sender);
    }

    function getByTokenId(uint256 tokenId) public view returns (address) {
        return Listings[tokenId].owner;
    }
}
