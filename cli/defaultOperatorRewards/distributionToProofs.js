const { StandardMerkleTree } = require('@openzeppelin/merkle-tree')

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

function findProof(trees, operator) {
  for (const [token, { tree, values }] of Object.entries(trees)) {
    for (const [index, value] of values.entries()) {
      if (value[0].toLowerCase() === operator.toLowerCase()) {
        const proof = tree.getProof(index)
        console.log(`-------------------------------`)
        console.log(`Token: ${token}`)
        console.log(`Proof: ${JSON.stringify(proof)}`)
      }
    }
  }
}

function main() {
  const trees = generateMerkleTrees()

  const operator = process.argv[2]
  if (!operator) {
    console.error('Please provide an operator address.')
    process.exit(1)
  }

  findProof(trees, operator)
}

main()
