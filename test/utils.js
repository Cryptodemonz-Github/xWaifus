const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");

const generateMerkleProof = (addresses, address) => {
  const leaf = [];

  addresses.map((e) => {
    leaf.push(keccak256(e));
  });
  const merkle = new MerkleTree(leaf, keccak256, { sortPairs: true });

  const hexProof = merkle.getHexProof(keccak256(address));

  return hexProof;
};

export default { generateMerkleProof }