// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract V2NftMarket is UUPSUpgradeable, OwnableUpgradeable {
    using ECDSA for bytes32;

    struct NftInfo {
        address nftAddress; //nft地址
        uint256 tokenId; //nft tokenId
        uint256 price; //nft价格
        address owner; //nft所有者
    }

    mapping(uint256 => NftInfo) public Listings; // tokenId => NftInfo
    mapping(address => uint256) public nonces; //用户签名递增值，防重放

    event Debug(address owner);
    event List(address owner, uint256 tokenId, address nftAddress, uint256 price);

    function initialize(address owner) public initializer {
        __Ownable_init(owner);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner { }

    // 普通上架，不进行检查
    function list(address proxyAddress, uint256 tokenId, address nftAddress, uint256 price, uint256 expireTime, uint256 nonce, bytes memory signature) public {
        require(block.timestamp < expireTime, "expireTime error");
        require(nonce == nonces[msg.sender], "nonce error");
        nonces[msg.sender]++;

        bytes32 hash = keccak256(abi.encodePacked(tokenId, nftAddress, price, expireTime, nonce));
        address signer = hash.recover(signature);
        emit Debug(msg.sender);
        emit Debug(signer);
        require(signer == msg.sender, "sign errors");
        //授权给代理地址，转移给代理
        IERC721(nftAddress).transferFrom(msg.sender, proxyAddress, tokenId);
        Listings[tokenId] = NftInfo(nftAddress, tokenId, price, msg.sender);
        emit List(msg.sender, tokenId, nftAddress, price);
    }

    function getByTokenId(uint256 tokenId) public view returns (address) {
        return Listings[tokenId].owner;
    }
}
