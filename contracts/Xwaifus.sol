// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./mocks/xLLTH.sol";

contract xWaifus is ERC721Enumerable, Ownable {
    using Strings for uint256;

    uint256 MAX_TOKENS = 10000;
    uint256 PRICE = 0.1 ether;

    string public BEGINNING_URI = "";
    string public ENDING_URI = "";
    
    xLLTH public lilith;

    constructor(xLLTH _lilith) ERC721("xWaifus", "xWaifus") {
        lilith = _lilith;
    }

    function mint(uint256 _amount) public payable {
        require(msg.value > PRICE, "Fee isn't paid")
        require(
            totalSupply() + _amount <= MAX_TOKENS,
            "total supply exceeds max supply"
        );

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

    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function setURI(uint256 _mode, string memory _new_uri) external onlyOwner {
        if (_mode == 1) BEGINNING_URI = _new_uri;
        else if (_mode == 2) ENDING_URI = _new_uri;
    }

    function setMintingPrice(uint256 _value) external onlyOwner {
        PRICE = _value;
    }
}
