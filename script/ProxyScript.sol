// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Script, console } from "forge-std/Script.sol";
import { Nft } from "../src/proxy/Nft.sol";
import { UUPSProxy } from "../src/proxy/UUPSProxy.sol";
import { OldNftMarket } from "../src/proxy/OldNftMarket.sol";
import { V2NftMarket } from "../src/proxy/V2NftMarket.sol";

contract ProxyScript is Script {
    function setUp() public { }

    function run() public {
        address owner = vm.envAddress("ACCOUNT_ADDRESS");
        vm.startBroadcast();
        Nft nft = new Nft();
        console.log("NFT deployed at:", address(nft));

        OldNftMarket oldNftMarket = new OldNftMarket();
        console.log("OldNftMarket deployed at:", address(oldNftMarket));

        // 初始化 OldNftMarket
        bytes memory initData = abi.encodeWithSignature("initialize(address)", owner);
        UUPSProxy proxy = new UUPSProxy(address(oldNftMarket), initData);
        console.log("UUPSProxy deployed at:", address(proxy));

        // 部署 V2NftMarket 合约
        V2NftMarket v2NftMarket = new V2NftMarket();
        console.log("V2NftMarket deployed at:", address(v2NftMarket));

        vm.stopBroadcast();
    }
}
