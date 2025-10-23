// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

library Hook {
    // Token types (bits 0-7)
    uint24 internal constant COLLATERAL_TOKEN = 0x01;
    uint24 internal constant PROTECTED_TOKEN = 0x02;
    uint24 internal constant DEBT_TOKEN = 0x03;

    // Core protocol actions (1-15)
    uint256 internal constant DEPOSIT = 1;
    uint256 internal constant WITHDRAW = 2;
    uint256 internal constant BORROW = 3;
    uint256 internal constant REPAY = 4;
    uint256 internal constant TRANSITION_COLLATERAL = 5;
    uint256 internal constant LIQUIDATION = 6;
    uint256 internal constant FLASH_LIQUIDATION = 7;
    uint256 internal constant ACCRUE_INTEREST = 8;

    // Share token actions (16-23)
    uint256 internal constant SHARE_TOKEN_TRANSFER = 16;
    uint256 internal constant SHARE_TOKEN_MINT = 17;
    uint256 internal constant SHARE_TOKEN_BURN = 18;

    // Prediction market actions (24-31)
    uint256 internal constant RESOLUTION_TRIGGERED = 24;
    uint256 internal constant RESOLUTION_FINALIZED = 25;
    uint256 internal constant RESOLUTION_DISPUTED = 26;
    uint256 internal constant LOSING_POSITION_LIQUIDATED = 27;
    uint256 internal constant WINNINGS_DISTRIBUTED = 28;

    // Helper functions
    /**
     * @notice Checks if a specific action is enabled in a bitmask
     * @dev Uses bitwise AND to test if the action's bit is set
     * @param hooks Bitmask of enabled actions (24 bits)
     * @param action Action ID to check (must be 0-31)
     * @return True if action bit is set in bitmask
     */
    function matchAction(
        uint24 hooks,
        uint256 action
    ) internal pure returns (bool) {
        if (action > 31) return false;
        return (hooks & (1 << action)) != 0;
    }

    /**
     * @notice Encodes share token transfer action with token type
     * @dev Stores token type in upper bits, action ID in lower bits
     * @param tokenType Type of share token (COLLATERAL_TOKEN, PROTECTED_TOKEN, DEBT_TOKEN)
     * @return Encoded action value (action ID in lower bits, token type in upper bits)
     */
    function shareTokenTransfer(
        uint24 tokenType
    ) internal pure returns (uint256) {
        return SHARE_TOKEN_TRANSFER | (uint256(tokenType) << 8);
    }

    /**
     * @notice Decodes token type from an encoded share token transfer action
     * @param encodedAction Encoded action from shareTokenTransfer()
     * @return The token type (COLLATERAL_TOKEN, PROTECTED_TOKEN, or DEBT_TOKEN)
     */
    function decodeShareTokenTransfer(
        uint256 encodedAction
    ) internal pure returns (uint24) {
        return uint24(encodedAction >> 8);
    }

    /**
     * @notice Creates a bitmask with a single action enabled
     * @param action Action ID to enable (0-31)
     * @return Bitmask with only this action enabled
     */
    function setBit(uint256 action) internal pure returns (uint24) {
        require(action <= 31, "Hook: action out of range");
        return uint24(1 << action);
    }

    /**
     * @notice Combines multiple actions into a single bitmask
     * @dev Uses bitwise OR to set multiple bits
     * @param actions Array of action IDs to enable
     * @return combined Bitmask with all specified actions enabled
     */
    function combineBits(
        uint256[] memory actions
    ) internal pure returns (uint24 combined) {
        for (uint256 i = 0; i < actions.length; i++) {
            require(actions[i] <= 31, "Hook: action out of range");
            combined |= uint24(1 << actions[i]);
        }
    }

    /**
     * @notice Checks if a bitmask has no actions enabled
     * @param hooks Bitmask to check
     * @return True if bitmask is 0 (no hooks enabled)
     */
    function isEmpty(uint24 hooks) internal pure returns (bool) {
        return hooks == 0;
    }
}
