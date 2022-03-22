const waifus = artifacts.require("xWaifusERC721A");
const whitelist = artifacts.require("xWaifusWhitelist");
const llth = artifacts.require("xLLTH");

const Web3 = require("web3");

/**
 * accounts[0] = owner
 * accounts[1] = user
 */

contract("xWaifus ERC721 Tests", async (accounts) => {
  let waifusInstance;
  let whitelistInstance;
  let llthInstance;

  beforeEach(async () => {
    llthInstance = await llth.new();
    waifusInstance = await waifus.new();
    whitelistInstance = await whitelist.new(llthInstance.address);

    const web3 = new Web3(
      new Web3.providers.HttpProvider("http://localhost:8545")
    );
    await llthInstance.mint(accounts[1], web3.utils.toWei("1000", "ether"));
  });

  it("Presale check", async () => {
    await waifusInstance.toggleAllowances(1, true, { from: accounts[0] });
    await waifusInstance.toggleAllowances(3, true, { from: accounts[0] });

    await waifusInstance.mint(2, 1, {
      from: accounts[1],
      value: web3.utils.toWei("0.1", "ether"),
    });

    let userbalance;
    await waifusInstance.balanceOf(accounts[1]).then((balance) => {
      userbalance = balance;
    });

    assert.equal(userbalance, 1, "User xWaifus balance must be 1");
  });
});
