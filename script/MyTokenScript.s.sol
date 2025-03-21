// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Script, console } from "forge-std/Script.sol";
import { MyToken } from "../src/MyToken.sol";

contract MyTokenScript is Script {
    MyToken public mytoken;

    function setUp() public { }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey); //开始广播交易
        mytoken = new MyToken("MyToken", "MTK");
        vm.stopBroadcast(); //停止广播

        console.log("MyToken deployed to:", address(mytoken)); //输出合约地址
    }
}
