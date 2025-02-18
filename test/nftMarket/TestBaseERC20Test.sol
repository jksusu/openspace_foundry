// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console } from "forge-std/Test.sol";
import { BaseERC20 } from "../../src/nftMarket/baseERC20.sol";

contract TestBankTest is Test {
    BaseERC20 public baseERC20;

    function setUp() public {
        baseERC20 = new BaseERC20();
    }

    function test_isContract() public { }
}
