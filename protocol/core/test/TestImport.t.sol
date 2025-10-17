// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {Test} from "forge-std/Test.sol";
import {TestImports} from "../contracts/TestImport.sol";

contract TestImportsTest is Test {
    function testMintedSupply() public {
        TestImports t = new TestImports();
        // Deployer is this test contract
        assertEq(t.balanceOf(address(this)), 1_000 ether);
    }
}
