pragma solidity ^0.5.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";

/**
 * 1 tonne of carbon represents 1 GIFT. Client receives `GIFT`s in
 * exchange for the ETH they invest in green projects.
 */
contract GIFT is ERC20, ERC20Detailed, Ownable {

    constructor(uint256 initialSupply) ERC20Detailed("Guilt Free Token", "GIFT", 18) public {
        _mint(_msgSender(), initialSupply * (10 ** uint256(decimals())));
    }
}