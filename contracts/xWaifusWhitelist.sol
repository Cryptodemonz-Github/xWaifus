// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

/**
    @title xWaifus Whitelist Contract
    @notice This contract is used to process whitelist sales for xWaifus
    @dev whitelist is done using merkle root of the list of addresses

    for initial (spawn2) whitelist, user should burn X amount of LLTH to
    mint 1 xWaifus NFT

    for spawn1 and collab projects whitelists, users should pay X amount of
    ether to mint max 5 xWaifus NFTs
 */

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import "./mocks/xLLTH.sol";
import "./xWaifusERC721A.sol";

abstract contract xWaifusWhitelist is xWaifusERC721A {
    uint256 public SPAWN_WHITELIST_SUPPLY = 500;
    uint256 public COLLAB_WHITELIST_SUPPLY = 1000;

    uint256 public INITIAL_WHITELIST_PRICE = 500 * (10**18);
    uint256 public SPAWN_WHITELIST_PRICE = 0.2 ether;
    uint256 public COLLAB_WHITELIST_PRICE = 0.2 ether;

    uint256 public SPAWN_WHITELIST_MAX_PER_WALLET = 5;
    uint256 public COLLAB_WHITELIST_MAX_PER_WALLET = 5;

    bytes32 public INITIAL_WH_MERKLE_ROOT = 0x0;
    bytes32 public SPAWN_WH_MERKLE_ROOT = 0x0;
    bytes32 public COLLAB_WH_MERKLE_ROOT = 0x0;

    bool public INITIAL_WH_ENABLED = false;
    bool public SPAWN_WH_ENABLED = false;
    bool public COLLAB_WH_ENABLED = false;

    xLLTH public lilith;

    mapping(address => bool) public initialWhClaimed;
    mapping(address => uint256) public spawnWhClaimed;
    mapping(address => uint256) public collabWhClaimed;

    constructor(xLLTH _lilith) {
        lilith = _lilith;
    }

    /**
        @notice mint tokens for whitelist
        @param _mode 0 for spawn2, 1 for spawn1, 2 for collab projects
        @param _merkleProof merkle proof of the whitelisted addresses
        @param _amount amount of tokens to mint
     */
    function mint(
        uint8 _mode,
        bytes32[] calldata _merkleProof,
        uint256 _amount
    ) public {
        if (_mode == 1) {
            require(
                INITIAL_WH_ENABLED,
                "WH not allowed"
            );
            require(!initialWhClaimed[msg.sender], "Already claimed");
            bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
            require(
                MerkleProof.verify(_merkleProof, INITIAL_WH_MERKLE_ROOT, leaf),
                "Invalid merkle proof"
            );

            lilith.burn(msg.sender, INITIAL_WHITELIST_PRICE);
            super._safeMint(msg.sender, 1);
            initialWhClaimed[msg.sender] = true;
        } else if (_mode == 2) {
            require(
                SPAWN_WH_ENABLED,
                "WH not allowed"
            );
            require(
                spawnWhClaimed[msg.sender] + _amount <=
                    SPAWN_WHITELIST_MAX_PER_WALLET,
                "Too many waifus"
            );
            bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
            require(
                MerkleProof.verify(_merkleProof, SPAWN_WH_MERKLE_ROOT, leaf),
                "Invalid merkle proof"
            );
            super._safeMint(msg.sender, _amount);
            spawnWhClaimed[msg.sender] += _amount;
        } else if (_mode == 3) {
            require(
                COLLAB_WH_ENABLED,
                "WH not allowed"
            );
            require(
                collabWhClaimed[msg.sender] + _amount <=
                    SPAWN_WHITELIST_MAX_PER_WALLET,
                "Too many waifus"
            );
            bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
            require(
                MerkleProof.verify(_merkleProof, COLLAB_WH_MERKLE_ROOT, leaf),
                "Invalid merkle proof"
            );
            super._safeMint(msg.sender, _amount);
            collabWhClaimed[msg.sender] += _amount;
        }
    }

    /**
        @notice set the lilith token 
        @param _lilith the address of the lilith token
     */
    function setLlth(xLLTH _lilith) public onlyOwner {
        lilith = _lilith;
    }

    /**
        @notice set supply settings
        @param _mode 1 for spawn1, 2 for collab projects.
        spawn2 whitelist has no hardcoded supply since only certain
        amount of addresses can mint it and its fixed to 1 per wallet
     */
    function setSupply(uint8 _mode, uint256 _amount) public onlyOwner {
        if (_mode == 1) {
            SPAWN_WHITELIST_SUPPLY = _amount;
        } 
        else if (_mode == 2) {
            COLLAB_WHITELIST_SUPPLY = _amount;
        }
    }

    /**
        @notice set price settings
        @param _mode 1 for spawn1, 2 for collab projects.
        notice that for initial whitelist, the price is denoted in
        llth and not ether
     */
    function setPrices(uint8 _mode, uint256 _amount) public onlyOwner {
        if (_mode == 1) {
            INITIAL_WHITELIST_PRICE = _amount*(10**18);
        } 
        else if (_mode == 2) {
            SPAWN_WHITELIST_PRICE = _amount*(10**18);
        }
        else if (_mode == 3) {
            COLLAB_WHITELIST_PRICE = _amount*(10**18);
        }
    }

    /**
        @notice set max per wallet settings
        @param _mode 1 for spawn1, 2 for collab projects.
        notice that initial(spawn2) whitelist is fixed to 
        1 per wallet.
     */
    function setMaxPerWallet(uint8 _mode, uint256 _amount) public onlyOwner {
        if (_mode == 1) {
            SPAWN_WHITELIST_MAX_PER_WALLET = _amount;
        } 
        else if (_mode == 2) {
            COLLAB_WHITELIST_MAX_PER_WALLET = _amount;
        }
    }

    /**
        @notice set merkle roots
        @param _initialRoot merkle root of spawn2 whitelist
        @param _spawnRoot merkle root of spawn1 whitelist
        @param _collabRoot merkle root of collab projects whitelist
     */
    function setMerkleRoots(
        bytes32 _initialRoot,
        bytes32 _spawnRoot,
        bytes32 _collabRoot
    ) public onlyOwner {
        INITIAL_WH_MERKLE_ROOT = _initialRoot;
        SPAWN_WH_MERKLE_ROOT = _spawnRoot;
        COLLAB_WH_MERKLE_ROOT = _collabRoot;
    }

    /**
        @notice enable whitelists
        @param _mode 1 for spawn2, 2 for spawn1, 3 for collab 
        and 4 for all
     */
    function enable(uint8 _mode, bool _value) public onlyOwner {
        if (_mode == 1) {
            INITIAL_WH_ENABLED = _value;
        } 
        else if (_mode == 2) {
            SPAWN_WH_ENABLED = _value;
        }
        else if (_mode == 3) {
            COLLAB_WH_ENABLED = _value;
        }
        else if (_mode == 4) {
            INITIAL_WH_ENABLED = _value;
            SPAWN_WH_ENABLED = _value;
            COLLAB_WH_ENABLED = _value;
        }
    }
}
