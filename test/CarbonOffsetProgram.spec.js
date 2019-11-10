/**
 * GIFT token scenarios.
 */
const GIFT                = artifacts.require("./GIFT.sol");
const BeneficiaryRegistry = artifacts.require("./BeneficiaryRegistry.sol");
const CarbonOffsetProgram = artifacts.require("./CarbonOffsetProgram.sol");

const BN       = require('bn.js');
const {assert} = require("chai");
const Web3     = require('web3');

const config = require("../config");

contract('Token API', (accounts) => {

    const [Owner, SaveEarth, Polluter] = accounts;

    before(async () => {
        this.driver = await CarbonOffsetProgram.deployed();
        this.gift   = await GIFT.deployed();
    });

    describe("Registry API", () => {

        it("should add a new beneficiary", async () => {
            await this.driver.setCarbonEmissionsPerGasUnit(1);

            let ens  = Web3.utils.utf8ToHex("saveearth.org");
            let name = "Save Earth Foundation";
            let apiUrl = "https://www.some-api.com";
            await this.driver.addBeneficiary(ens, Web3.utils.utf8ToHex(name), SaveEarth, Web3.utils.utf8ToHex(apiUrl));

            let registryAddr = await this.driver.registry.call();
            let registry     = await BeneficiaryRegistry.at(registryAddr);
            let result       = await registry.getBeneficiary(ens);

            assert.equal(name, Web3.utils.hexToUtf8(result._name));
            assert.equal(SaveEarth, result._wallet);
            assert.isTrue(result._exists);
        });

    });

    describe("Offset API", () => {

        it("should exchange GIFT for ETH", async () => {
            await this.driver.setCarbonEmissionsPerGasUnit(0.00000032*Math.pow(10, 18));

            let ens  = Web3.utils.utf8ToHex("saveearth.org");
            let name = "Save Earth Foundation";
            let apiUrl = "https://www.some-api.com";
            await this.driver.addBeneficiary(ens, Web3.utils.utf8ToHex(name), SaveEarth, Web3.utils.utf8ToHex(apiUrl));

            let registryAddr = await this.driver.registry.call();
            let registry     = await BeneficiaryRegistry.at(registryAddr);
            let beneficiary  = await registry.getBeneficiary(ens);
            let rate         = await registry.getRate(ens);

            assert.equal(name, Web3.utils.hexToUtf8(beneficiary._name));
            assert.equal(SaveEarth, beneficiary._wallet);
            assert.isTrue(beneficiary._exists);

            let balanceBefore = await this.gift.balanceOf.call(Polluter);
            let amountToSend  = Web3.utils.toWei("2", "ether");            
            let expectedTokens = new BN(amountToSend).div(rate).div(new BN(10).pow(new BN(18)));         

            await this.driver.offsetCarbonFootprint(ens, { from: Polluter, value: amountToSend });

            let balanceAfter = await this.gift.balanceOf.call(Polluter);

            assert.isTrue(balanceAfter.eq(balanceBefore.add(expectedTokens)));
        });

    });

});