# DEV NOTES
- FOR TESTS THAT READ DATA FROM ONLINE:
forge test --fork-url https://polygon-mainnet.g.alchemy.com/v2/elpiyNU3HOchYaeMMpCteXolAFqJYTEi -vvv
- airdrop list: https://docs.google.com/spreadsheets/d/1utck9-9MXnCJFf329RT2UoMNhQqgVd2wXyJhJJnl7ZY/








# [1] Token Testing
- 

# [2] Staking Testing
- forge test --fork-url https://polygon-mainnet.g.alchemy.com/v2/elpiyNU3HOchYaeMMpCteXolAFqJYTEi --match-path test/bonTokenStaking.t.sol -vvv

# [3] Bridging Testing
- forge test --fork-url https://polygon-mainnet.g.alchemy.com/v2/elpiyNU3HOchYaeMMpCteXolAFqJYTEi --match-path test/bonExchange.t.sol -vvv

# [4] NFT Testing
- forge test --fork-url https://polygon-mainnet.g.alchemy.com/v2/elpiyNU3HOchYaeMMpCteXolAFqJYTEi --match-path test/bonNFT.t.sol -vvv