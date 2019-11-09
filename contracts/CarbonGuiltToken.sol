pragma solidity ^0.5.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";

/**
 * Client receives CarbonGuiltToken tokens in exchange for the ETH
 * they invest in green projects.
 */
contract CarbonGuiltToken is ERC20, ERC20Detailed {

    constructor(uint256 initialSupply) ERC20Detailed("CarbonGuilt", "CGT", 18) public {
        _mint(msg.sender, initialSupply);
    }
}