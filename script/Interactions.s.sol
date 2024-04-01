// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {DeployFundMe} from "./DeployFundMe.s.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 2 ether;

    function fundFundMe(address _deployedContract, uint256 _send_value) public {
        vm.startBroadcast();
        FundMe(payable(_deployedContract)).fund{value: _send_value}(); 
        vm.stopBroadcast();
    }

    function run () external  returns (FundMe) {
        DeployFundMe deployFundMe = new DeployFundMe();
        FundMe deployedFundMeContract = deployFundMe.run();

        console.log("FundMe balance before funding contract: ", address(deployedFundMeContract).balance);

        fundFundMe(address(deployedFundMeContract), SEND_VALUE);
        

        console.log("Amount sent: ", SEND_VALUE);
        console.log("FundMe balance after funding contract: ", address(deployedFundMeContract).balance);

        return deployedFundMeContract;
    }
}

contract WithdrawFundMe is Script {
    uint256 constant SEND_VALUE = 2 ether;

    function withdrawFundMe(address _deployedContract) public {
        vm.startBroadcast();
        FundMe(payable(_deployedContract)).withdraw(); 
        vm.stopBroadcast();
    }

    function run () external  returns (FundMe) {
        DeployFundMe deployFundMe = new DeployFundMe();
        FundMe deployedFundMeContract = deployFundMe.run();

        console.log("FundMe balance before withdrawing contract: ", address(deployedFundMeContract).balance);
        
        withdrawFundMe(address(deployedFundMeContract));
    
        console.log("FundMe balance after withdrawing contract: ", address(deployedFundMeContract).balance);

        return deployedFundMeContract;
    }
}

// contract FundFundMe is Script {
//     uint256 constant SEND_VALUE = 2 ether;

//     function run() external {
//         HelperConfig helperConfig = new HelperConfig();
//         address ethUsdPriceFeed = helperConfig.activeNetworkConfig();

//         vm.startBroadcast();
//         FundMe fundMe = new FundMe(ethUsdPriceFeed);
//         fundMe.fund{value: SEND_VALUE}();
//         vm.stopBroadcast();
        
//         console.log("Amount sent: ", SEND_VALUE);
//         console.log("FundMe balance after funding contract: ", address(fundMe).balance);
//     }
// }

// contract WithdrawFundMe is Script {
//     uint256 constant SEND_VALUE = 3.5 ether;

//     function run() external {
//         HelperConfig helperConfig = new HelperConfig();
//         address ethUsdPriceFeed = helperConfig.activeNetworkConfig();
        
//         vm.startBroadcast();
//         FundMe fundMe = new FundMe(ethUsdPriceFeed);
//         vm.stopBroadcast();

//         uint256 fundMeBalanceBeforeFunding = address(fundMe).balance;

//         vm.startBroadcast();
//         fundMe.fund{value: SEND_VALUE}();
//         vm.stopBroadcast();
        
//         uint256 fundMeBalanceAfterFunding = address(fundMe).balance;
        
//         uint256 fundMeOwnerBalanceBeforeWithdraw = fundMe.getOwner().balance;

//         vm.startPrank(fundMe.getOwner());
//         fundMe.cheaperWithdraw();
//         vm.stopPrank();

//         uint256 fundMeBalanceAfterWithdraw = address(fundMe).balance;

//         // console logs
//         console.log("FundMe balance before funding: ", fundMeBalanceBeforeFunding);
//         console.log("FundMe balance after funding contract: ", fundMeBalanceAfterFunding);
//         console.log("FundMe balance after withdrawing funds: ", fundMeBalanceAfterWithdraw);
//         console.log("FundMe owner balance before withdrawing funds: ", fundMeOwnerBalanceBeforeWithdraw);
//         console.log("FundMe owner balance after withdrawing funds: ", fundMe.getOwner().balance);
//     }
// }
