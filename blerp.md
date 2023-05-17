
# ----- Notes to work on BEFORE real day -----
- write contracts and find airdrop list; 
    >> - art, autocrat, vitalik, s0c, merp, chad, xxx
    >> 1. Socrates	469-399 BC	The father of Western philosophy, known for his method of inquiry called the Socratic method.
    >> 2. Plato	428-348 BC	A student of Socrates, Plato founded the Academy in Athens, where Aristotle studied. He is best known for his theory of Forms.
    >> 3. Aristotle	384-322 BC	A student of Plato, Aristotle was a polymath who made significant contributions to many fields, including philosophy, science, and politics. He is known for his theory of the four causes.
    >> 4. Confucius	551-479 BC	A Chinese philosopher who emphasized the importance of education, morality, and social harmony. He is best known for his Analects.
    >> 5. Buddha	563-483 BC	A spiritual teacher who founded Buddhism. He is best known for his Four Noble Truths and the Eightfold Path.
    >> 6. Marcus Aurelius	121-180 AD	A Roman emperor and Stoic philosopher. He is best known for his Meditations.
    >> 7. René Descartes	1596-1650	A French philosopher who is considered the father of modern philosophy. He is best known for his famous statement "I think, therefore I am."
    >> 8. David Hume	1711-1776	A Scottish philosopher who was a leading figure in the Enlightenment. He is best known for his skepticism and his attack on the idea of innate ideas.
    >> 9. Immanuel Kant	1724-1804	A German philosopher who is considered one of the most important thinkers of the Enlightenment. He is best known for his theory of synthetic a priori knowledge.
    >> 10. Friedrich Nietzsche	1844-1900	A German philosopher who is considered one of the most influential thinkers of the 19th century. He is best known for his critique of Christianity and his concept of the Übermensch.
    >> 11. Simone de Beauvoir	1908-1986	A French existentialist philosopher and feminist. She is best known for her book The Second Sex.
    >> 12. Michel Foucault	1926-1984	A French philosopher and historian of ideas. He is best known for his work on power, discourse, and the body.
    >> 13. Ban Zhao	45-116	A Chinese philosopher and historian. She is best known for her book Lessons for Women, which is one of the earliest works of feminist philosophy.
- how to set up LP for WBON on Mod [0.5B CULT &&  BONNFT WBON funds]
    >> - https://designingtokenomics.com/the-complete-tokenomics-course-primer/articles/liquidity-matters-how-to-setup-liquidity-for-a-token
    >> - https://support.uniswap.org/hc/en-us/articles/7423194619661-How-to-provide-liquidity-on-Uniswap-V3
- xxx
    >> - xxx


# ----- Notes to remember on REAL day -----

**0 PRE DEPLOYMENTS**:
- clean up airdrop list
    >> https://docs.google.com/spreadsheets/d/1utck9-9MXnCJFf329RT2UoMNhQqgVd2wXyJhJJnl7ZY/
- use ledger BON_DEPLYR for all things;
    >> 0x287B6551Ab70E38E4c1de44643340b56739ff306
- Bridge tokens
    >> 0x28.... 1B cult for LPs && ~$4k BON for WBON/CULT LP
    >> 0xc70... my personal BON to bridge (this is freedom fund wallet)

**1 STAKING DEPLOY**:
- use WBON as address temporarily
- var: 604800 (7 days)
- var: 50 (5% of pool)

**2 WBON EXCHANGE DEPLOY**:
- Use WBON address and WBON address for now, and switch BANK later
- Use 2081376000 (66 years) for exchange timer
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

**6 WBANK EXCHANGE DEPLOY**:
- Use 2081376000 (66 years) for exchange timer
- 

**7 Update BONWORLD website**
- xx

**8 13 NFTs DEPLOY**
- contracts, art, ipfs, contracts


# ----- Other Notes -----

**TODOOO LATTEERRR**:
- todo ; use api3 air nodes qrnd on Modulus to make a simple scratcher card dapp that takes an upfront cost and uses probability into make sure that the house wins more----- or I can make a bet on the weather dApp that uses one source for distant weathwr predictions and then pay out based on the bet, people can bet to double their money and if it exists ij the pool then its sent but if they lose it just staysijn the pool AND BON makes money from a 4% tax on on and out
- WBANK LP on Polygon




**DEV NOTES**
- For forked testing: forge test --fork-url https://polygon-mainnet.g.alchemy.com/v2/elpiyNU3HOchYaeMMpCteXolAFqJYTEi --match-contract <test contract name> -vvv
- For specific test names: forge test --match-contract <test contract name>- vvv
- xxxxxxxxxxxxxxx
