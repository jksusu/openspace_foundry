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

    // 上架 NFT
    function list(uint256 tokenId, uint256 price) external {
        //检查上架的nft拥有者是否是当前发起交易的用户
        require(nft.ownerOf(tokenId) == msg.sender, "not owner");
        //上架需要nft拥有者把nft转移到交易所
        nft.transferFrom(msg.sender, address(this), tokenId);
        listings[tokenId] = Listing({ seller: msg.sender, price: price });
    }

    // 购买 NFT
    function buyNFT(uint256 tokenId) external {
        Listing memory listing = listings[tokenId];
        require(listing.price > 0, "NFT not listed");
        //调用 token 转账函数转账给交易所，交易所转账给卖家 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
        token.transferWithCallback(msg.sender, address(this), listing.price);
        token.transfer(listing.seller, listing.price);
        //需要把 nft 转给买家，需要交易所上架的时候把nft转移到交易所，或者授权给交易所，这里直接转移到付款人的地址上去
        nft.safeTransferFrom(address(this), msg.sender, tokenId);

        delete listings[tokenId]; //删除上架列表
    }

    //收到转账后，sender调用此方法用户改变 合约状态
    function tokensReceived(address from, uint256 amount) external returns (bool) {
        balances[address(token)][from] += amount;
        emit TokensReceived(from, amount);
        return true;
    }
}
