// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.5 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumUsdIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5 * 10 ** 18);
    }

    function testOwnerIsTestContract() public {
        console.log("fundMe.i_owner(): ", fundMe.getOwner());
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert(); // expect a revert
        fundMe.fund{value: 0}();
    }

    function testFundUpdatesFundedDataStructure() public funded {
        console.log("USER address: ", USER);
        console.log("USER balance:", USER.balance);

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFundertoArrayOfFunders() public funded {
        address funder = fundMe.getFunders(0);

        console.log("USER address:", USER);
        console.log("funder address: ", funder);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER); // the next TX will be sent by
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        console.log("msg.sender: ", msg.sender);
        console.log("USER address: ", USER);

        vm.expectRevert(); // expect a revert in the next TX (will ignore other vm lines of code)
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        // act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        // assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(endingOwnerBalance, startingOwnerBalance + SEND_VALUE);

        // console logs
        console.log("startingOwnerBalance: ", startingOwnerBalance);
        console.log("endingOwnerBalance: ", endingOwnerBalance);
        console.log("SEND_VALUE: ", SEND_VALUE);
        console.log(
            "Amount withdrawn: ",
            endingOwnerBalance - startingOwnerBalance
        );
        console.log("Ending FundMe balance: ", endingFundMeBalance);
    }

    function testWithdrawFromMultipleFunders() public funded {
        // arrange
        uint160 numberOfFunders = 15;
        uint160 startingFunderIndex = 1; // 0 index sometimes causes errors when generating addresses via integers
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank(); // similar structure to vm.startBroadcast() and vm.stopBroadcast(), will prank everything between the 2

        // assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundMeBalance
        );

        // console logs
        console.log("startingOwnerBalance: ", startingOwnerBalance);
        console.log("endingOwnerBalance: ", endingOwnerBalance);
        console.log("startingFundMeBalance: ", startingFundMeBalance);
        console.log(
            "Amount withdrawn: ",
            endingOwnerBalance - startingOwnerBalance
        );
        console.log("EndingFundMeBalance: ", endingFundMeBalance);
    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
        // arrange
        uint160 numberOfFunders = 15;
        uint160 startingFunderIndex = 1; // 0 index sometimes causes errors when generating addresses via integers
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank(); // similar structure to vm.startBroadcast() and vm.stopBroadcast(), will prank everything between the 2

        // assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundMeBalance
        );

        // console logs
        console.log("startingOwnerBalance: ", startingOwnerBalance);
        console.log("endingOwnerBalance: ", endingOwnerBalance);
        console.log("startingFundMeBalance: ", startingFundMeBalance);
        console.log(
            "Amount withdrawn: ",
            endingOwnerBalance - startingOwnerBalance
        );
        console.log("EndingFundMeBalance: ", endingFundMeBalance);
    }
}
