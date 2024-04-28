// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {Fundme} from "../src/FundMe.sol";

contract DeployFundMe is Script {
    function run() external returns (Fundme) {
        HelperConfig helperConfig = new HelperConfig();
        address priceFeed = helperConfig.activeNetworkConfig();
        vm.startBroadcast();
        Fundme fundme = new Fundme(priceFeed);
        vm.stopBroadcast();
        return fundme;
    }
}
