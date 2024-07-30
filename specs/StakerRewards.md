## Staker Rewards

For staker rewards calculation, the vault provides the following data:

- `activeSharesOfAt(account, timestamp, hint)` - $\text{active}$ shares of the user at a specific timestamp
- `activeSharesAt(timestamp, hint)` - total $\text{active}$ shares at a specific timestamp.
- Other checkpointed getters

Reward processing is not integrated into the vault's functionality. Instead, external reward contracts should manage this using the provided data.

However, we created the first version of the `IStakerRewards` interface to facilitate more generic reward distribution across networks.

- `IStakerRewards.version()` - provides a version of the interface that a particular rewards contract uses
- `IStakerRewards.distributeRewards(network, token, amount, data)` - call to distribute `amount` of `token` on behalf of `network` using an arbitrary `data`

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
forge script script/deploy/defaultStakerRewards/DefaultStakerRewards.s.sol:DefaultStakerRewardsScript 0x0000000000000000000000000000000000000000 0x0000000000000000000000000000000000000000 0 0x0000000000000000000000000000000000000000 0x0000000000000000000000000000000000000000 0x0000000000000000000000000000000000000000 --sig "run(address,address,uint256,address,address,address)" --broadcast --rpc-url=$ETH_RPC_URL
```
