pragma solidity ^0.5.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "./GIFT.sol";
import "./BeneficiaryRegistry.sol";
import "./CarbonEmissionConsumer.sol";

/**
 * The driver program.
 */
contract CarbonOffsetProgram is Ownable {
    using SafeMath for uint;

    GIFT public token;

    BeneficiaryRegistry public registry;

    CarbonEmissionConsumer public oracle;

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
    constructor(
        address _token,
        address _registry,
        address _oracle
    )
        public
    {
        token = GIFT(_token);
        registry = BeneficiaryRegistry(_registry);
        oracle = CarbonEmissionConsumer(_oracle);
    }

    /**
     * @dev Transfer ETH to a beneficiary and receive GIFT in exchange.
     * Returns the number of GIFT tokens purchased.
     */
    function offsetCarbonFootprint(bytes32 _beneficiaryENS)
        public payable
        returns (uint)
    {
        (bytes32 name, address payable wallet, uint giftPrice, bool exists) = registry.getBeneficiary(_beneficiaryENS);

        /// Beneficiary must exist.
        require(exists == true);

        /// Minimum amount to invest
        require(msg.value >= MIN_CONTRIBUTION);

        uint contribution = msg.value;

        uint purchased = contribution.div(giftPrice);
        uint gas = purchased.mul(10 ** 18).div(this.getCarbonEmissionsPerGasUnit());
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
        uint _giftPrice
    )
        public
        onlyOwner
    {
        registry.addBeneficiary(_ens, _name, _wallet, _giftPrice);
    }

    /**
     * @dev Carbon tonnage spent in terms of Ether produced.
     */
    function getCarbonEmissionsPerGasUnit()
        external view
        returns (uint _emissions)
    {
        uint avgMWhPerTx = oracle.avgMWhPerTx();
        uint tCO2PerMWh = oracle.tCO2PerMWh();
        uint avgGasPerTx = oracle.avgGasPerTx();

        _emissions = avgMWhPerTx.mul(tCO2PerMWh).div(avgGasPerTx);
    }
}
