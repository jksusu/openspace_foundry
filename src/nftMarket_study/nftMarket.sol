// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./baseERC20.sol";

contract NFTMarket {
    struct Listing {
        address seller;
        uint256 price;
    }

    mapping(uint256 => Listing) public listings;
    mapping(address => mapping(address => uint256)) public balances; //付款记录

    BaseERC20 public token;
    IERC721 public nft;

    event TokensReceived(address, uint256);

    constructor(BaseERC20 _token, IERC721 _nft) {
        token = _token;
        nft = _nft;
    }

    function getNftByTokenId(uint256 tokenId) public view returns (Listing memory) {
        return listings[tokenId];
    }

    // 上架 NFT
    function list(uint256 tokenId, uint256 price) external {
        //检查上架的nft拥有者是否是当前发起交易的用户
        require(nft.ownerOf(tokenId) == msg.sender, "not owner");
        //上架需要nft拥有者把nft转移到交易所
        nft.transferFrom(msg.sender, address(this), tokenId);
        listings[tokenId] = Listing({ seller: msg.sender, price: price });
    }

    function buyNFT(address buyAddress, uint256 tokenId) private {
        Listing memory listing = listings[tokenId];
        require(listing.price > 0, "NFT not listed");
        token.transfer(listing.seller, listing.price);
        nft.transferFrom(address(this), buyAddress, tokenId);
        delete listings[tokenId];
    }

    function tokensReceived(address from, uint256 amount, uint256 tokenId) external returns (bool) {
        require(listings[tokenId].seller != address(0), "does not exist");
        require(amount == listings[tokenId].price, "Insufficient amount");
        buyNFT(from, tokenId);
        emit TokensReceived(from, amount);
        return true;
    }
}
