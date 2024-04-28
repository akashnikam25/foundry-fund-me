// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {Fundme} from "../src/FundMe.sol";

contract FundFundme is Script {
    uint256 constant SEND_VALUE = 1 ether;

    function fundFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        console.log("hey akash");
        // fundme.fund{value: SEND_VALUE}();
        Fundme(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("Fundme", block.chainid);
        // Fundme fundme = new Fundme(payable(mostRecentlyDeployed));
        fundFundMe(mostRecentlyDeployed);
    }
}

contract WithdrawFundme is Script {
    uint256 constant SEND_VALUE = 1 ether;

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("Fundme", block.chainid);
        withdrawFundMe(mostRecentlyDeployed);
        //  Fundme fundme = new Fundme(payable(mostRecentlyDeployed));
    }

    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        console.log("hey akash");
        Fundme(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
    }
}
