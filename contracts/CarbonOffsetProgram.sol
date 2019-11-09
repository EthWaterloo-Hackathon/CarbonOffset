pragma solidity ^0.5.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "./GIFT.sol";
import "./BeneficiaryRegistry.sol";

/**
 * The driver program.
 */
contract CarbonOffsetProgram is Ownable {
    using SafeMath for uint;

    GIFT public token;

    BeneficiaryRegistry public registry;

    uint public carbonTonnagePerETH;

    uint public ethOffset;

    uint public constant MIN_CONTRIBUTION = 1 ether;

    /**
     * @dev Initialize with token address and beneficiary registry.
     */
    constructor(address _token, address _registry) public {
        token = GIFT(_token);
        registry = BeneficiaryRegistry(_registry);
    }

    /**
     * @dev Transfer ETH to a beneficiary and receive GIFT in exchange.
     * Returns the number of GIFT tokens purchased.
     */
    function offsetCarbonFootprint(bytes32 _beneficiaryENS)
        public payable
        returns (uint)
    {
        (bytes32 name, address payable wallet, bool exists) = registry.getBeneficiary(_beneficiaryENS);

        /// Beneficiary must exist.
        require(exists == true);

        /// Minimum amount to invest
        require(msg.value >= MIN_CONTRIBUTION);

        uint contribution = msg.value;
        uint purchased = contribution.mul(carbonTonnagePerETH);
        uint totalSold = ethOffset.add(contribution);

        ethOffset = totalSold;
        wallet.transfer(contribution);
        token.transfer(msg.sender, purchased);

        return purchased;
    }

    /**
     * @dev Add a new beneficiary. Call is delegated to the registry.
     */
    function addBeneficiary(
        bytes32 _ens,
        bytes32 _name,
        address payable _wallet
    )
        public
        onlyOwner
    {
        registry.addBeneficiary(_ens, _name, _wallet);
    }

    /**
     * @dev Carbon tonnage spent in terms of Ether produced.
     */
    function setCarbonTonnagePerETH(
        uint _rate
    )
        onlyOwner
        external returns (bool)
    {
        carbonTonnagePerETH = _rate;

        return true;
    }

}
