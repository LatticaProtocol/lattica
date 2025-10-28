// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IPolymarketOracle} from "./interfaces/IPolymarketOracle.sol";

/// @notice Mock oracle returning prices per tokenId and a binary payout after resolution
contract PolymarketOracleMock is IPolymarketOracle {
    mapping(uint256 => uint256) public price; // 1e18 scaled
    bool public resolved;
    uint256 public winnerId;

    function setPrice(uint256 id, uint256 p) external {
        price[id] = p;
    }

    function setPrices(uint256 idA, uint256 pA, uint256 idB, uint256 pB) external {
        price[idA] = pA;
        price[idB] = pB;
    }

    function resolve(uint256 _winnerId) external {
        resolved = true;
        winnerId = _winnerId;
    }

    function isResolved() external view returns (bool) {
        return resolved;
    }

    function payout(uint256 tokenId) external view returns (uint256) {
        if (!resolved) return 0;
        return tokenId == winnerId ? 1e18 : 0;
    }
}
