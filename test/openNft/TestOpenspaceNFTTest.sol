// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test, console } from "forge-std/Test.sol";
import {OpenspaceNFT} from "../../src/openNft/OpenspaceNFT.sol";
contract TestOpenspaceNFTTest is Test{
    OpenspaceNFT nft;

    address owner = makeAddr("owner");
    address user = makeAddr("user");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");

    function setUp() public {
        vm.startPrank(owner);
        nft = new OpenspaceNFT();
        bool isAc = OpenspaceNFT(nft).isPresaleActive();
        console.log("isAc", isAc);
        //开启
        OpenspaceNFT(nft).enablePresale();
        isAc = OpenspaceNFT(nft).isPresaleActive();
        console.log("isAc", isAc);
        vm.stopPrank();
    }

    function test_presale() public {
        uint256 userAmount = 0.01 ether;
        vm.deal(user, userAmount);
        vm.startPrank(user);
        OpenspaceNFT(nft).presale{value: userAmount}(1);

        assertEq(nft.balanceOf(user), 1);
        assertEq(nft.ownerOf(1), user);
        assertEq(user.balance, 0);
        vm.stopPrank();
    }
}