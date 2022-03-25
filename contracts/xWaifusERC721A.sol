// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

/**
    @title xWaifus NFT contract
 */

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "erc721a/contracts/ERC721A.sol";
import "erc721a/contracts/extensions/ERC721ABurnable.sol";

contract xWaifusERC721A is ERC721A, ERC721ABurnable, Ownable {
    using Strings for uint256;

    // for testing purposes
    // real values are:
    // total supply = 6666
    // presale supply = 666
    uint256 public constant TOTAL_SUPPLY = 10;
    uint256 public constant PRESALE_SUPPLY = 5;

    uint256 public PUBLIC_SALE_PRICE = 0.2 ether;
    uint256 public PRESALE_PRICE = 0.1 ether;

    uint256 public PRESALE_MAX_PER_WALLET = 1;

    bool public MINTING_ALLOWED = false;
    bool public PUBLIC_MINTING_ALLOWED = false;
    bool public PRESALE_ALLOWED = false;

    string public BEGINNING_URI = "";
    string public ENDING_URI = "";

    constructor() ERC721A("xWaifus", "xWaifus") {}

    /**
        @notice mint tokens
        @param _mode 1 for public minting, 2 for presale minting
        @param _amount amount of tokens to mint
     */
    function mint(uint8 _mode, uint256 _amount) public payable {
        require(MINTING_ALLOWED, "Minting isn't allowed");
        if (_mode == 1) {
            require(
                PUBLIC_MINTING_ALLOWED,
                "Public sale is not allowed"
            );
            require(msg.value >= PUBLIC_SALE_PRICE * _amount, "Fee isn't paid");
            require(
                _totalMinted() + _amount <= TOTAL_SUPPLY,
                "Total supply exceeds max supply"
            );

            _safeMint(msg.sender, _amount);
        } else if (_mode == 2) {
            require(
                balanceOf(msg.sender) + _amount <= PRESALE_MAX_PER_WALLET,
                "Too many waifus"
            );
            require(
                PRESALE_ALLOWED,
                "Presale is not allowed"
            );
            require(msg.value >= PRESALE_PRICE  * _amount, "Fee isn't paid");
            require(
                _totalMinted() + _amount <= PRESALE_SUPPLY,
                "Total supply exceeds max supply"
            );

            _safeMint(msg.sender, _amount);
        }
    }

    /**
        @notice proper way to burn tokens
        @param _token_id token id to burn
     */
    function burnToken(uint256 _token_id) public {
        burn(_token_id);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(BEGINNING_URI, tokenId.toString(), ENDING_URI)
            );
    }

    /**
        @notice withdraw ether from contract
     */
    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    /**
        @notice set tokenURI
        @param _mode 1 for BEGINNING_URI and 2 for ENDING_URI
     */
    function setURI(uint256 _mode, string memory _new_uri) public onlyOwner {
        if (_mode == 1) BEGINNING_URI = _new_uri;
        else if (_mode == 2) ENDING_URI = _new_uri;
    }

    /**
        @notice set uint256 info
        @param _mode 1 for public sale price, 2 for presale price and
        3 for max number of tokens per wallet during presale
     */
    function setUint256(uint8 _mode, uint256 _value) public onlyOwner {
        if (_mode == 1) PUBLIC_SALE_PRICE = _value * (10**18);
        else if (_mode == 2) PRESALE_PRICE = _value * (10**18);
        else if (_mode == 3) PRESALE_MAX_PER_WALLET = _value;
    }

    /**
        @notice enable minting
        @param _mode 1 for if minting is allowed,
        2 for if public minting is allowed, 3 for
        presale and 4 for all
        @param _value allowed or not allowed
     */
    function toggleAllowances(uint8 _mode, bool _value) public onlyOwner {
        if (_mode == 1) MINTING_ALLOWED = _value;
        else if (_mode == 2) PUBLIC_MINTING_ALLOWED = _value;
        else if (_mode == 3) PRESALE_ALLOWED = _value;
        else if (_mode == 4) {
            MINTING_ALLOWED = _value;
            PUBLIC_MINTING_ALLOWED = _value;
            PRESALE_ALLOWED = _value;
        }
    }
}
