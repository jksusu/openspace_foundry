// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console } from "forge-std/Test.sol";
import { OldNftMarket } from "../../src/proxy/OldNftMarket.sol";
import { V2NftMarket } from "../../src/proxy/V2NftMarket.sol";
import { UUPSProxy } from "../../src/proxy/UUPSProxy.sol";
import { Nft } from "../../src/proxy/Nft.sol";

contract TestUUPSTest is Test {
    OldNftMarket oldNftMarket;
    UUPSProxy proxy;
    V2NftMarket v2NftMarket;

    Nft nft;
    uint256 nftPrice;
    uint256 tokenId;

    address owner;
    address sellerUser;
    uint256 sellerUserKey;

    function setUp() public {
        owner = makeAddr("owner");
        (sellerUser, sellerUserKey) = makeAddrAndKey("sellerUser");

        nft = new Nft();

        vm.startPrank(sellerUser);
        tokenId = nft.mintNFT("https://baidu.com");
        vm.stopPrank();
    }

    function testList() public {
        vm.startPrank(owner);
        oldNftMarket = new OldNftMarket();
        console.log("oldNftMarket", address(oldNftMarket));

        //需要调用的方法签名
        bytes memory initData = abi.encodeWithSignature("initialize(address)", owner);
        proxy = new UUPSProxy(address(oldNftMarket), initData);
        console.log("UUPSProxy", address(oldNftMarket));
        vm.stopPrank();

        vm.startPrank(sellerUser);
        console.log("proxy", address(proxy));
        // 通过代理合约调用OldNftMarket合约的li
        bytes memory list = abi.encodeWithSignature("list(uint256,address,uint256)", 1, sellerUser, 100);
        (bool success,) = address(proxy).call(list);
        assert(success);

        bytes memory getByTokenId = abi.encodeWithSignature("getByTokenId(uint256)", 1);
        (, bytes memory getRes) = address(proxy).call(getByTokenId);
        assert(abi.decode(getRes, (address)) == sellerUser);
        vm.stopPrank();

        vm.startPrank(owner);
        //部署 v2
        v2NftMarket = new V2NftMarket();
        console.log("v2NftMarket", address(v2NftMarket));
        bytes memory v2NftMarketSign = abi.encodeWithSignature("upgradeToAndCall(address,bytes)", address(v2NftMarket), new bytes(0));
        (bool saveAddressSuccess,) = address(proxy).call(v2NftMarketSign);
        assert(saveAddressSuccess);
        vm.stopPrank();

        //上架v2
        vm.startPrank(sellerUser);
        //批量授权
        nft.setApprovalForAll(address(proxy), true);
        //查询授权是否成功
        assert(nft.isApprovedForAll(sellerUser, address(proxy)));

        //对nft上架进行签名
        uint256 nonceId = v2NftMarket.nonces(sellerUser);
        uint256 expireTime = block.timestamp + 1 hours;
        console.log("nonceId", nonceId);
        console.log("expireTime", expireTime);

        //签名
        bytes32 hash = keccak256(abi.encodePacked(tokenId, address(nft), nftPrice, expireTime, nonceId));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(sellerUserKey, hash);
        bytes memory sign = abi.encodePacked(r, s, v);

        bytes memory listv2 = abi.encodeWithSignature("list(address,uint256,address,uint256,uint256,uint256,bytes)", address(proxy), tokenId, address(nft), nftPrice, expireTime, nonceId, sign);
        (bool successv2,) = address(proxy).call(listv2);
        assert(successv2);

        bytes memory getByTokenv2Id = abi.encodeWithSignature("getByTokenId(uint256)", tokenId);
        (, bytes memory getResv2) = address(proxy).call(getByTokenv2Id);
        assert(abi.decode(getResv2, (address)) == sellerUser);
        vm.stopPrank();
    }
}
