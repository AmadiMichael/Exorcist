// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "lib/solady/src/tokens/ERC20.sol";

contract MockERC20 is ERC20 {
    string NAME;
    string SYMBOL;

    error SOULBOUND();

    constructor(string memory _name, string memory _symbol) {
        NAME = _name;
        SYMBOL = _symbol;
    }

    /// @dev Returns the name of the token.
    function name() public view override returns (string memory) {
        return NAME;
    }

    /// @dev Returns the symbol of the token.
    function symbol() public view override returns (string memory) {
        return SYMBOL;
    }

    function transfer(address, uint256) public pure override returns (bool) {
        revert SOULBOUND();
    }

    function transferFrom(address, address, uint256) public pure override returns (bool) {
        revert SOULBOUND();
    }

    function mint(address to, uint256 amount) public virtual {
        _mint(to, amount);
    }
}
