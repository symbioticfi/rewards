const { StandardMerkleTree } = require('@openzeppelin/merkle-tree')
const fs = require('fs')

const Distribution = require('./data/distribution.json')

function generateMerkleTrees() {
  const trees = {}

  Distribution.forEach((tokenData) => {
    const values = tokenData.operators.map(({ operator, reward }) => [
      operator,
      reward.toString(),
    ])
    const tree = StandardMerkleTree.of(values, ['address', 'uint256'])
    trees[tokenData.token] = { tree, values }
  })

  return trees
}

function main() {
  const trees = generateMerkleTrees()

  for (const [token, { tree }] of Object.entries(trees)) {
    console.log(`-------------------------------`)
    console.log(`Token: ${token}`)
    console.log(`Merkle Root: ${tree.root}`)
  }
}

main()
