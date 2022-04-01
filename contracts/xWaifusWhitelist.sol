// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import "./mocks/xLLTH.sol";
import "./xWaifusERC721A.sol";

contract xWaifusWhitelist is xWaifusERC721A {
    uint256 public PUBLIC_WH_SUPPLY = 1500;

    uint256 public SNAPSHOT_WH_PRICE = 500 * (10**18);
    uint256 public PUBLIC_WH_PRICE = 0.2 ether;

    uint256 public PUBLIC_WH_MAX_PER_WALLET = 3;

    bytes32 public SNAPSHOT_WH_MERKLE_ROOT = 0x0;
    bytes32 public PUBLIC_WH_MERKLE_ROOT = 0x0;

    bool public SNAPSHOT_WH_ENABLED = false;
    bool public PUBLIC_WH_ENABLED = false;

    xLLTH public lilith;

    mapping(address => bool) public snapshotWhClaimed;
    mapping(address => uint256) public publicWhClaimed;

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
            require(SNAPSHOT_WH_ENABLED, "WH not allowed");
            require(!snapshotWhClaimed[msg.sender], "Already claimed");
            bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
            require(
                MerkleProof.verify(_merkleProof, SNAPSHOT_WH_MERKLE_ROOT, leaf),
                "Invalid merkle proof"
            );

            lilith.burn(msg.sender, SNAPSHOT_WH_PRICE);
            super._safeMint(msg.sender, 1);
            snapshotWhClaimed[msg.sender] = true;
        } else if (_mode == 2) {
            require(PUBLIC_WH_ENABLED, "WH not allowed");
            require(
                publicWhClaimed[msg.sender] + _amount <=
                    PUBLIC_WH_MAX_PER_WALLET,
                "Too many waifus"
            );
            bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
            require(
                MerkleProof.verify(_merkleProof, PUBLIC_WH_MERKLE_ROOT, leaf),
                "Invalid merkle proof"
            );
            super._safeMint(msg.sender, _amount);
            publicWhClaimed[msg.sender] += _amount;
        } 
    }

    /**
        @notice set the lilith token 
        @param _lilith the address of the lilith token
     */
    function setLlth(xLLTH _lilith) public onlyOwner {
        lilith = _lilith;
    }

    function setPublicWhSupply(uint256 _amount) public onlyOwner {
        PUBLIC_WH_SUPPLY = _amount;
    }

    function setPrices(uint8 _mode, uint256 _amount) public onlyOwner {
        if (_mode == 1) {
            SNAPSHOT_WH_PRICE = _amount * (10**18);
        } else if (_mode == 2) {
            PUBLIC_WH_PRICE = _amount * (10**18);
        } else revert("Invalid mode");
    }

    function setMaxPerWallet(uint256 _amount) public onlyOwner {
        PUBLIC_WH_MAX_PER_WALLET = _amount;
    }

    function setMerkleRoot(uint8 _mode, bytes32 _root) public onlyOwner {
        if (_mode == 1) {
            SNAPSHOT_WH_MERKLE_ROOT = _root;
        } else if (_mode == 2) {
            PUBLIC_WH_MERKLE_ROOT = _root;
        } else revert("Invalid mode");
    }

    function enableWhs(uint8 _mode, bool _value) public onlyOwner {
        if (_mode == 1) {
            SNAPSHOT_WH_ENABLED = _value;
        } else if (_mode == 2) {
            PUBLIC_WH_ENABLED = _value;
        } else revert("Invalid mode");
    }
}
