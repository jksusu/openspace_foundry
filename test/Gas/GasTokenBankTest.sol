// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/Gas/TokenBank.sol";

contract GasTokenBankTest is Test {
    TokenBank tokenBank;

    // 测试用户地址
    address initAddress = address(1);
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");
    address user4 = makeAddr("user4");
    address user5 = makeAddr("user5");
    address user6 = makeAddr("user6");
    address user7 = makeAddr("user7");
    address user8 = makeAddr("user8");
    address user9 = makeAddr("user9");
    address user10 = makeAddr("user10");
    address user11 = makeAddr("user11");

    function setUp() public {
        tokenBank = new TokenBank();

        // 为所有测试用户分配初始资金
        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);
        vm.deal(user3, 100 ether);
        vm.deal(user4, 100 ether);
        vm.deal(user5, 100 ether);
        vm.deal(user6, 100 ether);
        vm.deal(user7, 100 ether);
        vm.deal(user8, 100 ether);
        vm.deal(user9, 100 ether);
        vm.deal(user10, 100 ether);
        vm.deal(user11, 100 ether);
    }

    function testDepositTest() public {
        //第一个用户存款
        vm.startPrank(user1);
        console.log("one", initAddress);
        tokenBank.deposit(initAddress, 10 ether);
        assertEq(tokenBank.tokenBalanceOf(user1), 10 ether);
        vm.stopPrank();

        vm.startPrank(user2);
        tokenBank.deposit(user1, 9 ether);
        assertEq(tokenBank.tokenBalanceOf(user2), 9 ether);
        vm.stopPrank();

        vm.startPrank(user3);
        tokenBank.deposit(user2, 8 ether);
        assertEq(tokenBank.tokenBalanceOf(user3), 8 ether);
        vm.stopPrank();

        vm.startPrank(user4);
        tokenBank.deposit(user3, 7 ether);
        assertEq(tokenBank.tokenBalanceOf(user4), 7 ether);
        vm.stopPrank();

        vm.startPrank(user5);
        tokenBank.deposit(user4, 6 ether);
        assertEq(tokenBank.tokenBalanceOf(user5), 6 ether);
        vm.stopPrank();

        vm.startPrank(user6);
        tokenBank.deposit(user5, 5 ether);
        assertEq(tokenBank.tokenBalanceOf(user6), 5 ether);
        vm.stopPrank();

        vm.startPrank(user7);
        tokenBank.deposit(user6, 4 ether);
        assertEq(tokenBank.tokenBalanceOf(user7), 4 ether);
        vm.stopPrank();

        vm.startPrank(user8);
        tokenBank.deposit(user7, 3 ether);
        assertEq(tokenBank.tokenBalanceOf(user8), 3 ether);
        vm.stopPrank();

        vm.startPrank(user9);
        tokenBank.deposit(user8, 2 ether);
        assertEq(tokenBank.tokenBalanceOf(user9), 2 ether);
        vm.stopPrank();

        vm.startPrank(user10);
        tokenBank.deposit(user9, 1 ether);
        assertEq(tokenBank.tokenBalanceOf(user10), 1 ether);
        vm.stopPrank();

        vm.startPrank(user11);
        tokenBank.deposit(user10, 100000);
        assertEq(tokenBank.tokenBalanceOf(user11), 100000);
        vm.stopPrank();

        //验证排名
        address[] memory addressArr = tokenBank.getTop(10);
        assertEq(addressArr.length, 10);
    }
}
