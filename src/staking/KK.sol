pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * 总供应量  100000000 一亿个
 */
contract KK is ERC20 {
    constructor() ERC20("KK", "KK") {
        _mint(msg.sender, 100000000 * 10 ** 18);
    }
}
