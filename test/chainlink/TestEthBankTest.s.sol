// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Test.sol";
import { EthBank } from "../../src/chainlink/EthBank.sol";

contract TestEthBankTest is Test {
    EthBank ethBank;
    address owner ;
    address user1 = address(0x1);
    address chainlinkUser;

    function setUp() public {
        owner = makeAddr("owner");
        chainlinkUser = makeAddr("chainlinkUser");

        vm.startPrank(owner);
        ethBank = new EthBank();
        vm.stopPrank();
    }

    function testDeposit() public {
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        ethBank.depositETH{value: 1 ether}();
        assertEq(address(ethBank).balance, 1 ether);
        vm.stopPrank();

        vm.startPrank(chainlinkUser);
        // 对收款地址进行abi编码
        bytes memory performData = abi.encode(owner);
        console.logBytes(performData);
        address account = abi.decode(performData, (address));
        console.log("account: %s", account);
        (bool upkeepNeeded, bytes memory _performData) = ethBank.checkUpkeep(performData);
        console.log("upkeepNeeded:", upkeepNeeded);
        if (upkeepNeeded) {
            address _performDataAddress = abi.decode(_performData, (address));
            console.log("_performDataAddress: %s", _performDataAddress);
            ethBank.performUpkeep(_performData);
            assert(address(owner).balance > 0);
            console.log("owner eth:", address(owner).balance / 1 ether);
        }
        vm.stopPrank();
    }
}