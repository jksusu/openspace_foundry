pragma solidity ^0.8.28;

import "./Erc20TokenPremit2.sol";
import { IAllowanceTransfer } from "permit2/src/interfaces/IAllowanceTransfer.sol";
import { ISignatureTransfer } from "permit2/src/interfaces/ISignatureTransfer.sol";
import { IPermit2 } from "permit2/src/interfaces/Ipermit2.sol";

contract TokenBankPremit2 {
    Erc20TokenPremit2 public erc20TokenPremit2;
    IPermit2 public permit2;

    mapping(address => mapping(address => uint256)) public tokenBalanceOf; //用户地址 -- 币种地址 ---> 币种余额

    event Deposit(address tokenAddress, address indexed user, uint256 amount); //存款事件

    constructor(Erc20TokenPremit2 _tokenAddress, address _permit2) {
        erc20TokenPremit2 = _tokenAddress;
        permit2 = IPermit2(_permit2);
    }

    function depositWithPermit2(uint256 amount, uint256 nonce, uint256 deadline, bytes calldata signature) public {
        //通过签名直接转走代币
        permit2.permitTransferFrom(
            ISignatureTransfer.PermitTransferFrom({ permitted: ISignatureTransfer.TokenPermissions({ token: address(erc20TokenPremit2), amount: amount }), nonce: nonce, deadline: deadline }),
            ISignatureTransfer.SignatureTransferDetails({ to: address(this), requestedAmount: amount }),
            msg.sender,
            signature
        );
        tokenBalanceOf[msg.sender][address(erc20TokenPremit2)] += amount;
        emit Deposit(address(erc20TokenPremit2), msg.sender, amount);
    }

    function getDepositByToken(address userAddress) external view returns (uint256) {
        return tokenBalanceOf[userAddress][address(erc20TokenPremit2)];
    }
}
