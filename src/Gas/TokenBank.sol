pragma solidity ^0.8.28;

import { IAllowanceTransfer } from "permit2/src/interfaces/IAllowanceTransfer.sol";
import { ISignatureTransfer } from "permit2/src/interfaces/ISignatureTransfer.sol";
import { IPermit2 } from "permit2/src/interfaces/Ipermit2.sol";
import {Erc20TokenPremit2} from "../tokenBank/Erc20TokenPremit2.sol";

contract TokenBank {
    Erc20TokenPremit2 public erc20TokenPremit2;
    IPermit2 public permit2;

    mapping(address => uint256) public tokenBalanceOf; //用户地址  ---> 币种余额

    mapping(address => address) public _nextBalance; // 链表

    uint256 public total;

    address constant init = address(1);//初始地址

    event Deposit(address indexed user, uint256 amount); //存款事件
    event NextAddress(address prev, address next); 

    // constructor(Erc20TokenPremit2 _tokenAddress, address _permit2) {
    //     erc20TokenPremit2 = _tokenAddress;
    //     permit2 = IPermit2(_permit2);
    //     _nextBalance[init] = init;
    // }

     constructor() {
        _nextBalance[init] = init;
    }

    // function deposit(address prevAddress, uint256 amount, uint256 nonce, uint256 deadline, bytes calldata signature) public {
    //     require(_nextStudents[prevAddress] != address(0));
    //     require(_verifyIndex(prevAddress, amount, _nextBalance[prevAddress]));
    //     //通过签名直接转走代币
    //     // permit2.permitTransferFrom(
    //     //     ISignatureTransfer.PermitTransferFrom({ permitted: ISignatureTransfer.TokenPermissions({ token: address(erc20TokenPremit2), amount: amount }), nonce: nonce, deadline: deadline }),
    //     //     ISignatureTransfer.SignatureTransferDetails({ to: address(this), requestedAmount: amount }),
    //     //     msg.sender,
    //     //     signature
    //     // );
    //     _saveNest(msg.sender, inFrontAddress);
    //     tokenBalanceOf[msg.sender] += amount;
    //     emit Deposit(msg.sender, amount);
    // }

    function deposit(address prevAddress, uint256 amount) public {
        require(_nextBalance[prevAddress] != address(0),"prev address not exist");
        // require(_verifyIndex(prevAddress, amount, _nextBalance[prevAddress]),"index verify failed");
        _saveNext(prevAddress, msg.sender);
        tokenBalanceOf[msg.sender] += amount;
        emit Deposit(msg.sender, amount);
    }

    //更新链表中的前后地址
    function _saveNext(address _prevAddress, address _address) internal {
        //修改上一个的下一个是当前地址
        _nextBalance[_prevAddress] = _address;
        //修改当前地址的上一个是上一个地址，占位
        _nextBalance[_address] = _prevAddress;
        total++;

        emit NextAddress(_prevAddress,_address);
    }
    //验证连表中的位置是否正确
    function _verifyIndex(address prev, uint256 newValue, address next) internal view returns (bool) {
        //上一个是初始地址 或者 上一个地址 的余额要大于 新地址余额； 且 下一个要等于初始地址 或者 当前余额要大于下一个地址的余额
        return (prev == init || tokenBalanceOf[prev] >= newValue) && (next == init || newValue > tokenBalanceOf[next]);
    }

    function getDepositByToken(address userAddress) external view returns (uint256) {
        return tokenBalanceOf[userAddress];
    }

    function getTop(uint256 number) public view returns (address[] memory) { 
        require(number <= total, "number is too large");
        address[] memory result = new address[](number);
        address current = _nextBalance[init];
        for (uint256 i = 0; i < number; i++) {
            result[i] = current;
            current = _nextBalance[current];
        }
        return result;
    }

    function getNextByAddress(address userAddress) external view returns (address) {
        return _nextBalance[userAddress];
    }
}
