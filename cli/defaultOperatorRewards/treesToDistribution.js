const { StandardMerkleTree } = require('@openzeppelin/merkle-tree')
const fs = require('fs')
const path = require('path')

const Trees = require('./data/trees.json')

function parseMerkleTrees() {
  const trees = {}

  Trees.forEach((tokenData) => {
    const values = tokenData.tree.values.map(
      ({ value: [operator, reward] }) => [operator, reward]
    )
    const tree = StandardMerkleTree.of(values, ['address', 'uint256'])
    trees[tokenData.token] = { tree, values }
  })

  return trees
}

function main() {
  const trees = parseMerkleTrees()

  const distributionJson = []
  for (const [token, { values }] of Object.entries(trees)) {
    distributionJson.push({
      token,
      operators: values.map(([operator, reward]) => ({
        operator,
        reward,
      })),
    })
  }

  const fileName = 'data/distribution.json'
  const filePath = path.join(__dirname, fileName)

  fs.writeFileSync(filePath, JSON.stringify(distributionJson, null, 2))
  console.log(`Distribution written to ${fileName}`)
}

main()
