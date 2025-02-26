pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

/**
 * @title AksErc2612Token erc20 代币合约
 * @title 合约测试地址 sepolia 0x93d6f0735b19582aa26884853e841a73749538da
 * @title https://sepolia.etherscan.io/address/0x93d6f0735b19582aa26884853e841a73749538da
 * @dev Implementation of the AksErc2612Token
 * @dev https://eips.ethereum.org/EIPS/eip-2612
 * @dev https://docs.openzeppelin.com/contracts/4.x/erc20-permit
 * @dev This contract mints 1000000 tokens to the contract creator.
 * @dev This contract uses the {ERC20} and {ERC20Permit} from OpenZeppelin
 */
contract AksErc2612Token is ERC20, ERC20Permit {
    constructor() ERC20("AksErc2612Token", "2612Token") ERC20Permit("2612Token") {
        _mint(msg.sender, 1000000 * (10 ** 18));
    }
}
