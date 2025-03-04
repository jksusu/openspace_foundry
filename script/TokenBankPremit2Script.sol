// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Script, console } from "forge-std/Script.sol";
import { TokenBankPremit2 } from "../src/tokenBank/TokenBankPremit2.sol";
import { Erc20TokenPremit2 } from "../src/tokenBank/Erc20TokenPremit2.sol";

// forge script script/TokenBankPremit2Script.s.sol:TokenBankPremit2Script --rpc-url 127.0.0.1:8545 --broadcast --sender 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
contract TokenBankPremit2Script is Script {
    //0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
    TokenBankPremit2 public c;

    function setUp() public { }

    function run() public {
        vm.startBroadcast();
        c = new TokenBankPremit2(Erc20TokenPremit2(0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512), 0x000000000022D473030F116dDEE9F6B43aC78BA3);
        vm.stopBroadcast();
        console.log("MyToken deployed to:", address(c));
    }
}
