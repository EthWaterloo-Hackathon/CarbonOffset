pragma solidity ^0.5.0;

import "@openzeppelin/contracts/ownership/Ownable.sol";

/**
 * @dev Registry of beneficiaries who are eligible to receive payment in exchange for offsetting carbon emissions.
 */
contract BeneficiaryRegistry is Ownable {

    /// Registry
    mapping(bytes32 => Beneficiary) registry;

    /// stores keys separately
    bytes32[] ensIndex;

    /**
     * @dev A beneficiary entity working on a green project.
     */
    struct Beneficiary {
        /// Name
        bytes32 name;
        /// ETH is sent to this entity wallet
        address payable wallet;
        /// Used for membership check
        bool exists;
    }

    /*
     * Modifiers
     */

    modifier onlyNonZeroAddress(address _a) {
        require(_a != address(0x0));
        _;
    }


    /*
     * Events
     */

    /// A new beneficiary was added
    event LogBeneficiaryAdded(bytes32 indexed _ens, bytes32 name);


    /**
     * @dev Add a new beneficiary. Check if beneficiary exisits in storage. Do not
     * throw if beneficiary already exists.
     */
    function addBeneficiary(
        bytes32 _ens,
        bytes32 _name,
        address payable _wallet
    )
        public
        onlyOwner
        onlyNonZeroAddress(_wallet)
    {
        Beneficiary memory beneficiary = registry[_ens];

        // ENS was not found, add beneficiary as a new entry
        if (beneficiary.exists == false) {
            beneficiary.name = _name;
            beneficiary.wallet = _wallet;
            beneficiary.exists = true;

            registry[_ens] = beneficiary;
            ensIndex.push(_ens);
        }

        // Log event
        emit LogBeneficiaryAdded(_ens, _name);
    }

    /**
     * Return beneficiary information.
     */
    function getBeneficiary(
        bytes32 _ens
    )
        public
        view
        returns (bytes32 _name, address payable _wallet, bool _exists)
    {
        Beneficiary memory beneficiary = registry[_ens];

        _exists = beneficiary.exists;

        if (beneficiary.exists == true) {
            _name = beneficiary.name;
            _wallet = beneficiary.wallet;
        } else {
            _name = 0;
            _wallet = address(0x0);
        }
    }

    function getAllBeneficiaries() public view returns (bytes32[] memory _names, address[] memory _wallets, bytes32[] memory _ensAddresses) {
        bytes32 ens;
        Beneficiary memory beneficiary;
        for (uint i = 0; i < ensIndex.length; i++) {
            ens = ensIndex[i];
            beneficiary = registry[ens];
            _ensAddresses[i] = ens;
            _names[i] = beneficiary.name;
            _wallets[i] = beneficiary.wallet;
        }
    }
}
