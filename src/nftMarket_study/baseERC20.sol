// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface ITokenReceiver {
    function tokensReceived(address from, uint256 amount, uint256 tokenId) external returns (bool);
}

contract BaseERC20 is ERC20 {
    constructor() ERC20("BaseERC20", "BaseERC20") {
        _mint(msg.sender, 100000000 * 10 ** 18);
    }

    function transferWithCallback(address _to, uint256 amount, uint256 tokenId) public returns (bool) {
        _transfer(msg.sender, _to, amount);
        if (isContract(_to)) {
            (bool success) = ITokenReceiver(_to).tokensReceived(msg.sender, amount, tokenId);
            require(success, "Callback failed");
        }
        return true;
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}
