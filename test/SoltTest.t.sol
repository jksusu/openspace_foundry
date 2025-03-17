// SPDX-License-Identifier: MIT

import { Test } from "forge-std/Test.sol";
import { Solt } from "../src/Solt.sol";

pragma solidity ^0.8.26;

contract SoltTest is Test {
    Solt public contractInstance;

    function setUp() public {
        contractInstance = new Solt("MyWallet");
    }

    function testExample() public {
        // Add your test logic here
        address test = makeAddr("test");
        vm.startPrank(test);
        contractInstance.setOwnerViaAssembly(test);
    }
}
