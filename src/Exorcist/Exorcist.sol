// SPDX-License-Identifier: MIT
pragma solidity 0.8.x;

import {ERC20} from "solady/tokens/ERC20.sol";

// Exorcises a soulbound token from it's bounded address, enables transferability
contract Exorcist is ERC20 {
    uint256 private constant _BALANCE_SLOT_SEED = 0x87a211a2;
    uint256 private constant _BALANCE_OF_FUNCTION_SELECTOR = 0x70a08231;
    uint256 private constant _LegionBalanceOfCallReverted_ERROR_SIGNATURE = 0xe037a455;

    ERC20 immutable LEGION_CONTRACT;
    uint8 immutable LEGION_DECIMALS;

    string LEGION_NAME;
    string LEGION_SYMBOL;
    mapping(address => uint256) lastSoulboundBalance;

    error LegionBalanceOfCallReverted();

    constructor(address _legionAddress) {
        ERC20 _legion = ERC20(_legionAddress);

        LEGION_CONTRACT = _legion;
        LEGION_DECIMALS = _legion.decimals();

        LEGION_NAME = string.concat("Exorcised-", _legion.name());
        LEGION_SYMBOL = string.concat("E-", _legion.symbol());
    }

    /// @dev Returns the name of the token.
    function name() public view override returns (string memory) {
        return LEGION_NAME;
    }

    /// @dev Returns the symbol of the token.
    function symbol() public view override returns (string memory) {
        return LEGION_SYMBOL;
    }

    /// @dev Returns the decimals places of the token.
    function decimals() public view override returns (uint8) {
        return LEGION_DECIMALS;
    }

    /// @dev Returns the amount of tokens in existence.
    function totalSupply() public view override returns (uint256) {
        return LEGION_CONTRACT.totalSupply();
    }

    /// @dev Returns the amount of tokens owned by `owner`.
    function balanceOf(address _addr) public view override returns (uint256 result) {
        (uint256 _exorcised,) = _getExorcisable(_addr);
        unchecked {
            result = super.balanceOf(_addr) + _exorcised;
        }
    }

    /// @dev Hook that is called before any transfer of tokens.
    /// This includes minting and burning.
    function _beforeTokenTransfer(address _from, address _to, uint256) internal virtual override {
        _exorcise(_from);
        _exorcise(_to);
    }

    /// @dev tops up the user's current balance by the new soulbound tokens they acquired since last updated (if any)
    function _exorcise(address _addr) internal virtual {
        (uint256 _exorcised, bytes32 _addrLastSoulboundBalanceSlot) = _getExorcisable(_addr);

        /// @solidity memory-safe-assembly
        assembly {
            if _exorcised {
                // update last known soulbound balance
                let _addrLastSoulboundBalance := sload(_addrLastSoulboundBalanceSlot)
                sstore(_addrLastSoulboundBalanceSlot, add(_addrLastSoulboundBalance, _exorcised)) // unchecked add is safe because the result is a valid value from the legion contract

                // update balance
                let addr_ := shl(96, _addr)
                mstore(0x0c, or(addr_, _BALANCE_SLOT_SEED))
                let addrBalanceSlot := keccak256(0x0c, 0x20)
                sstore(addrBalanceSlot, _exorcised)
            }
        }
    }

    function _getExorcisable(address _addr)
        private
        view
        returns (uint256 _exorcised, bytes32 _addrLastSoulboundBalanceSlot)
    {
        ERC20 _legionContract = LEGION_CONTRACT;

        /// @solidity memory-safe-assembly
        assembly {
            // get _addr's balanceOf
            mstore(0x00, _BALANCE_OF_FUNCTION_SELECTOR)
            mstore(0x20, _addr)
            if iszero(staticcall(gas(), _legionContract, 0x1c, 0x24, 0x00, 0x20)) {
                mstore(0x00, _LegionBalanceOfCallReverted_ERROR_SIGNATURE)
                revert(0x1c, 0x04)
            }
            let _soulboundBalance := mload(0x00)

            // get _addr's lastSoulboundBalance
            mstore(0x00, _addr)
            mstore(0x20, lastSoulboundBalance.slot)
            _addrLastSoulboundBalanceSlot := keccak256(0x00, 0x40)
            let _addrLastSoulboundBalance := sload(_addrLastSoulboundBalanceSlot)

            if gt(_soulboundBalance, _addrLastSoulboundBalance) {
                // assume it increased since last checked, soulbound tokens shouldn't decrease in balance
                // unchecked sub, will wrap around to type(uint256).max if soulbound balance reduces (should not be possible)
                _exorcised := sub(_soulboundBalance, _addrLastSoulboundBalance)
            }
        }
    }
}
