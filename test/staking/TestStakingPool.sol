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

        IERC20(address(kk)).approve(address(stakingPool), 100e18); //授权给质押池
        vm.stopPrank();
    }

    function testStake() public {
        uint256 stakeAmount = 1 ether; //质押金额
        vm.deal(alice, 1 ether);
        vm.startPrank(alice);
        stakingPool.stake{ value: stakeAmount }();
        //验证eth是否为零
        assertEq(address(alice).balance, 0, "Incorrect0 ETH balance after staking");
        //验证质押总量，我的质押数量，最后区块是否被改变
        assertEq(stakingPool.getStakesETHTotal(), stakeAmount, "Incorrect total staked ETH");
        assertEq(stakingPool.getLastBlock(), block.number, "Incorrect last block");
        assertEq(stakingPool.balanceOf(alice), stakeAmount, "Incorrect user staking balance");
        vm.stopPrank();

        uint256 oldStakesETHTotal = stakingPool.getStakesETHTotal();//旧的质押总量
        uint256 oldLastBlock = stakingPool.getLastBlock();//旧的最后区块

        vm.deal(bob, stakeAmount);
        vm.startPrank(bob);
        stakingPool.stake{ value: stakeAmount }();
        //验证eth是否为零
        assertEq(address(bob).balance, 0, "Incorrect1 ETH balance after staking");
        uint256 newLastBlock = stakingPool.getLastBlock(); //新的最后区块

        //验证最新的数量是否 = + old 数量
        assertEq(stakingPool.getStakesETHTotal(), oldStakesETHTotal + stakeAmount, "Incorrect2 total staked ETH");
        assertEq(newLastBlock, oldLastBlock, "Incorrect last block");
        assertEq(stakingPool.balanceOf(bob), stakeAmount, "Incorrect user staking balance");

        //验证 alice 用户的质押奖励是否正确
        // uint256 blockNumber = newLastBlock - oldLastBlock;
        // uint256 reward = blockNumber * 1e18;




        IERC20(kk).balanceOf(alice);


        vm.stopPrank();
    }
}
