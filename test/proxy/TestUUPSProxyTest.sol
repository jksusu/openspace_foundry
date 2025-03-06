// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console } from "forge-std/Test.sol";
import { OldNftMarket } from "../../src/proxy/OldNftMarket.sol";
import { V2NftMarket } from "../../src/proxy/V2NftMarket.sol";
import { UUPSProxy } from "../../src/proxy/UUPSProxy.sol";

contract TestUUPSTest is Test {
    OldNftMarket oldNftMarket;
    UUPSProxy proxy;
    V2NftMarket v2NftMarket;
    address owner;
    address sellerUser;

    function setUp() public {
        //初始化管理员
        owner = makeAddr("owner");
        sellerUser = makeAddr("sellerUser");
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
        bytes memory listv2 = abi.encodeWithSignature("list(uint256,address,uint256)", 2, sellerUser, 100);
        (bool successv2,) = address(proxy).call(listv2);
        assert(successv2);

        bytes memory getByTokenv2Id = abi.encodeWithSignature("getByTokenId(uint256)", 2);
        (, bytes memory getResv2) = address(proxy).call(getByTokenv2Id);
        assert(abi.decode(getResv2, (address)) == sellerUser);
        vm.stopPrank();
    }
}
