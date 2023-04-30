
# Notes to remember on REAL day
TOKEN DEPLOY:
- on first deploy on mainnet, set all treasuries to OWNER wallet
- later, this contract owner should be ledger, but treasuries NOT


EXCHANGE DEPLOY:
- need to add exchange contract address to BANK bonStakers addr var asap
- need to whitelist exchange address on token contract asap
- send some BANK to stakingContract ASAP for rewardsCalc to work
- stake as many wallets as possible to decrease the reward proportion ratio












# DEV NOTES
- For forked testing: forge test --fork-url https://polygon-mainnet.g.alchemy.com/v2/elpiyNU3HOchYaeMMpCteXolAFqJYTEi --match-contract <test contract name> -vvv
- For specific test names: forge test --match-contract <test contract name> -vvv
- airdrop list: https://docs.google.com/spreadsheets/d/1utck9-9MXnCJFf329RT2UoMNhQqgVd2wXyJhJJnl7ZY/
- Add emits to EVERYTHING because this makes JS interaction way way easier

>> DO NOW
- LP token split [1B CULT && 8.4M BANK]
- bridge stuff; xxxx >>NOT DONE!!!! 

>> DO LATER
1. Create a BON Uniswap dApp:
- https://stackoverflow.com/questions/71001299/typeerror-msg-value-and-callvalue-can-only-be-used-in-payable-public-func
2. 