
# Notes to remember on REAL day
**PRE DEPLOYMENTS**:
- make a new MetaMask wallet secured by ledger
- use this for all deploys and then slowly switch out

**TOKEN DEPLOY**:
- clean up airdrop list https://docs.google.com/spreadsheets/d/1utck9-9MXnCJFf329RT2UoMNhQqgVd2wXyJhJJnl7ZY/
- on first deploy on mainnet, set all treasuries to OWNER ldgr wallet
- later, this contract owner should be ledger, but treasuries NOT


**STAKING DEPLOY**:
- set staking status as TRUE
- need to add STAKING contract address to BANK bonStakers addr var asap
- need to whitelist STAKING address on token contract asap
- send some BANK to stakingContract ASAP for rewardsCalc to work
- stake as many wallets as possible to decrease the reward proportion ratio

**EXCHANGE DEPLOY**:
- need to whitelist EXCHANGE address on token contract asap
- need to send 10.5m BANK to exchange contract

**BANK LP SETUP**:
- LP token split [1B CULT && 8.4M BANK] (?)
- Bridge CULT over to ledger wallet (?)
- Burn LP tokens if possible














- todo ; use api3 air nodes on Modulus













# DEV NOTES
- For forked testing: forge test --fork-url https://polygon-mainnet.g.alchemy.com/v2/elpiyNU3HOchYaeMMpCteXolAFqJYTEi --match-contract <test contract name> -vvv
- For specific test names: forge test --match-contract <test contract name> -vvv
