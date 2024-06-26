## Rewards

For staker rewards calculation, the vault provides the following data:

- `activeSharesOfAt(account, timestamp)` - $\text{active}$ shares of the user at a specific timestamp
- `activeSharesAt(timestamp)` - total $\text{active}$ shares at a specific timestamp.
- Other checkpointed getters

Reward processing is not integrated into the vault's functionality. Instead, external reward contracts should manage this using the provided data.

However, we created the first version of the `IStakerRewards` interface to facilitate more generic reward distribution across networks.

- `IStakerRewards.version()` - provides a version of the interface that a particular rewards distributor uses
- `IStakerRewards.distributeReward(network, token, amount, timestamp)` - call to distribute `amount` of `token` on behalf of `network` using `timestamp` as a time point for calculations

The vault's rewards distributor's address can be obtained via the `stakerRewards()` method, which can be set by the `STAKER_REWARDS_SET_ROLE` holder.

### Deploy

```shell
source .env
```

#### Deploy factory

Deployment script: [click](../script/deploy/defaultStakerRewards/DefaultStakerRewardsFactory.s.sol)

```shell
forge script script/deploy/defaultStakerRewards/DefaultStakerRewardsFactory.s.sol:DefaultStakerRewardsFactoryScript 0x0000000000000000000000000000000000000000 0x0000000000000000000000000000000000000000 0x0000000000000000000000000000000000000000 --sig "run(address,address,address)" --broadcast --rpc-url=$ETH_RPC_URL
```

#### Deploy entity

Deployment script: [click](../script/deploy/defaultStakerRewards/DefaultStakerRewards.s.sol)

```shell
forge script script/deploy/defaultStakerRewards/DefaultStakerRewards.s.sol:DefaultStakerRewardsScript 0x0000000000000000000000000000000000000000 0x0000000000000000000000000000000000000000 --sig "run(address,address)" --broadcast --rpc-url=$ETH_RPC_URL
```
