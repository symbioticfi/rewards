## Operator Rewards

The network distributes the operator rewards at its discretion. Here are three examples:

1. The network performs off-chain calculations to determine the reward distributions. After calculating the rewards, the network executes batch transfers to distribute the rewards in a consolidated manner.
2. The network performs off-chain calculations to determine rewards and generates a Merkle tree, allowing operators to claim their rewards.
3. The network performs on-chain reward calculations within its middleware to determine the distribution of rewards.

##### Source of Data for Network On-Chain Reward Calculations

For operator rewards, the delegator module of the vault provides:

- `Delegator.stakeAt(network, operator, timestamp, hint)` - Active stake of an operator in the network.

Additionally, all operators register through the network, providing necessary details such as commission rates, fixed payments, and other relevant conditions. This registration process ensures that networks have the required data to perform accurate on-chain reward calculations in their middleware.

### Deploy

```shell
source .env
```

#### Deploy factory

Deployment script: [click](../script/deploy/DefaultOperatorRewardsFactory.s.sol)

```shell
forge script script/deploy/DefaultOperatorRewardsFactory.s.sol:DefaultOperatorRewardsFactoryScript 0x0000000000000000000000000000000000000000 --sig "run(address)" --broadcast --rpc-url=$ETH_RPC_URL
```

#### Deploy entity

Deployment script: [click](../script/deploy/DefaultOperatorRewards.s.sol)

```shell
forge script script/deploy/DefaultOperatorRewards.s.sol:DefaultOperatorRewardsScript 0x0000000000000000000000000000000000000000 --sig "run(address)" --broadcast --rpc-url=$ETH_RPC_URL
```

### CLI

#### Install packages

```shell
npm install
```

#### Use commands

**distributionToRoots**

```shell
node cli/defaultOperatorRewards/distributionToRoots.js
```

Get a Merkle root for each rewards distribution by token.

_Make sure to save `distribution.json` to `cli/defaultOperatorRewards/data` folder. You can check [an example format here](../cli/defaultOperatorRewards/data/distribution.json.example)._

---

**distributionToProofs**

```shell
node cli/defaultOperatorRewards/distributionToProofs.js OPERATOR
```

Get proofs for all tokens in a rewards distribution for a given operator.

_Make sure to save `distribution.json` to `cli/defaultOperatorRewards/data` folder. You can check [an example format here](../cli/defaultOperatorRewards/data/distribution.json.example)._

Arguments:

- `OPERATOR` - an address of the operator to get proofs for

---

**distributionToTrees**

```shell
node cli/defaultOperatorRewards/distributionToTrees.js
```

Saves OZ Merkle tree structures constructed from the rewards distribution to `cli/defaultOperatorRewards/data/trees.json`.

_Make sure to save `distribution.json` to `cli/defaultOperatorRewards/data` folder. You can check [an example format here](../cli/defaultOperatorRewards/data/distribution.json.example)._

---

**treesToRoots**

```shell
node cli/defaultOperatorRewards/treesToRoots.js
```

Get a Merkle root for each Merkle tree by token.

_Make sure to save `trees.json` to `cli/defaultOperatorRewards/data` folder. You can check [an example format here](../cli/defaultOperatorRewards/data/trees.json.example)._

---

**treesToProofs**

```shell
node cli/defaultOperatorRewards/treesToProofs.js OPERATOR
```

Get proofs for all tokens in Merkle trees for a given operator.

_Make sure to save `trees.json` to `cli/defaultOperatorRewards/data` folder. You can check [an example format here](../cli/defaultOperatorRewards/data/trees.json.example)._

Arguments:

- `OPERATOR` - an address of the operator to get proofs for

---

**treesToDistribution**

```shell
node cli/defaultOperatorRewards/treesToDistribution.js
```

Saves a rewards distribution constructed from the OZ Merkle trees to `cli/defaultOperatorRewards/data/distribution.json`.

_Make sure to save `trees.json` to `cli/defaultOperatorRewards/data` folder. You can check [an example format here](../cli/defaultOperatorRewards/data/trees.json.example)._
