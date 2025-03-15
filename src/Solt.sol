// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;
contract Solt {
    string public name;
    mapping (address => bool) privateapproved;
    address public owner;

    modifier auth {
        require (msg.sender == owner, "Not authorized");
        _;
    }

    constructor(string memory _name) {
        name = _name;
        owner = msg.sender;
    }

    function transferOwernship(address _addr) public auth {
        require(_addr != address(0), "New owner is the zero address");
        require(owner != _addr, "New owner is the same as the old owner");
        owner = _addr;
    }

    // 通过汇编修改 owner 的函数
    function setOwnerViaAssembly(address _newOwner) public {
        assembly {
            // 将 _newOwner 存储到存储槽 2
            sstore(2, _newOwner)
        }
    }
}