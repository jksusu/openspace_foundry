// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Script, console } from "forge-std/Script.sol";
import { Erc20TokenPremit2 } from "../src/tokenBank/Erc20TokenPremit2.sol";

// forge script script/Erc20TokenPremit2Script.s.sol:Erc20TokenPremit2Script --rpc-url 127.0.0.1:8545 --broadcast --sender 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
contract Erc20TokenPremit2Script is Script {
    // 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
    Erc20TokenPremit2 public mytoken;

    function setUp() public { }

    function run() public {
        vm.startBroadcast();
        mytoken = new Erc20TokenPremit2();
        vm.stopBroadcast();
        console.log("MyToken deployed to:", address(mytoken));
    }
}
