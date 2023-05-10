
# Notes to remember on REAL day
**PRE DEPLOYMENTS**:
- make a new MetaMask wallet secured by ledger
- use this for all deploys and then slowly switch out
- bridge the BON I want to both exchange and ALSO for the LP for WBON on Mod which I should set up before doing anything else

**TOKEN DEPLOY**:
- add 4 only owner vars for the tax proportions but require them to all add up to 100
- clean up airdrop list https://docs.google.com/spreadsheets/d/1utck9-9MXnCJFf329RT2UoMNhQqgVd2wXyJhJJnl7ZY/
- on first deploy on mainnet, set all treasuries to OWNER ldgr wallet
- later, this contract owner should be ledger, but treasuries NOT


**STAKING DEPLOY**:
- I should really add a quick mint/burn token for staking receipt
- set staking status as TRUE
- need to add STAKING contract address to BANK bonStakers addr var asap
- need to whitelist STAKING address on token contract asap
- send some BANK to stakingContract ASAP for rewardsCalc to work
- stake as many wallets as possible to decrease the reward proportion ratio

**EXCHANGE DEPLOY**:
- need to whitelist EXCHANGE address on token contract asap
- need to send 10.5m BANK to exchange contract

**BANK LP SETUP**:
- LP token split [1B CULT && 8.4M BANK] (actually NO I need to split the 1B between the BANK but also the WBON needed to exchange and just buysell on Mod .. and the WBANK can be done by me for me..)
- Bridge CULT over to ledger wallet (?)
- Burn LP tokens if possible
- I'm gonna have to also do LPs for WBANK and WBON..













- todo ; use api3 air nodes qrnd on Modulus to make a simple scratcher card dapp that takes an upfront cost and uses probability into make sure that the house wins more













# DEV NOTES
- For forked testing: forge test --fork-url https://polygon-mainnet.g.alchemy.com/v2/elpiyNU3HOchYaeMMpCteXolAFqJYTEi --match-contract <test contract name> -vvv
- For specific test names: forge test --match-contract <test contract name> -vvv
