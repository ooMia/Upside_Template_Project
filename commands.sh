yarn install

cast bn -r rw1 # get last block number: 6919826

cast b -r rw1 0xc943edb4bb4439d65b81f2f60bc698411e910b14  # get balance

cast age -r rw1

cast f -r rw1 1

0xc943edb4bb4439d65b81f2f60bc698411e910b14

0x16c22a7571b57b4b5e46ddbbd3b4bd6d698db267073b4765ee25cda3b2d30789




cast b -r rw1 -B $(cast bn -r rw1) 0xc943edb4bb4439d65b81f2f60bc698411e910b14  # get balance

cast wallet list



echo $(cast wallet dk upside)
Enter password: 
upside's private key is: 0x1c22a7571b51112d476ee30111bd3073b24b7b46b11146ddbb51116d698db267



# get user's pk

$(cast wallet dk upside) | tail -c 68 # dd



forge script --chain sepolia script/NFT.s.sol:MyScript --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv



forge test --contracts ./src/test/2021-04/Uranium_exp.sol -vv

# https://github.com/SunWeb3Sec/DeFiHackLabs



Fei Rari
RPC: https://upside-chal.chainlight.io/rw3/rpc/oomia.dev:6a8b7b6487e4c363c3a66ba94eed539592472f8d2604703fa838ad3b45c38400
Reset: https://upside-chal.chainlight.io/rw3/rpc/oomia.dev:6a8b7b6487e4c363c3a66ba94eed539592472f8d2604703fa838ad3b45c38400
Superfluid
RPC: https://upside-chal.chainlight.io/rw4/rpc/oomia.dev:6a8b7b6487e4c363c3a66ba94eed539592472f8d2604703fa838ad3b45c38400
Reset: https://upside-chal.chainlight.io/rw4/rpc/oomia.dev:6a8b7b6487e4c363c3a66ba94eed539592472f8d2604703fa838ad3b45c38400
Superfluid v2 (patched)



1. Flash loan USDT & USDC
2. Exchange USDC -> USDT on yCurve (Pump USDT)
3. Deposit USDT to Harvest FARM_USDT
4. Exchange USDT -> USDC on yCurve (Dump USDT)
5. Withdraw shares from the third step
6. Repay flash loan
7. Iterate 1-6 N times
8. Profit!

# Harvest Finance
h = HVault(0x053c80eA73Dc6941F518a68E2FC52Ac45BDE7c9C);
c = CurveStrategy(0x1C47343eA7135c2bA3B2d24202AD960aDaFAa81c);
y = yCurve(0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51);
uUSDT = UniSwapV2(0x0d4a11d5EEaaC28EC3F61d100daF4d40471f1852);
uUSDC = UniSwapV2(0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc);
usdt = ERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
usdc = ERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);



# Fei Rari

# https://etherscan.io/address/0x6162759edad730152f0df8115c698a42e666157f
IERC20 DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
ComptrollerInterface unitroller =
ComptrollerInterface(0xc54172e34046c1653d1920d40333Dd358c7a1aF4);
CErc20Interface fDAI = CErc20Interface(0x7e9cE3CAa9910cc048590801e64174957Ed41d43);
CErc20Interface fETH = CErc20Interface(0xbB025D470162CC5eA24daF7d4566064EE7f5F111);





# Superfluid
superfluid = 0x3E14dC1b13c488a8d5D310918780c983bD5982E7
ida = 0xB0aABBA4B2783A72C52956CDEF62d438ecA2d7a1
superusdc = 0xCAa7349CEA390F89641fe306D93591f87595dc1F
usdc = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174
victim = ?
victim = 0x2e9e3C24049655f2D8C59f08602Da3DE4aD34188