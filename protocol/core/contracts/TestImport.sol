// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.28;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title TestImports
contract TestImports is ERC20 {
    constructor() ERC20("ImportToken", "IMPT") {
        _mint(msg.sender, 1_000 ether);
    }
}
