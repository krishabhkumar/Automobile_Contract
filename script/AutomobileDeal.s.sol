// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {AutomobileDeal} from "../src/AutomobileDeal.sol";


contract DeployAutomobileDeal is Script {
    AutomobileDeal public automobileDeal;

    function setUp() public {
        // automobileDeal = new AutomobileDeal();
    }

    function run() public {
        vm.startBroadcast();
        automobileDeal = new AutomobileDeal(10);
        vm.stopBroadcast();
    }
}