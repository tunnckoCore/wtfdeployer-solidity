# Burn Lotto

A Solidity v0.8 lottery contract. Called BurnLotto, because players deposit an ERC20 burnable tokens, and a winner is chosen randomly when round is finished - x% of deposited tokens are burned, the rest are transferred to the winner.

## Background

I'm Open Source developer for a decade already. You can read more on my [GitHub profile](https://github.com/tunnckocore).

Or in short, my software created over the years has over 130m downloads per month, and over 4.3 billion in total.  
It's used by VSCode, Microsoft, Eclipse Foundation, ConsenSys, TruffleSuite, Ethereum / Web3 communities, Decentraland, Electron apps, Aragorn DAOs, and much more.

## The deployment

- Deployer must pass a ERC-20 Burnable token address
- And a signature - just a message signed with your wallet

**Note:** No one can do anything malicious. Not even the deployer, no need for `renounce`-ing or whatever. It's just 150 lines of code. No re-entrancy attacks. No owners. The deployer can be a player as any other, it has no roles or privilages.

### Goerli demo

- 59b supply $NEKO Cats ERC-20 burnable - https://goerli.etherscan.io/token/0x99130B0C69c4a892F5aD9ae8Da4Ab3C68AC52C4e
- the BurnLotto - https://goerli.etherscan.io/address/0x4280cbFd6dE77e98BC1934dfCbc4c572004b7545

## The Game

- A round should be started first by someone by calling `startRound`.
  - the `startRound` function must be called with amount of minutes a round will be opened
- Then players can deposit maximum 2 times, their ERC-20 Burnable tokens
  - those are contracts that have at least public `burn` function that can be called by the owner of the tokens
- When the time for a round ends, anyone can call `endRound`
  - this function expects a `percent` and a `signature` arguments
  - this `signature` can be created by signing some message with your wallet
  - the `percent` argument is how much percents of the deposited tokens to be burned
  - calculates randomly a winner from all the depositors
  - calculates x% (eg. 30%) of the deposited tokens and burn them forever
  - transfers the rest (eg. 70%) of the tokens to the chosen Winner
  - resets the state, and a new round can be started again

**Note:** It cannot be stopped or paused, or anything else. It emit events and has several view functions.

## Why signatures?

It ensures better on-chain randomness. There's one signature that's by the deployer, and one by the round closer. It could be even better if it includes all depositor signatures too, but that's avoided here for less friction to the players. Secured from 2 of 3 potentially malicious sides is better than nothing.

## License

[Apache-2.0](https://www.tldrlegal.com/license/apache-license-2-0-apache-2-0)
