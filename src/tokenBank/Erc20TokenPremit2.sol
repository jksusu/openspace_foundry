// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Erc20TokenPremit2 is ERC20 {
    constructor() ERC20("PreMit2", "PreMit2") {
        _mint(msg.sender, 1e10 * 1e18);
    }
}
