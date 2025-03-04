// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import { Test, console } from "forge-std/Test.sol";

// EIP712
// 1. domain 域分隔符 链id 有效时间戳 随机数 应用名 版本； 主要用来防止签名重放
// 2. message 消息
// 3. hash计算
// 4. 签名与验证
contract EIP712Utils is EIP712 {
    using ECDSA for bytes32;

    // 定义 Transfer 类型哈希，包括 nonce
    bytes32 private constant TRANSFER_TYPEHASH = keccak256("Transfer(address from,address to,uint256 amount,uint256 nonce)");

    // 事件：记录签名验证
    event Verified(address indexed from, address indexed to, uint256 amount, uint256 nonce);

    // 构造函数，调用 EIP712 构造函数初始化域分隔符
    constructor(string memory name, string memory version) EIP712(name, version) { }

    // 对消息进行哈希（ERC20 转账消息）
    function hashTransfer(address from, address to, uint256 amount, uint256 nonce) internal pure returns (bytes32) {
        return keccak256(abi.encode(TRANSFER_TYPEHASH, from, to, amount, nonce));
    }

    // 对 EIP-712 签名进行哈希 得到签名
    function getTypedDataHash(address from, address to, uint256 amount, uint256 nonce) public view returns (bytes32) {
        bytes32 structHash = hashTransfer(from, to, amount, nonce);
        return _hashTypedDataV4(structHash);
    }

    //验证签名方法
    function verifySignature(address from, address to, uint256 amount, uint256 nonce, bytes memory signature) external returns (bool) {
        // 计算签名的哈希
        bytes32 digest = getTypedDataHash(from, to, amount, nonce);
        // 验证签名
        address signer = digest.recover(signature);
        require(signer == from, "Invalid signature");

        emit Verified(from, to, amount, nonce);
        return true;
    }
}

// forge test --mc TestEIP712Test -vvv、
// 如果你需要使用EIP712，你需要准备三个数据，DomainSeparator，TypedDataHash，你的密钥v,r,s
// DomainSeparator用于唯一地标识你的合约
// TypedDataHash用于唯一地调用你要使用的函数
// 密钥v，r，s用于验证你的身份
contract TestEIP712Test is Test {
    constructor() { }

    function testSignTest() public {
        //调用签名合约
        EIP712Utils eip712Utils = new EIP712Utils("Test", "1");
        //admin给用户转账签名
        (address adminAddress, uint256 adminPrivateKey) = makeAddrAndKey("admin");
        address userAddress = makeAddr("user");
        uint256 amount = 1000;
        uint256 nonce = 1;
        //计算消息哈希 默认签名 erc20 转账消息
        bytes32 digest = eip712Utils.getTypedDataHash(adminAddress, userAddress, amount, nonce);

        // 使用 admin 的私钥签名, 这里才是最终需要用户签名的步骤 ***
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(adminPrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        //断言事件
        vm.expectEmit(true, true, true, true);
        emit EIP712Utils.Verified(adminAddress, userAddress, amount, nonce);
        bool verify = eip712Utils.verifySignature(adminAddress, userAddress, amount, nonce, signature);
        assertEq(verify, true);
    }
}
