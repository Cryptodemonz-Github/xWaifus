const xWaifus = artifacts.require("xWaifusERC721A");
const Whitelist = artifacts.require("xWaifusWhitelist");
const xLLTH = artifacts.require("xLLTH");

const truffleAssert = require("truffle-assertions");

const generateMerkleProof = ("./utils.js").generateMerkleProof;

contract("xWaifus whitelist happy/sad tests", async (accounts) => {
    let waifu;
    let whitelist;
    let llth;
    let initialWh = [];
    let spawnWh = [];
    let collabWh = [];

    beforeEach(async () => {
        llth = await xLLTH.new();
        waifu = await xWaifus.new();
        whitelist = await Whitelist.new(llth.address);
        
        for (let i = 0; i < accounts.length; i++) {}


        await whitelist.setMerkleRoots(

        )
    });


})