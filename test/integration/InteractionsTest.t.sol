// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.5 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        
        // Testing FundFundMe component
        console.log("fund me contract address: ", address(fundMe));

        FundFundMe fundFundMeContract = new FundFundMe();

        console.log("FundMe balance before funding contract: ", address(fundMe).balance);

        fundFundMeContract.fundFundMe(address(fundMe), SEND_VALUE);

        console.log("Amount sent: ", SEND_VALUE);
        console.log("FundMe balance after funding contract: ", address(fundMe).balance);

        // Testing WithdrawFundMe component
        WithdrawFundMe withdrawFundMeContract = new WithdrawFundMe();
        withdrawFundMeContract.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);

        console.log("FundMe balance after withdrawing contract: ", address(fundMe).balance);
    }

}