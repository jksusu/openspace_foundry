// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console } from "forge-std/Test.sol";
import { TokenBankPremit2 } from "../../src/tokenBank/TokenBankPremit2.sol";
import { Erc20TokenPremit2 } from "../../src/tokenBank/Erc20TokenPremit2.sol";
import { IAllowanceTransfer } from "permit2/src/interfaces/IAllowanceTransfer.sol";
import { ISignatureTransfer } from "permit2/src/interfaces/ISignatureTransfer.sol";
import { IPermit2 } from "permit2/src/interfaces/IPermit2.sol";

contract TestTokenBankPremit2Test is Test {
    IPermit2 public permit2;
    TokenBankPremit2 public bank;
    Erc20TokenPremit2 public token;

    address owner = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266; // 管理员
    uint256 ownerKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80; // 管理员私钥

    address user = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8; // 普通用户

    address signUser = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC; // 签名用户
    uint256 signUserPrivateKey = 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a; // 签名用户私钥

    function setUp() public {
        vm.createSelectFork("http://127.0.0.1:8545");
        vm.startPrank(owner);

        // 假设 Permit2 已经在指定地址部署
        permit2 = IPermit2(0x000000000022D473030F116dDEE9F6B43aC78BA3);
        token = Erc20TokenPremit2(0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512);
        bank = TokenBankPremit2(0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0);

        // 授权给 Permit2
        token.approve(address(permit2), 1000000000000000000000);
        assertEq(token.allowance(address(owner), address(permit2)), 1000000000000000000000);

        // 给 signUser 分配代币
        token.transfer(signUser, 100000);
        assertEq(token.balanceOf(signUser), 100000);

        console.log("tokenBank:", address(bank));
        console.log("Token:", address(token));
        console.log("Permit2:", address(permit2));

        vm.stopPrank();
    }

    function testDepositWithPermit2Test() public {
        vm.startPrank(signUser);
        uint256 amount = 100000;
        uint256 nonce = 0;
        uint256 deadline = block.timestamp + 1 hours;

        // 构造 PermitTransferFrom 数据
        ISignatureTransfer.PermitTransferFrom memory permitTransferFrom =
            ISignatureTransfer.PermitTransferFrom({ permitted: ISignatureTransfer.TokenPermissions({ token: address(token), amount: amount }), nonce: nonce, deadline: deadline });

        // 计算 EIP-712 哈希
        bytes32 typeHash = keccak256(
            "PermitTransferFrom(TokenPermissions permitted,address spender,uint256 nonce,uint256 deadline)TokenPermissions(address token,uint256 amount)"
        );

        // 计算 TokenPermissions 哈希
        bytes32 tokenPermissionsHash = keccak256(abi.encode(
            keccak256("TokenPermissions(address token,uint256 amount)"),
            permitTransferFrom.permitted.token,
            permitTransferFrom.permitted.amount
        ));

        // 计算 PermitTransferFrom 哈希
        bytes32 permitTransferFromHash = keccak256(
            abi.encode(
                typeHash,
                tokenPermissionsHash,
                address(bank), // 这里应该使用bank地址作为spender
                permitTransferFrom.nonce,
                permitTransferFrom.deadline
            )
        );

        // 计算最终签名消息
        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            permit2.DOMAIN_SEPARATOR(),
            permitTransferFromHash
        ));

        // 使用 signUser 的私钥签名
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signUserPrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        // 先授权给 Permit2
        token.approve(address(permit2), type(uint256).max);

        // 调用 depositWithPermit2
        bank.depositWithPermit2(amount, nonce, deadline, signature);

        // 验证余额
        assertEq(bank.tokenBalanceOf(signUser, address(token)), amount);

        vm.stopPrank();
    }
}