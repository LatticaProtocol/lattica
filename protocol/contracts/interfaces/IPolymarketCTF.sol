// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

interface IPolymarketCTF {
    /**
     * @notice Gets balance of a specific token
     * @param account Address to query
     * @param tokenId Token ID (condition ID + position)
     * @return Balance of the token
     */
    function balanceOf(address account, uint256 tokenId) external view returns (uint256);

    /**
     * @notice Gets balances for multiple tokens
     * @param accounts Array of addresses
     * @param tokenIds Array of token IDs
     * @return Array of balances
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata tokenIds)
        external
        view
        returns (uint256[] memory);

    /**
     * @notice Transfers a single token
     * @param from Source address
     * @param to Destination address
     * @param id Token ID
     * @param amount Amount to transfer
     * @param data Additional data
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

    /**
     * @notice Transfers multiple tokens
     * @param from Source address
     * @param to Destination address
     * @param ids Array of token IDs
     * @param amounts Array of amounts
     * @param data Additional data
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

    /**
     * @notice Gets payout numerator for a position
     * @dev After resolution, determines how much each position gets (0 or 1e6)
     * @param conditionId Condition ID
     * @param index Position index (0 = NO, 1 = YES typically)
     * @return Payout numerator (0 for losers, 1e6 for winners)
     */
    function payoutNumerators(bytes32 conditionId, uint256 index) external view returns (uint256);

    /**
     * @notice Checks if condition is resolved
     * @param conditionId Condition ID
     * @return True if resolved
     */
    function isResolved(bytes32 conditionId) external view returns (bool);
}
