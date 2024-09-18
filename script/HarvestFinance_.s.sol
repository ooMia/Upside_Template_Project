// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import "forge-std/Script.sol";

interface CurveStrategy {
    function deposit(uint256) external;
    function withdraw(uint256) external;
}

contract Rw2_ is Script {
    uint256 immutable secret = vm.envUint("PRIVATE_KEY");
    address immutable attacker = vm.rememberKey(secret);
    address constant usdt = address(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    address constant usdc = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    Exploit immutable exploit = new Exploit(usdt, usdc);

    function run() external {
        vm.startBroadcast(secret);

        exploit.run();

        vm.stopBroadcast();
    }
}

import {Address} from "@openzeppelin/contracts/utils/Address.sol";

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

interface IHarvestVault {
    function deposit(uint256 amountWei) external;

    function withdraw(uint256 numberOfShares) external;

    function balanceOf(address account) external view returns (uint256);
}

interface IHarvestETHController {
    function vaults(address) external view returns (address);
}

interface IcurveYSwap {
    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external;

    function exchange_underlying(int128 i, int128 j, uint256 dx, uint256 min_dy) external;
}

interface IWrappedNative is IERC20 {
    function deposit() external payable;
    function withdraw(uint256 wad) external;
}

interface IUSDT {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external;

    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address from, address to, uint256 value) external;
    function approve(address spender, uint256 value) external;
}

import {IERC20, IUniswapV2Callee, IUniswapV2Factory, IUniswapV2Pair} from "./IUniswapV2.sol";

contract Exploit is IUniswapV2Callee {
    using Address for address;

    // ======== CONSTANTS ========

    address immutable owner;

    IHarvestETHController constant harvestETHController =
        IHarvestETHController(0x222412af183BCeAdEFd72e4Cb1b71f1889953b1C);
    IUniswapV2Router constant router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Factory constant factory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);

    IUSDT constant usdt = IUSDT(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    IERC20 constant usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20 constant dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IWrappedNative immutable weth = IWrappedNative(router.WETH());

    IERC20 immutable mainToken;
    IERC20 immutable subToken;
    IUniswapV2Pair immutable mainPair; // WETH-MainToken
    IUniswapV2Pair immutable subPair; // WETH-SubToken

    IHarvestVault immutable harvest;
    address constant harvestUsdtVault = address(0x053c80eA73Dc6941F518a68E2FC52Ac45BDE7c9C); // HVault: fUSDT
    address constant harvestUsdcVault = address(0xf0358e8c3CD5Fa238a29301d0bEa3D63A17bEdBE); // HVault: fUSDC
    address constant harvestDaiVault = address(0xab7FA2B2985BCcfC13c6D86b1D5A17486ab1e04C); // HVault: fDAI

    IcurveYSwap constant curveYSwap = IcurveYSwap(0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51); // yCurve

    // ERC20 fusdt = ERC20(0x053c80eA73Dc6941F518a68E2FC52Ac45BDE7c9C);
    // ERC20 fusdc = ERC20(0xf0358e8c3CD5Fa238a29301d0bEa3D63A17bEdBE);

    // ======== INITIALIZATION ========

    /// @dev choose main token and sub token
    /// currently only supports between USDT and USDC
    constructor(address _mainToken, address _subToken) {
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
            mainPair = IUniswapV2Pair(factory.getPair(address(weth), address(mainToken)));
            subPair = IUniswapV2Pair(factory.getPair(address(weth), address(subToken)));
            require(address(mainPair) != address(0) && address(subPair) != address(0), "Pair not found");
        }
    }

    function run() external view {
        // doSwap(mainToken, subToken, 1e18); // INSUFFICIENT_LIQUIDITY
        // doSwap(weth, mainToken, 1e18);
    }

    function uniswapV2Call(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external override {
        require(msg.sender == address(mainPair) || msg.sender == address(subPair), "Unauthorized");

        // 1. flashloan
        // 2. arbitrage
        // 3. repay flashloan
    }

    function doSwap(IERC20 in_token, IERC20 out_token, uint256 amount) public {
        if (amount == 0) {
            return;
        }

        IUniswapV2Pair pair = IUniswapV2Pair(factory.getPair(address(out_token), address(in_token)));
        uint256 amountOut = amount;

        (uint256 res0, uint256 res1,) = pair.getReserves();

        console.log(IERC20(pair.token0()).name(), "   \tRES0:", res0);
        console.log(IERC20(pair.token1()).name(), "   \tRES1:", res1);

        // console.log("IN:", in_token, "OUT:", out_token);
        pair.swap(
            pair.token0() == address(out_token) ? amountOut : 0,
            pair.token0() == address(out_token) ? 0 : amountOut,
            address(this),
            new bytes(0)
        );
        console.log("SWAP OUT", address(out_token), out_token.balanceOf(address(this)));
    }

    function helper() internal view {
        for (uint256 i = 0; i < factory.allPairsLength(); i++) {
            IUniswapV2Pair pair = IUniswapV2Pair(factory.allPairs(i));
            if (pair.token0() == address(dai) || pair.token1() == address(dai)) {
                (uint256 res0, uint256 res1,) = pair.getReserves();
                if (res0 / 1e18 > 0 && res1 / 1e18 > 0) {
                    console.log("----- [%d] %x -----", i, address(pair));
                    console.log(IERC20(pair.token0()).name(), pair.token0());
                    console.log(IERC20(pair.token1()).name(), pair.token1());
                    console.log("Reserves : ", res0 / 1e18, res1 / 1e18);
                    console.log("-----------------");
                }
            }
        }
    }
}
