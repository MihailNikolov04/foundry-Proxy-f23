// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Test} from "forge-std/Test.sol";
import {DeployBox} from "../script/DeployBox.s.sol";
import {UpgradeBox} from "../script/UpdateBox.s.sol";
import {BoxV1} from "../src/BoxV1.sol";
import {BoxV2} from "../src/BoxV2.sol";

contract DeployAndUpgradeTest is Test {
    DeployBox public deployer;
    UpgradeBox public upgrader;
    address public OWNER = makeAddr("owner");
    BoxV1 public proxy;

    function setUp() public {
        deployer = new DeployBox();
        upgrader = new UpgradeBox();
        proxy = BoxV1(deployer.run());
    }

    function testProxyStartsAsBoxV1() public {
        vm.expectRevert();
        BoxV2(address(proxy)).setNumber(7);
    }

    function testUpgrades() public {
        BoxV2 boxV2 = new BoxV2();
        upgrader.upgradeBox(address(proxy), address(boxV2));

        uint256 expectedValue = 2;
        assertEq(expectedValue, BoxV2(address(proxy)).version());

        BoxV2(address(proxy)).setNumber(7);
        assertEq(7, BoxV2(address(proxy)).getNumber());
    }
}
