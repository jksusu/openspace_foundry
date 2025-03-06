// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Target {
    uint256 public value;

    constructor(uint256 _value) {
        value = _value;
    }
}