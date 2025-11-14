// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

contract FundMe {
    using PriceConverter for uint256;

    uint public MINIMUM_USD = 10;

    address[] public funders;
    address public owner;

    mapping (address funder => uint256 amountFunded) public addressToAmountFunded; 
    mapping (address funder => uint256 fundsCount) public addressToFundsCount;

    constructor() {
        owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value.getConversationRate() >= MINIMUM_USD, "Not enough USD to send");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value.getConversationRate();
        addressToFundsCount[msg.sender] += 1;
    }

    function withdraw() public onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        
        payable(msg.sender).transfer(address(this).balance);
    }

    function getLatestBTCPriceInETH() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x5fb1616F78dA7aFC9FF79e0371741a747D2a7F22);
        (,int256 answer,,,) = priceFeed.latestRoundData();
        return uint256(answer);
    }

    function convertUsdToEth(uint256 usdAmount, uint256 ethPrice) public pure returns (uint256) {
        return usdAmount / ethPrice * 1e18;
    }

    function contributionCount(address funder) public view returns (uint256) {
        return addressToFundsCount[funder];
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Sender is not owner");
        _;
    }
}