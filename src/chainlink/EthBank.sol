pragma solidity ^0.8.28;

interface AutomationCompatibleInterface {
    function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData);
    function performUpkeep(bytes calldata performData) external;
}

/**
 * 测试 https://automation.chain.link
 * 阈值hook
 */
contract EthBank {
    mapping(address => uint256) public balanceOf;

    event Deposit(address indexed user, uint256 amount);

    function depositETH() external payable {
        balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function checkUpkeep(bytes calldata checkData) external view returns (bool upkeepNeeded, bytes memory performData) {
        upkeepNeeded = false;
        if (address(this).balance > 0) {
             upkeepNeeded = true;
        }
        performData = checkData;
        return (upkeepNeeded, performData);
    }

    function performUpkeep(bytes calldata performData) external {
        address account = abi.decode(performData, (address));
        if (address(this).balance > 0) {
            payable(account).transfer(address(this).balance);
        }
    }
}
