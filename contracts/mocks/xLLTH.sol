//SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract xLLTH is ERC20, Ownable {
    mapping(address => bool) public managers;

    constructor() ERC20("Lilith", "LLTH") {
        _mint(owner(), 100000 * (10**18));
    }

    modifier managerOnly() {
        require(managers[msg.sender]);
        _;
    }

    function setManager(address manager, bool state) external onlyOwner {
        managers[manager] = state;
    }

    function mint(address user, uint256 amount) external onlyOwner {
        _mint(user, amount);
    }

    function burn(address user, uint256 amount) external {
        _burn(user, amount);
    }
}