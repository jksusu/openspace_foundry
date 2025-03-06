// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Factory {
    event Deployed(address addr);

    function deploy(bytes32 salt, bytes memory bytecode) public returns (address) {
        address addr;
        assembly {
            addr := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
            if iszero(extcodesize(addr)) { revert(0, 0) }
        }
        emit Deployed(addr);
        return addr;
    }

    // 预测地址
    function predictAddress(bytes32 salt, bytes memory bytecode) public view returns (address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, keccak256(bytecode))))));
    }
}