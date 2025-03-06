// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Signature712 {
    bytes32 public domainSeparator;
    bytes32 public constant EIP712_DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    constructor() { }

    /**
     * typeHash 要签名的消息hash
     */
    function _sign712(bytes32 typeHash) internal view returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, typeHash));
    }
}
