// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {AutomobileDeal} from "../src/AutomobileDeal.sol";

contract TestAutomobileDeal is Test {

    AutomobileDeal public automobileDeal;

    function setUp() public {
        automobileDeal = new AutomobileDeal(10);
    }

    function testOwner() view public {
        assertEq(automobileDeal.owner(), address(this));
    }
}