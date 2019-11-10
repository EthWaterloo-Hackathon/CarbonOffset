pragma solidity ^0.5.0;

import "@openzeppelin/contracts/ownership/Ownable.sol";
import "chainlink/v0.5/contracts/ChainlinkClient.sol";

contract CarbonEmissionConsumer is ChainlinkClient, Ownable {
    uint constant private ORACLE_PAYMENT = 1 * LINK;

    uint public avgMWhPerTx;
    uint public tCO2PerMWh;
    uint public avgGasPerTx;

    event RequestElectricityConsumptionFulfilled(bytes32 indexed requestId, uint indexed avgMWhPerTx);

    event RequestEmissionFactorFulfilled(bytes32 indexed requestId, uint indexed tCO2PerMWh);

    event RequestGasUsageFulfilled(bytes32 indexed requestId, uint indexed avgGasPerTx);

    constructor() public Ownable() {
        setPublicChainlinkToken();
    }

    function requestElectricityConsumption(address _oracle, string memory _jobId)
        public
        onlyOwner
    {
        Chainlink.Request memory req = buildChainlinkRequest(stringToBytes32(_jobId), address(this), this.fulfillElectricityConsumption.selector);
        req.add("get", "https://guarded-cliffs-86805.herokuapp.com/electricity-consumption");
        req.add("path", "result");
        req.addInt("times", (10 ** 18));
        sendChainlinkRequestTo(_oracle, req, ORACLE_PAYMENT);
    }

    function requestEmissionFactor(address _oracle, string memory _jobId)
        public
        onlyOwner
    {
        Chainlink.Request memory req = buildChainlinkRequest(stringToBytes32(_jobId), address(this), this.fulfillEmissionFactor.selector);
        req.add("get", "https://guarded-cliffs-86805.herokuapp.com/grid-emission-factor");
        req.add("path", "result");
        req.addInt("times", (10 ** 18));
        sendChainlinkRequestTo(_oracle, req, ORACLE_PAYMENT);
    }

    function requestGasUsage(address _oracle, string memory _jobId)
        public
        onlyOwner
    {
        Chainlink.Request memory req = buildChainlinkRequest(stringToBytes32(_jobId), address(this), this.fulfillGasUsage.selector);
        req.add("get", "https://guarded-cliffs-86805.herokuapp.com/gas-usage");
        req.add("path", "result");
        req.addInt("times", (10 ** 18));
        sendChainlinkRequestTo(_oracle, req, ORACLE_PAYMENT);
    }

    function fulfillElectricityConsumption(bytes32 _requestId, uint _avgMWhPerTx)
        public
        recordChainlinkFulfillment(_requestId)
    {
        emit RequestElectricityConsumptionFulfilled(_requestId, _avgMWhPerTx);
        avgMWhPerTx = _avgMWhPerTx;
    }

    function fulfillEmissionFactor(bytes32 _requestId, uint _tCO2PerMWh)
        public
        recordChainlinkFulfillment(_requestId)
    {
        emit RequestEmissionFactorFulfilled(_requestId, _tCO2PerMWh);
        tCO2PerMWh = _tCO2PerMWh;
    }

    function fulfillGasUsage(bytes32 _requestId, uint _avgGasPerTx)
        public
        recordChainlinkFulfillment(_requestId)
    {
        emit RequestGasUsageFulfilled(_requestId, _avgGasPerTx);
        avgGasPerTx = _avgGasPerTx;
    }

    function getChainlinkToken() public view returns (address) {
        return chainlinkTokenAddress();
    }

    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(link.transfer(msg.sender, link.balanceOf(address(this))), "Unable to transfer");
    }

    function cancelRequest(
        bytes32 _requestId,
        uint _payment,
        bytes4 _callbackFunctionId,
        uint _expiration
    )
        public
        onlyOwner
    {
        cancelChainlinkRequest(_requestId, _payment, _callbackFunctionId, _expiration);
    }

    function stringToBytes32(string memory source) private pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {// solhint-disable-line no-inline-assembly
            result := mload(add(source, 32))
        }
    }
}