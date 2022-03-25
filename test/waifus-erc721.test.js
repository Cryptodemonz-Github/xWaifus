const waifus = artifacts.require("xWaifusERC721A");
const whitelist = artifacts.require("xWaifusWhitelist");
const llth = artifacts.require("xLLTH");

const truffleAssert = require("truffle-assertions");

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

  it("Presale checks - v1", async () => {
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

    await waifusInstance.setUint256(3, 6, { from: accounts[0] });

    await truffleAssert.fails(
      waifusInstance.mint(2, 2, { from: accounts[1], value: web3.utils.toWei("0.1", "ether") }),
      truffleAssert.ErrorType.REVERT,
      "Fee isn't paid"
    );
  });

  it("Presale checks - v2", async () => {
    await truffleAssert.fails(
      waifusInstance.mint(2, 1, { from: accounts[1], value: web3.utils.toWei("0.2", "ether") }),
      truffleAssert.ErrorType.REVERT,
      "Minting isn't allowed"
  );

    await waifusInstance.toggleAllowances(1, true, { from: accounts[0] });
    await waifusInstance.toggleAllowances(3, true, { from: accounts[0] });

    await truffleAssert.fails(
        waifusInstance.mint(2, 2, { from: accounts[1], value: web3.utils.toWei("0.2", "ether") }),
        truffleAssert.ErrorType.REVERT,
        "Too many waifus"
    );

    await truffleAssert.fails(
        waifusInstance.mint(2, 1, { from: accounts[1], value: web3.utils.toWei("0.01", "ether") }),
        truffleAssert.ErrorType.REVERT,
        "Fee isn't paid"
    );

    await waifusInstance.setUint256(3, 6, { from: accounts[0] });

    await truffleAssert.fails(
        waifusInstance.mint(2, 6, { from: accounts[1], value: web3.utils.toWei("0.6", "ether") }),
        truffleAssert.ErrorType.REVERT,
        "Total supply exceeds max supply"
    );
  });

  it("Public sale checks - v1", async () => {
    await waifusInstance.toggleAllowances(1, true, { from: accounts[0] });
    await waifusInstance.toggleAllowances(2, true, { from: accounts[0] });

    await waifusInstance.mint(1, 1, {
      from: accounts[1],
      value: web3.utils.toWei("0.2", "ether"),
    });

    await waifusInstance.mint(1, 3, {
      from: accounts[1],
      value: web3.utils.toWei("0.6", "ether"),
    });

    let userbalance;
    await waifusInstance.balanceOf(accounts[1]).then((balance) => {
      userbalance = balance;
    });

    assert.equal(userbalance, 4, "User xWaifus balance must be 4");

    await truffleAssert.fails(
      waifusInstance.mint(2, 3, { from: accounts[1], value: web3.utils.toWei("0.1", "ether") }),
      truffleAssert.ErrorType.REVERT
  );
  });
});
