// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Script, console } from "forge-std/Script.sol";
import { TokenBank } from "../src/tokenBank/TokenBank.sol";

contract MyTokenScript is Script {
    TokenBank public tokenBank;

    function setUp() public { }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey); //开始广播交易
        tokenBank = new TokenBank();
        vm.stopBroadcast(); //停止广播

        console.log("tokenBank deployed to:", address(tokenBank)); //输出合约地址
    }
}
