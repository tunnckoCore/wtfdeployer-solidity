# WTFDeployer

Solidity v0.8 Token Deployer Factory for cheaply deploying secure ERC-20 Burnable tokens with no ownership. Allows for deploying with CREATE2 too. The ownership of the created token is renounced immediately after creation.

## Info

There are 3 contracts in this project.

- `WTF20.sol` - copy of the OpenZeppelin's ERC-20 with added methods for Ownable, and ERC-20 Burnable
- `WTFDeployer` - a contract once deloyed anyone can deloy ERC-20 Burnable tokens with ease
- `WTFDeployerWithLottery` - the same contract, but allows to deploy [BurnLotto](https://github.com/tunnckoCore/burnlotto) for the created token automagically if the deployer want

**Note:** The deployer of `WTFDeployer` gets 1% of the supply of every token that's created through that deployer. This acts as a service fee.

### more info soon
