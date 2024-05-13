// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2 as console} from "forge-std/Test.sol";
import {Exorcist} from "../src/Exorcist.sol";
import {ExorcistFactory} from "./../src/ExorcistFactory.sol";
import {MockERC20} from "./mocks/MockERC20.sol";

contract ExorcistTest is Test {
    ExorcistFactory exorcistFactory;
    Exorcist exorcist;
    MockERC20 soulboundERC20;

    address actor0 = address(uint160(uint256(keccak256("actor0"))));
    address actor1 = address(uint160(uint256(keccak256("actor1"))));

    function setUp() public {
        exorcistFactory = new ExorcistFactory();
        soulboundERC20 = new MockERC20("Soulbound", "SBD");

        exorcist = Exorcist(exorcistFactory.deployExorcist(address(soulboundERC20)));

        // mint to actor0
        soulboundERC20.mint(actor0, 1000e18);
    }

    function test_basic_exorcise() external {
        vm.startPrank(actor0);

        console.log("initial actor0 balance: %e", exorcist.balanceOf(actor0));

        exorcist.transfer(actor1, 500e18);

        console.log("after actor0 balance: %e", exorcist.balanceOf(actor0));
    }
}
