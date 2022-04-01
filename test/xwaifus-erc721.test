const xWaifus = artifacts.require("xWaifusERC721A");

const truffleAssert = require("truffle-assertions");
const web3 = require("web3");

contract("xWaifus happy/sad tests", async (accounts) => {
  let waifus;
  const presalePrice = web3.utils.toWei("0.1", "ether");
  const publicPrice = web3.utils.toWei("0.2", "ether");

  beforeEach(async () => {
    waifus = await xWaifus.new();
  });

  it("should mint waifu thru presale", async () => {
    await waifus.toggleAllowances(2, true, { from: accounts[0] });
    await waifus.mint(2, 1, { from: accounts[1], value: presalePrice });

    await waifus.ownerOf(0).then((res) => {
      owner = res;
    });

    assert.equal(owner, accounts[1]);
  });

  it("should mint waifu thru public sale", async () => {
    await waifus.toggleAllowances(1, true, { from: accounts[0] });
    await waifus.mint(1, 1, { from: accounts[1], value: publicPrice });

    await waifus.ownerOf(0).then((res) => {
      owner = res;
    });

    assert.equal(owner, accounts[1]);
  });

  it("should revert if fee isn't paid", async () => {
    await waifus.toggleAllowances(2, true, { from: accounts[0] });
    await waifus.toggleAllowances(1, true, { from: accounts[0] });

    await truffleAssert.reverts(
      waifus.mint(1, 1, { from: accounts[1], value: 0 }),
      "Fee isn't paid"
    );
    await truffleAssert.reverts(
      waifus.mint(2, 1, { from: accounts[1], value: 0 }),
      "Fee isn't paid"
    );
  });

  it("should revert if user requests more than total supply", async () => {
    await waifus.toggleAllowances(2, true, { from: accounts[0] });
    await waifus.toggleAllowances(1, true, { from: accounts[0] });
    await waifus.setUint256(3, 6, { from: accounts[0] });

    await truffleAssert.reverts(
      waifus.mint(1, 11, { from: accounts[1], value: publicPrice * 11 }),
      "Total supply exceeds max supply"
    );

    await truffleAssert.reverts(
      waifus.mint(2, 6, { from: accounts[1], value: presalePrice * 6 }),
      "Total supply exceeds max supply"
    );
  });

  it("scenario where presale wasn't sold, so we move to public", async () => {
    await waifus.toggleAllowances(2, true, { from: accounts[0] });
    await waifus.mint(2, 1, { from: accounts[1], value: presalePrice });

    // presale failed, time to activate public sale

    await waifus.toggleAllowances(2, false, { from: accounts[0] });
    await waifus.toggleAllowances(1, true, { from: accounts[0] });

    await waifus.totalSupply().then((res) => {
      assert.equal(res, 1);
    });

    await waifus.mint(1, 9, { from: accounts[1], value: publicPrice * 9 });

    await truffleAssert.reverts(
      waifus.mint(1, 1, { from: accounts[1], value: publicPrice }),
      "Total supply exceeds max supply"
    );

    await waifus.totalSupply().then((res) => {
      assert.equal(res, 10);
    });
  });
});
