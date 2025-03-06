// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/create/Factroy.sol";
import "../src/create/Traget.sol";

contract Create2Script is Script {
    function run() external {
        // 启动广播（模拟交易）
        vm.startBroadcast();
        // 部署 Factory 合约
        Factory factory = new Factory();
        console.log("Factory deployed at:", address(factory));

        // 获取 Target 合约的字节码
        bytes memory targetBytecode = type(Target).creationCode;
        uint256 value = 42;
        bytes memory constructorArgs = abi.encode(value);
        bytes memory fullBytecode = abi.encodePacked(targetBytecode, constructorArgs);

        // 设置 salt
        bytes32 salt = keccak256(abi.encodePacked("my-salt"));

        // 预测地址
        address predictedAddress = factory.predictAddress(salt, fullBytecode);
        console.log("Predicted address:", predictedAddress);

        // 部署 Target 合约
        address deployedAddress = factory.deploy(salt, fullBytecode);
        console.log("Deployed address:", deployedAddress);

        // 验证预测是否正确
        require(predictedAddress == deployedAddress, "Prediction failed");

        // 停止广播
        vm.stopBroadcast();
    }
}
