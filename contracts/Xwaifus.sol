// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./mocks/xLLTH.sol";

contract xWaifus is ERC721Enumerable, Ownable {
    using Strings for uint256;

    uint256 PUBLIC_SALE_SUPPLY = 8000;
    uint256 PRESALE_SUPPLY = 2000;

    uint256 PUBLIC_SALE_PRICE = 0.1 ether;
    uint256 PRESALE_PRICE = 0.05 ether;

    bool MINTING_ALLOWED = false;
    bool PRESALE_ALLOWED = true;

    string public BEGINNING_URI = "";
    string public ENDING_URI = "";
    
    xLLTH public lilith;

    constructor(xLLTH _lilith) ERC721("xWaifus", "xWaifus") {
        lilith = _lilith;
    }

    function mint(uint8 _mode, uint256 _amount) public payable {
        if (_mode == 1) {
            require(MINTING_ALLOWED && PRESALE_ALLOWED, "Either minting or presale isn't allowed");
            require(msg.value >= PUBLIC_SALE_PRICE, "Fee isn't paid");
            require(
                totalSupply() + _amount <= PUBLIC_SALE_SUPPLY,
                "Total supply exceeds max supply"
            );
        }

        else if (_mode == 2) {
            require(MINTING_ALLOWED && !PRESALE_ALLOWED, "Either minting or public sale isn't allowed");
            require(msg.value >= PRESALE_PRICE, "Fee isn't paid");
            require(
                totalSupply() + _amount <= PRESALE_SUPPLY,
                "Total Supply exceeds max supply"
            );
        }

        for (uint256 i = 0; i < _amount; i++) {
            _safeMint(msg.sender, totalSupply());
        }
    }

    function burnToken(uint256 _token_id) external {
        require(ownerOf(_token_id) == msg.sender, "Sender is not owner");
        _burn(_token_id);
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

    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function setURI(uint256 _mode, string memory _new_uri) public onlyOwner {
        if (_mode == 1) BEGINNING_URI = _new_uri;
        else ENDING_URI = _new_uri;
    }

    function setPrices(uint8 _mode, uint256 _value) public onlyOwner {
        if (_mode == 1) PUBLIC_SALE_PRICE = _value;
        else PRESALE_PRICE = _value;
    }

    function toggleAllowance(uint8 _mode) public onlyOwner {
        if (_mode == 1) MINTING_ALLOWED = !MINTING_ALLOWED;
        else PRESALE_ALLOWED = !PRESALE_ALLOWED;
    }


    function changeSupply(uint8 _mode, uint256 _value) public onlyOwner {
        if (_mode == 1) PUBLIC_SALE_SUPPLY = _value;
        else PRESALE_SUPPLY = _value;
    }
}
