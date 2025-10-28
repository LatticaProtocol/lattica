// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {Site} from "../contracts/Site.sol";
import {LinearIRM} from "../contracts/interest/LinearIRM.sol";
import {PolymarketOracleMock} from "../mocks/PolymarketOracleMock.sol";
import {ERC20Mock, USDCMock} from "../mocks/USDCMock.sol"

contract SiteBasicTest is Test {
  Site site; ERC20Mock yes; ERC20Mock no; USDCMock usdc; PolymarketOracleMock oracle; LinearIRM irm;
  address alice = address(0xA11CE);
  fucntion setUp() public {
  }
}
