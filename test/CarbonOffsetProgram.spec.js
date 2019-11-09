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
            await this.driver.setCarbonTonnagePerETH(1);

            let ens  = Web3.utils.utf8ToHex("saveearth.org");
            let name = "Save Earth Foundation";
            await this.driver.addBeneficiary(ens, Web3.utils.utf8ToHex(name), SaveEarth);

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
            await this.driver.setCarbonTonnagePerETH(1);

            let ens  = Web3.utils.utf8ToHex("saveearth.org");
            let name = "Save Earth Foundation";
            await this.driver.addBeneficiary(ens, Web3.utils.utf8ToHex(name), SaveEarth);

            let registryAddr = await this.driver.registry.call();
            let registry     = await BeneficiaryRegistry.at(registryAddr);
            let result       = await registry.getBeneficiary(ens);

            assert.equal(name, Web3.utils.hexToUtf8(result._name));
            assert.equal(SaveEarth, result._wallet);
            assert.isTrue(result._exists);

            let balanceBefore = await this.gift.balanceOf.call(Polluter);

            await this.driver.offsetCarbonFootprint(ens, {from: Polluter, value: Web3.utils.toWei("2", "ether")});

            let balanceAfter = await this.gift.balanceOf.call(Polluter);

            assert.isTrue(balanceAfter.eq(balanceBefore.add(new BN("2000000000000000000"))));
        });

    });

});