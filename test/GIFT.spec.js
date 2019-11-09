/**
 * GIFT token scenarios.
 */
const GIFT                = artifacts.require("./GIFT.sol");
const CarbonOffsetProgram = artifacts.require("./CarbonOffsetProgram.sol");

const BN       = require('bn.js');
const {assert} = require("chai");
const Web3     = require('web3');

const config = require("../config");

contract('Token API', () => {

    before(async () => {
        this.driver = await CarbonOffsetProgram.deployed();
        this.gift   = await GIFT.deployed();
    });

    describe("Basic ERC20 properties", () => {

        it("should return GIFT as symbol", async () => {
            const symbol = await this.gift.symbol();
            assert.equal(symbol, 'GIFT');
        });

        it('should return 18 decimals', async () => {
            const decimals = await this.gift.decimals.call();
            assert.equal(decimals.toString(), "18");
        });

        it("should return 'Guilt Free Token' as name", async () => {
            const name = await this.gift.name.call();
            assert.equal(name, 'Guilt Free Token');
        });
    });

    describe('Balance allocations', () => {

        it("should report 1,000,000,000 GIFT as total supply", async () => {
            let total = await this.gift.totalSupply();
            assert.equal(Web3.utils.fromWei(total, "ether"), new BN(config.get("token:initialSupply")));
        });

        it('should report balance of driver contract as 1,000,000,000 GIFT', async () => {
            let total   = await this.gift.totalSupply();
            let balance = await this.gift.balanceOf(this.driver.address);
            assert.isTrue(balance.eq(total));
        });
    });
});