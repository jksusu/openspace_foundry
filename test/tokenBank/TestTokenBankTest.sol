// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console } from "forge-std/Test.sol";
import { TokenBank } from "../../src/tokenBank/TokenBank.sol";
import { AksErc2612Token } from "../../src/eip2612Token/Eip2612Token.sol";
import { ERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract TestTokenBankTest is Test {
    TokenBank public tokenBank;
    AksErc2612Token public aksErc2612Token;

    address owner = makeAddr("owner"); //管理员
    address user = makeAddr("user"); //普通用户
    address signUser; //签名用户
    uint256 signUserPrivateKey; // 存储签名用户的私钥

    function setUp() public {
        // 使用确定性的方式生成私钥和地址
        signUserPrivateKey = uint256(keccak256(abi.encodePacked("signUser")));
        signUser = vm.addr(signUserPrivateKey);
        //验证私钥对应的地址确实是 signUser
        assertEq(vm.addr(signUserPrivateKey), signUser);

        vm.startPrank(owner);
        tokenBank = new TokenBank();
        aksErc2612Token = new AksErc2612Token();

        aksErc2612Token.transfer(signUser, 100000); //管理员转账给签名用户10w代币
        assertEq(aksErc2612Token.balanceOf(signUser), 100000);
        vm.stopPrank();
    }

    function testChangeContractStatusTest() public {
        //测试普通权限
        vm.startPrank(user);
        vm.expectRevert(TokenBank.NoPermission.selector);
        tokenBank.changeContractStatus(true);
        vm.stopPrank();

        //测试管理员权限
        vm.startPrank(owner);
        tokenBank.changeContractStatus(true);
        assertEq(tokenBank.status(), true);
        //测试 false
        tokenBank.changeContractStatus(false);
        assertEq(tokenBank.status(), false);
        vm.stopPrank();

        //调用任意方法报错
        vm.startPrank(user);
        vm.expectRevert(TokenBank.ContractPause.selector);
        tokenBank.listToken(user);
        vm.stopPrank();
    }

    function testChangeTokenStatusTest() public {
        //测试普通权限
        vm.startPrank(user);
        vm.expectRevert(TokenBank.NoPermission.selector);
        tokenBank.changeTokenStatus(address(aksErc2612Token), 1, true);
        vm.stopPrank();

        //测试管理员权限
        vm.startPrank(owner);
        tokenBank.changeTokenStatus(address(aksErc2612Token), 1, true);
        assertEq(tokenBank.tokenContractStatus(address(aksErc2612Token), 1), true);
        //测试 false
        tokenBank.changeTokenStatus(address(aksErc2612Token), 2, false);
        assertEq(tokenBank.tokenContractStatus(address(aksErc2612Token), 2), false);
        vm.stopPrank();
    }

    //测试 list
    function testListTokenTest() public {
        //测试普通权限
        vm.startPrank(user);
        vm.expectRevert(TokenBank.NoPermission.selector);
        tokenBank.listToken(address(aksErc2612Token));
        vm.stopPrank();

        //测试管理员权限
        vm.startPrank(owner);
        tokenBank.listToken(address(aksErc2612Token));
        assertEq(tokenBank.tokenContractStatus(address(aksErc2612Token), 1), true);
        assertEq(tokenBank.tokenContractStatus(address(aksErc2612Token), 2), true);
        vm.stopPrank();
    }

    function testDepositByTokenTest() public {
        vm.startPrank(owner);
        tokenBank.changeTokenStatus(address(aksErc2612Token), 1, true);
        tokenBank.changeTokenStatus(address(aksErc2612Token), 2, true);

        //测试用户存款
        vm.startPrank(user);
        assertEq(tokenBank.tokenContractStatus(address(aksErc2612Token), 1), true);
        assertEq(tokenBank.tokenContractStatus(address(aksErc2612Token), 2), true);

        //断言事件是否执行成功
        vm.expectEmit(true, true, true, true);
        emit TokenBank.Deposit(address(aksErc2612Token), user, 100);
        tokenBank.depositeByToken(address(aksErc2612Token), 100);

        //检查存款是否成功
        assertEq(tokenBank.getDepositByToken(user, address(aksErc2612Token)), 100);
        vm.stopPrank();
    }

    function testPermitDepositTest() public {
        // 设置时间戳
        vm.warp(1740586075);
        uint256 deadline = block.timestamp + 100000; // 截止时间 2000
        uint256 nonce = aksErc2612Token.nonces(signUser);
        uint256 amount = 1000; // 100 个代币

        console.log("SignUser address:", signUser);
        console.log("SignUser privateKey:", signUserPrivateKey);
        console.log("block.timestamp:", block.timestamp);
        console.log("deadline:", deadline);
        console.log("nonce:", nonce);

        // 生成签名
        bytes32 domainSeparator = aksErc2612Token.DOMAIN_SEPARATOR();
        bytes32 permitTypehash = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
        bytes32 structHash = keccak256(abi.encode(permitTypehash, signUser, address(tokenBank), amount, nonce, deadline));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signUserPrivateKey, digest);

        console.log("Signature components:");
        console.log("v:", v);
        console.logBytes32(r);
        console.logBytes32(s);

        // zhangsan 执行 permit 和 transferFrom
        address zhangsan = makeAddr("zhangsan");
        vm.startPrank(zhangsan);

        // 执行 permit 和 transferFrom
        aksErc2612Token.permit(signUser, address(tokenBank), amount, deadline, v, r, s);
        vm.startPrank(address(tokenBank));
        aksErc2612Token.transferFrom(signUser, address(tokenBank), amount);

        // 验证余额
        assertEq(aksErc2612Token.balanceOf(address(tokenBank)), amount, "TokenBank balance incorrect");

        vm.stopPrank();
    }
}
