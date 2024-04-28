// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {Fundme} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {Script} from "forge-std/Script.sol";

contract FundMeTest is Test, Script {
    Fundme fundme;
    address akash = makeAddr("akash");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 1 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundme = deployFundMe.run();
        vm.deal(akash, STARTING_BALANCE);
    }

    function testMinimumUSD() public view {
        assertEq(fundme.MINIMUM_USD(), 5e18);
    }

    function testFundMeOwner() public view {
        //assertEq(fundme.owner(),msg.msg.sender); //us(msg.sender)->fundMeTest(fundme.owner())->Fundme
        assertEq(fundme.getOwner(), msg.sender);
    }

    function testPriceFeedIsAccurate() public view {
        uint256 version = fundme.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();
        fundme.fund();
    }

    function testFundSuccessSendEnoughEth() public {
        vm.prank(akash);
        vm.deal(akash, 1 ether);
        fundme.fund{value: SEND_VALUE}();
        uint256 amt = fundme.getAddressToAmountFunded(akash);
        assertEq(amt, SEND_VALUE);
    }

    function testGetAddress() public {
        vm.prank(akash);
        vm.deal(akash, 1 ether);
        fundme.fund{value: SEND_VALUE}();
        address funderAddr = fundme.getAddress(0);
        assertEq(funderAddr, akash);
    }

    modifier funded() {
        vm.prank(akash);
        fundme.fund{value: SEND_VALUE}();
        _;
    }

    function testWithSingelFunderFail() public funded {
        vm.expectRevert();
        fundme.withdraw();
    }

    function testOnlyOwnerCanWithdraw() public funded {
        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundmeBalance = address(fundme).balance;
        // console.log("startingOwnerBalance ==%d", startingOwnerBalance);
        // console.log("startingFundmeBalance %d", startingFundmeBalance);

        vm.startPrank(fundme.getOwner());
        fundme.withdraw();
        vm.stopPrank();

        uint256 endingOwnerBalance = fundme.getOwner().balance;
        uint256 endingFundmeBalance = address(fundme).balance;
        // console.log("endingFundmeBalance %d", endingFundmeBalance);
        // console.log("endingOwnerBalance %d", endingOwnerBalance);

        assertEq(endingFundmeBalance, 0);
        assertEq(startingFundmeBalance + startingOwnerBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFunders() public funded {
        uint160 numOfFunders = 10;
        uint160 startingFunderIndexs = 1;

        for (uint160 i = startingFunderIndexs; i <= numOfFunders; i++) {
            // vm.prank(address(i));
            hoax(address(i), SEND_VALUE);
            // vm.deal(address(i),SEND_VALUE);
            fundme.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundmeBalance = address(fundme).balance;
        // console.log("startingOwnerBalance %d", startingOwnerBalance);
        // console.log("startingFundmeBalance %d", startingFundmeBalance);
        uint256 startinggas = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundme.getOwner());
        fundme.withdraw();
        uint256 endinggas = gasleft();
        console.log((startinggas - endinggas) * tx.gasprice);
        uint256 endingOwnerBalance = fundme.getOwner().balance;
        uint256 endingFundmeBalance = address(fundme).balance;
        // console.log("endingFundmeBalance %d", endingFundmeBalance);
        // console.log("endingOwnerBalance %d", endingOwnerBalance);
        assertEq(endingFundmeBalance, 0);
        assertEq(startingFundmeBalance + startingOwnerBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleCheaperFunders() public funded {
        uint160 numOfFunders = 10;
        uint160 startingFunderIndexs = 1;

        for (uint160 i = startingFunderIndexs; i <= numOfFunders; i++) {
            // vm.prank(address(i));
            hoax(address(i), SEND_VALUE);
            // vm.deal(address(i),SEND_VALUE);
            fundme.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundmeBalance = address(fundme).balance;
        // console.log("startingOwnerBalance %d", startingOwnerBalance);
        // console.log("startingFundmeBalance %d", startingFundmeBalance);
        uint256 startinggas = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundme.getOwner());
        fundme.cheaperWithdraw();
        uint256 endinggas = gasleft();
        console.log((startinggas - endinggas) * tx.gasprice);
        uint256 endingOwnerBalance = fundme.getOwner().balance;
        uint256 endingFundmeBalance = address(fundme).balance;
        // console.log("endingFundmeBalance %d", endingFundmeBalance);
        // console.log("endingOwnerBalance %d", endingOwnerBalance);
        assertEq(endingFundmeBalance, 0);
        assertEq(startingFundmeBalance + startingOwnerBalance, endingOwnerBalance);
    }
}
