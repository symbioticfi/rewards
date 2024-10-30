const { StandardMerkleTree } = require('@openzeppelin/merkle-tree')
const fs = require('fs')
const path = require('path')

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

  const treesJson = []
  for (const [token, { tree }] of Object.entries(trees)) {
    treesJson.push({ token, tree })
  }

  const fileName = 'data/trees.json'
  const filePath = path.join(__dirname, fileName)

  fs.writeFileSync(filePath, JSON.stringify(treesJson, null, 2))
  console.log(`Trees written to ${fileName}`)
}

main()
