
# ----- Notes to remember on REAL day -----

**0 PRE DEPLOYMENTS**:
- make a new MetaMask wallet secured by ledger; use this for all deploys and then slowly switch out
- Send CULT to bridge to this wallet
- Purchase BON with BONNFT money and bridge that over
- set up LP for WBON on Mod [0.5B CULT &&  BONNFT WBON funds]
- clean up airdrop list https://docs.google.com/spreadsheets/d/1utck9-9MXnCJFf329RT2UoMNhQqgVd2wXyJhJJnl7ZY/
- Bridge over my own BON that I want to exchange to BANK

**1 STAKING DEPLOY**:
- I should really add a quick mint/burn token for staking receipt
- use WBON as address temporarily
- var: 604800 (7 days)
- var: 50 (5% of pool)

**2 EXCHANGE DEPLOY**:
- Use WBON address and WBON address for now, and switch BANK later
- Use 2629746 (1 month) for exchange timer
- 

**3 TOKEN DEPLOY**:
- string memory _name,      Bank of Nowhere
    string memory _symbol,  BANK
    address _treasury,      0xtemp-onLedgerForNow
    address _stakers,       0xtemp-onLedgerForNow
    address _devs,          0xtemp-onLedgerForNow
    uint _tax,              4
- 

**4 FINALIZATION**:
- need to send 10.5m BANK to exchange contract; then exchange MY WBON
- need to whitelist EXCHANGE and STAKING and a TRADING wallet address on token contract
- send some BANK to stakingContract ASAP for rewardsCalc to work; and stake TWO wallets at least
- set staking status as TRUE

**5 BANK LP SETUP**:
- LP token split [0.5B CULT && 8.4M BANK]
- Bridge CULT over to ledger wallet (?)
- Burn LP tokens if possible
- I'm gonna have to also do LPs for WBANK and WBON..
- 

**6 12 NFTs DEPLOY**
- ... utility?


# ----- Other Notes -----

**TODOOO LATTEERRR**:
- todo ; use api3 air nodes qrnd on Modulus to make a simple scratcher card dapp that takes an upfront cost and uses probability into make sure that the house wins more
- 

**DEV NOTES**
- For forked testing: forge test --fork-url https://polygon-mainnet.g.alchemy.com/v2/elpiyNU3HOchYaeMMpCteXolAFqJYTEi --match-contract <test contract name> -vvv
- For specific test names: forge test --match-contract <test contract name>- vvv
- xxxxxxxxxxxxxxx
