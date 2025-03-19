// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @dev 质押池合约 每个区块出 10个KK Token，分配给当前质押的用户，公平分布
 */
contract StakingPool is Ownable, ReentrancyGuard {
    mapping(address => uint256) public stakes;     // 用户质押记录
    mapping(address => uint256) public unclaimed;  // 待领取的收益
    mapping(address => uint256) public rewardDebt; // 已经领取的总数，下一次计算的时候再减去这个值

    uint256 public stakesETHTotal;                 // 质押ETH总量
    uint256 public lastBlock;                      // 上次更新奖励的区块
    uint256 public accRewardPerShare;              // 每单位质押量的累计奖励
    uint256 constant public BLOCK_REWARD = 10e18; // 每个区块10 KK Token
    uint256 constant public MIN_STAKE_AMOUNT = 1 ether; // 最小质押金额
    
    address public KKToken;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event Claimed(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    constructor(address kk) Ownable(msg.sender) {
        KKToken = kk;
        lastBlock = block.number;
    }

    receive() external payable {}

    // 更新奖励池
    function _updatePool() private {
        if (block.number <= lastBlock || stakesETHTotal == 0) {
            lastBlock = block.number;
            return;
        }
        uint256 blocks = block.number - lastBlock;
        uint256 reward = blocks * BLOCK_REWARD;
        accRewardPerShare += (reward * 1e18) / stakesETHTotal;
        lastBlock = block.number;
    }

    /**
     * @dev 质押 ETH 到合约
     */
    function stake() external payable nonReentrant {
        require(msg.value >= MIN_STAKE_AMOUNT, "Amount Min");
        
        _updatePool();
        
        if (stakes[msg.sender] > 0) {
            uint256 pending = (stakes[msg.sender] * accRewardPerShare) / 1e18 - rewardDebt[msg.sender];
            if (pending > 0) {
                unclaimed[msg.sender] += pending;
            }
        }
        
        stakes[msg.sender] += msg.value;
        stakesETHTotal += msg.value;
        rewardDebt[msg.sender] = (stakes[msg.sender] * accRewardPerShare) / 1e18;
        
        emit Staked(msg.sender, msg.value);
    }

    /**
     * @dev 赎回质押的 ETH
     */
    function unstake(uint256 amount) external nonReentrant {
        require(stakes[msg.sender] >= amount, "Insufficient balance");
        
        _updatePool();
        
        uint256 pending = (stakes[msg.sender] * accRewardPerShare) / 1e18 - rewardDebt[msg.sender];
        if (pending > 0) {
            unclaimed[msg.sender] += pending;
        }
        
        stakes[msg.sender] -= amount;
        stakesETHTotal -= amount;
        rewardDebt[msg.sender] = (stakes[msg.sender] * accRewardPerShare) / 1e18;
        
        payable(msg.sender).transfer(amount);
        emit Unstaked(msg.sender, amount);
    }

    /**
     * @dev 领取 KK Token 收益
     */
    function claim() external nonReentrant {
        _updatePool();
        
        uint256 pending = (stakes[msg.sender] * accRewardPerShare) / 1e18 - rewardDebt[msg.sender];
        if (pending > 0) {
            unclaimed[msg.sender] += pending;
        }
        
        uint256 amount = unclaimed[msg.sender];
        require(amount > 0, "No rewards to claim");
        
        unclaimed[msg.sender] = 0;
        rewardDebt[msg.sender] = (stakes[msg.sender] * accRewardPerShare) / 1e18;
        
        IERC20(KKToken).transfer(msg.sender, amount);
        emit Claimed(msg.sender, amount);
    }

    /**
     * @dev 获取质押的 ETH 数量
     */
    function balanceOf(address account) external view returns (uint256) {
        return stakes[account];
    }

    /**
     * @dev 获取待领取的 KK Token 收益
     */
    function earned(address account) external view returns (uint256) {
        uint256 tempAccRewardPerShare = accRewardPerShare;
        if (block.number > lastBlock && stakesETHTotal > 0) {
            uint256 blocks = block.number - lastBlock;
            uint256 reward = blocks * BLOCK_REWARD;
            tempAccRewardPerShare += (reward * 1e18) / stakesETHTotal;
        }
        uint256 pending = (stakes[account] * tempAccRewardPerShare) / 1e18 - rewardDebt[account];
        return unclaimed[account] + pending;
    }

    function getLastBlock() external view returns (uint256) {
        return lastBlock;
    }

    function getStakesETHTotal() external view returns (uint256) {
        return stakesETHTotal;
    }

    /**
     * @dev 提现ETH
     */
    function withdraw(uint256 amount) external onlyOwner nonReentrant {
        payable(msg.sender).transfer(amount);
        emit Withdrawn(msg.sender, amount);
    }
}