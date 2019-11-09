pragma solidity ^0.5.0;

import "./GIFT.sol";
import "./BeneficiaryRegistry.sol";

/**
 * The driver program.
 */
contract CarbonOffsetProgram {

    GIFT public token;

    BeneficiaryRegistry public registry;



    /**
     * Initialize with token address and beneficiary registry.
     */
    constructor(address _token, address _registry) public {
        token = GIFT(_token);
        registry = BeneficiaryRegistry(_registry);
    }


    

}
