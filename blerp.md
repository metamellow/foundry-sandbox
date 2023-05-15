
- make a WBANK to BON exchange on Polygon; bridge the BON over and stock the contract; but on the Polygon bridge, add a 4% tax that burns and sends back to Modulus BANK staking; label BONtoBANK as taxfree and then label BANKtoBON as 4%; going to need to make a new graphic; can use the idea of yin and yang;
- also, add secondary third etc staking pools that work in conjunction with the current system 







# ----- Notes to remember on REAL day -----

**0 PRE DEPLOYMENTS**:
- clean up airdrop list
    >> https://docs.google.com/spreadsheets/d/1utck9-9MXnCJFf329RT2UoMNhQqgVd2wXyJhJJnl7ZY/
- use ledger BON_DEPLYR for all things;
    >> 0x287B6551Ab70E38E4c1de44643340b56739ff306
- Bridge tokens
    >> 0x28.... 1B cult for LPs && ~$4k BON for WBON/CULT LP
    >> 0xc70... my personal BON to bridge (this is freedom fund wallet)
- set up LP for WBON on Mod [0.5B CULT &&  BONNFT WBON funds]
    >> https://designingtokenomics.com/the-complete-tokenomics-course-primer/articles/liquidity-matters-how-to-setup-liquidity-for-a-token
    >> https://support.uniswap.org/hc/en-us/articles/7423194619661-How-to-provide-liquidity-on-Uniswap-V3


**1 STAKING DEPLOY**:
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
    address _treasury,      0xtemp-onLedgerMMSKForNow
    address _stakers,       0xtemp-onLedgerMMSKForNow
    address _devs,          0xtemp-onLedgerMMSKForNow
    uint _tax,              4
- 

**4 FINALIZATION**:
- need to send 10.5m BANK to exchange contract; then exchange MY WBON
- need to whitelist EXCHANGE and STAKING and a TRADING wallet address on token contract
- send some BANK to stakingContract ASAP for rewardsCalc to work; and stake TWO wallets at least
- set staking status as TRUE

**5 BANK LP SETUP**:
- LP token split [0.5B CULT && 8.4M BANK]
- 

**6 12 NFTs DEPLOY**
- ... utility?


# ----- Other Notes -----

**TODOOO LATTEERRR**:
- todo ; use api3 air nodes qrnd on Modulus to make a simple scratcher card dapp that takes an upfront cost and uses probability into make sure that the house wins more
- WBANK LP on Polygon




**DEV NOTES**
- For forked testing: forge test --fork-url https://polygon-mainnet.g.alchemy.com/v2/elpiyNU3HOchYaeMMpCteXolAFqJYTEi --match-contract <test contract name> -vvv
- For specific test names: forge test --match-contract <test contract name>- vvv
- xxxxxxxxxxxxxxx
