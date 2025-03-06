// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./baseERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract NFTMarketPremit2 {
    struct nftInfo {
        address seller;
        uint256 price;
        string name;
        string ipfs;
    }

    mapping(uint256 => nftInfo) public listings; //上架信息 tokenId => nftInfo

    BaseERC20 public token;
    IERC721 public nft;

    event NFTListed(uint256 tokenId, nftInfo info); //上架事件
    event NFTBuyed(address buy, address seller, uint256 tokenId, nftInfo info); //购买nft事件

    constructor(BaseERC20 _token, IERC721 _nft) {
        token = _token;
        nft = _nft;
    }

    function getListByTokenId(uint256 tokenId) public view returns (nftInfo memory) {
        return listings[tokenId];
    }

    // 上架 NFT
    function list(uint256 tokenId, string memory ipfs, string memory name, uint256 amount, uint256 deadline, bytes memory signature) internal returns (bool) {
        bytes32 message = keccak256(abi.encodePacked(tokenId, ipfs, name, amount, deadline));
        bytes32 hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", message));
        address signer = ECDSA.recover(hash, signature);
        require(signer == msg.sender, "Invalid signature");

        //授权给交易所
        nft.approve(address(this), tokenId);
        nft.safeTransferFrom(msg.sender, address(this), tokenId);

        //上架nft
        listings[tokenId] = nftInfo({ seller: msg.sender, price: amount, name: name, ipfs: ipfs });
        return true;
    }

    // 使用ETH买入NFT
    function buyNFT(uint256 tokenId) external payable {
        nftInfo memory listing = listings[tokenId];
        require(msg.value >= listing.price, "Insufficient ETH");

        // 转移NFT
        nft.safeTransferFrom(listing.seller, msg.sender, tokenId);

        // 支付ETH给卖家
        (bool sent,) = listing.seller.call{ value: listing.price }("");
        require(sent, "ETH transfer failed");

        delete listings[tokenId];

        emit NFTBuyed(msg.sender, listing.seller, tokenId, listing);
    }
}
