// SPDX-License-Identifier: MIT
pragma solidity 0.8.x;

import {ExorcistStaticBalance} from "./ExorcistStaticBalance.sol";

contract ExorcisStaticBalanceFactory {
    error DeterministicDeploymentFailed();
    error AlreadyExorcised();

    function deployExorcist(address _legionAddress) external returns (address _exorcist) {
        bool isExorcised;
        assembly ("memory-safe") {
            isExorcised := sload(_legionAddress)
        }
        if (isExorcised) revert AlreadyExorcised();

        _exorcist = address(
            uint160(
                uint256(
                    bytes32(
                        keccak256(
                            abi.encodePacked(
                                hex"ff",
                                address(this),
                                uint256(uint160(_legionAddress)),
                                keccak256(
                                    bytes.concat(type(ExorcistStaticBalance).creationCode, abi.encode(_legionAddress))
                                )
                            )
                        )
                    )
                )
            )
        );

        assembly ("memory-safe") {
            sstore(_legionAddress, _exorcist)
        }

        if (
            _exorcist
                != address(new ExorcistStaticBalance{salt: bytes32(uint256(uint160(_legionAddress)))}(_legionAddress))
        ) {
            revert DeterministicDeploymentFailed();
        }
    }

    function getExorcistOf(address _legionAddress) external view returns (address _exorcist) {
        assembly ("memory-safe") {
            _exorcist := sload(_legionAddress)
        }
    }
}
