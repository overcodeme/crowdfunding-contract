// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    uint public MINIMUM_USD = 10;

    function fund() public payable {
        require(getConversationRate(msg.value) > MINIMUM_USD, "Not enough USD to send");
    }

    // function withdraw() public {}

    function getLatestPrice() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (,int256 answer,,,) = priceFeed.latestRoundData();
        return uint256(answer * 1e10);
    }

    function getConversationRate(uint256 ethAmount) internal view returns (uint256) {
        uint256 ethPrice = getLatestPrice();
        uint256 EthAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return EthAmountInUsd;
    }
}