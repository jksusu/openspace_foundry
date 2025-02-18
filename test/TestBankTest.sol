// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Bank} from "../src/Bank.sol";

contract TestBankTest is Test {
    Bank public bank;

    function setUp() public {
        bank = new Bank();
    }

    function test_depositETH() public {
        uint oldBanlance = address(this).balance; //当前钱包余额
        uint depositAmount = 1 ether; //存款金额

        vm.deal(address(this), depositAmount);
        bank.depositETH{value: depositAmount}();

        // vm.expectEmit(true, true, false, true);
        // emit bank.Deposit(address(this), depositAmount);

        // 检查存款额更新
        assertEq(bank.balanceOf(address(this)), depositAmount);
        assertEq(address(this).balance, oldBanlance - depositAmount);
    }
}
