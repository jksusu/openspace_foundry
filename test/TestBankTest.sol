// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Bank} from "../src/Bank.sol";

contract CounterTest is Test {
    Bank public bank;

    function setUp() public {
        bank = new Bank();
    }

    function test_depositETH() public {
        vm.expectEmit(true, false, false, true);
        emit Bank.Deposit(address(this), 100);

        bank.depositETH{value: 100}();
        assertEq(address(bank).balance, 100);
    }
}