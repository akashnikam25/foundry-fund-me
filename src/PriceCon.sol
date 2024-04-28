// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceCon {
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        (
            ,
            /* uint80 roundID */
            int256 answer, /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/
            ,
            ,
        ) = AggregatorV3Interface(priceFeed).latestRoundData();
        return uint256(answer * 1e10);
    }

    function getPriceConversion(uint256 ethVal, AggregatorV3Interface priceFeed) internal view returns (uint256) {
        uint256 val = (getPrice(priceFeed) * ethVal) / 1e18;
        return val;
    }
}
