// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

interface IPolymarketCTF {
    /**
     * @notice Gets token balance for a single token ID
     * @param account Address to query
     * @param tokenId Token ID (position ID in CTF)
     * @return Balance
     */
    function balanceOf(
        address account,
        uint256 tokenId
    ) external view returns (uint256);

    /**
     * @notice Gets balances for multiple token IDs
     * @param accounts Array of addresses
     * @param tokenIds Array of token IDs
     * @return Array of balances
     */
    function balanceOfBatch(
        address[] calldata accounts,
        uint256[] calldata tokenIds
    ) external view returns (uint256[] memory);

    /**
     * @notice Transfers tokens (ERC1155)
     * @param from Source address
     * @param to Destination address
     * @param id Token ID
     * @param amount Amount to transfer
     * @param data Additional data
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @notice Batch transfers tokens
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
     * @notice Gets payout numerator for outcome index
     * @dev Used to determine resolution (which outcome won)
     * @param conditionId Polymarket condition ID
     * @param index Outcome index (0 for NO, 1 for YES typically)
     * @return Payout numerator
     */
    function payoutNumerators(
        bytes32 conditionId,
        uint256 index
    ) external view returns (uint256);

    /**
     * @notice Checks if condition is resolved in CTF
     * @param conditionId Polymarket condition ID
     * @return True if resolved
     */
    function isResolved(bytes32 conditionId) external view returns (bool);
}
