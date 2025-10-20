// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

interface ISwapper {
    /// @notice Emitted when swap executes
    event Swap(
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        uint256 amountOut
    );

    /**
     * @notice Swaps exact amount in for minimum amount out
     * @dev Used when liquidator has exact collateral amount to sell
     * @param tokenIn Address of input token (YES/NO shares)
     * @param tokenOut Address of output token (USDC)
     * @param amountIn Exact amount of input tokens
     * @param minAmountOut Minimum acceptable output (slippage protection)
     * @param data DEX-specific calldata
     * @return amountOut Actual output amount received
     */
    function swapAmountIn(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minAmountOut,
        bytes calldata data
    ) external returns (uint256 amountOut);

    /**
     * @notice Swaps maximum amount in for exact amount out
     * @dev Used when liquidator needs exact USDC amount to repay debt
     * @param tokenIn Address of input token
     * @param tokenOut Address of output token
     * @param amountOut Exact amount of output tokens needed
     * @param maxAmountIn Maximum input tokens willing to spend
     * @param data DEX-specific calldata
     * @return amountIn Actual input amount used
     */
    function swapAmountOut(
        address tokenIn,
        address tokenOut,
        uint256 amountOut,
        uint256 maxAmountIn,
        bytes calldata data
    ) external returns (uint256 amountIn);

    /**
     * @notice Gets the address to approve for token spending
     * @dev Different DEXs have different router addresses
     * @return Address to approve tokens to
     */
    function spenderToApprove() external view returns (address);

    /**
     * @notice Quotes output amount for input amount
     * @param tokenIn Input token address
     * @param tokenOut Output token address
     * @param amountIn Input amount
     * @return Expected output amount
     */
    function getAmountOut(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) external view returns (uint256);

    /**
     * @notice Quotes input amount for output amount
     * @param tokenIn Input token address
     * @param tokenOut Output token address
     * @param amountOut Desired output amount
     * @return Required input amount
     */
    function getAmountIn(
        address tokenIn,
        address tokenOut,
        uint256 amountOut
    ) external view returns (uint256);
}
