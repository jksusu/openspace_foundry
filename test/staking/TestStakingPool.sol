// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console } from "forge-std/Test.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { StakingPool } from "../../src/staking/StakingPool.sol";
import { KK } from "../../src/staking/KK.sol";

contract TestStakingPool is Test {
    StakingPool public stakingPool;
    KK public kk;

    address owner = makeAddr("owner");
    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");

    function setUp() public {
        vm.startPrank(owner);
        // 部署质押合约和代币合约
        kk = new KK();
        stakingPool = new StakingPool(address(kk));

        //给所有用户加余额
        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);

        IERC20(address(kk)).approve(address(stakingPool), 1e12); //授权给质押池
        vm.stopPrank();
    }

    function testStake() public {
        uint256 stakeAmount = 1 ether;
        vm.startPrank(alice);
        uint256 aliceOldETHBalance = address(alice).balance;
        stakingPool.stake{ value: stakeAmount }();
        assertEq(address(alice).balance, aliceOldETHBalance - stakeAmount, "Incorrect0 ETH balance after staking");
        assertEq(stakingPool.getStakesETHTotal(), stakeAmount, "Incorrect total staked ETH");
        assertEq(stakingPool.getLastBlock(), block.number, "Incorrect last block");
        assertEq(stakingPool.balanceOf(alice), stakeAmount, "Incorrect user staking balance");
        vm.stopPrank();

        uint256 oldStakesETHTotal = stakingPool.getStakesETHTotal();//旧的质押总量
        uint256 oldLastBlock = stakingPool.getLastBlock();//旧的最后区块

        vm.deal(bob, stakeAmount);
        vm.startPrank(bob);
        stakingPool.stake{ value: stakeAmount }();

        assertEq(address(bob).balance, address(bob).balance - stakeAmount, "Incorrect1 ETH balance after staking");
        uint256 newLastBlock = stakingPool.getLastBlock();

        //验证最新的数量是否 = + old 数量
        assertEq(stakingPool.getStakesETHTotal(), oldStakesETHTotal + stakeAmount, "Incorrect2 total staked ETH");
        assertEq(newLastBlock, oldLastBlock, "Incorrect last block");
        assertEq(stakingPool.balanceOf(bob), stakeAmount, "Incorrect user staking balance");
        IERC20(kk).balanceOf(alice);
        vm.stopPrank();
    }
}
