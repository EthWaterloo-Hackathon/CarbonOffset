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

    uint public carbonEmissionsPerGasUnit;

    uint public totalContributions;

    uint public constant MIN_CONTRIBUTION = 1 ether;

    /**
     * Events
     */
    event GuiltAlleviated(uint indexed _tonnes, uint indexed _gas);

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
        uint rate = registry.getRate(_beneficiaryENS);

        uint purchased = contribution.div(rate) ** 18;
        uint gas = purchased.div(this.getCarbonEmissionsPerGasUnit());
        uint totalSold = totalContributions.add(contribution);

        totalContributions = totalSold;
        wallet.transfer(contribution);
        token.transfer(msg.sender, purchased);

        emit GuiltAlleviated(purchased, gas);

        return purchased;
    }

    /**
     * @dev Add a new beneficiary. Call is delegated to the registry.
     */
    function addBeneficiary(
        bytes32 _ens,
        bytes32 _name,
        address payable _wallet,
        bytes32 _rateApiUrl
    )
        public
        onlyOwner
    {
        registry.addBeneficiary(_ens, _name, _wallet, _rateApiUrl);
    }

    /**
     * @dev Carbon tonnage spent in terms of Ether produced.
     */
    function setCarbonEmissionsPerGasUnit(
        uint _rate
    )
        onlyOwner
        external returns (bool)
    {
        carbonEmissionsPerGasUnit = _rate;

        return true;
    }

    function getCarbonEmissionsPerGasUnit() external pure returns (uint _emissions) {
        // TODO: chainlink this mofo up
        _emissions = carbonEmissionsPergasUnit;
    }
}
