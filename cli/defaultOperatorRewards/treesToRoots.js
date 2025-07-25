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
    const tree = StandardMerkleTree.load(tokenData.tree)
    trees[tokenData.token] = { tree, values }
  })

  return trees
}

function main() {
  const trees = parseMerkleTrees()

  for (const [token, { tree }] of Object.entries(trees)) {
    console.log(`-------------------------------`)
    console.log(`Token: ${token}`)
    console.log(`Merkle Root: ${tree.root}`)
  }
}

main()
