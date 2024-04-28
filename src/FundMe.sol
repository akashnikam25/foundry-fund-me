// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceCon} from "./PriceCon.sol";
import {console} from "forge-std/Test.sol";

error NotOwner();

contract Fundme {
    uint256 public constant MINIMUM_USD = 5e18;

    using PriceCon for uint256;

    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmtFunded;
    address public immutable i_owner;

    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        s_priceFeed = AggregatorV3Interface(priceFeed);
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value.getPriceConversion(s_priceFeed) >= MINIMUM_USD, "Didn't send enough ether");
        s_funders.push(msg.sender);

        s_addressToAmtFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for (uint256 i = 0; i < s_funders.length; i++) {
            address funder = s_funders[i];
            s_addressToAmtFunded[funder] = 0;
        }

        s_funders = new address[](0);

        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "call Failed");
    }

    function cheaperWithdraw() public onlyOwner {
        uint256 funderslength = s_funders.length;
        for (uint256 i = 0; i < funderslength; i++) {
            address funder = s_funders[i];
            s_addressToAmtFunded[funder] = 0;
        }

        s_funders = new address[](0);

        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "call Failed");
    }

    modifier onlyOwner() {
        // require(i_owner == msg.sender, "must be i_owner") ;

        if (i_owner != msg.sender) {
            revert NotOwner();
        }
        _;
    }

    function getVersion() public view returns (uint256) {
        return AggregatorV3Interface(s_priceFeed).version();
    }

    function getAddressToAmountFunded(address sender) external view returns (uint256) {
        return s_addressToAmtFunded[sender];
    }

    function getAddress(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }

    function getMsgSender() external view returns (address) {
        return msg.sender;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
