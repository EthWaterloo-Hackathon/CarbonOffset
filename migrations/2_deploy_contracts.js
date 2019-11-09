const GIFT                = artifacts.require("./GIFT.sol");
const BeneficiaryRegistry = artifacts.require("./BeneficiaryRegistry.sol");
const CarbonOffsetProgram = artifacts.require("./CarbonOffsetProgram.sol");

const config = require("../config");

module.exports = function (deployer, network, accounts) {
    deployer.then(async () => {
        let gift     = await deployer.deploy(GIFT, config.get("token:initialSupply"));
        let registry = await deployer.deploy(BeneficiaryRegistry);
        let driver   = await deployer.deploy(CarbonOffsetProgram, gift.address, registry.address);

        // Transfer all tokens to driver contract
        let totalSupply = await gift.totalSupply();
        await gift.transfer(driver.address, totalSupply);

        // Driver controls registry
        await registry.transferOwnership(driver.address);

        // let balance = await await gift.balanceOf(driver.address);
        // console.log(totalSupply.toString());
        // console.log(balance.toString());
    })
    .catch((err) => {
        console.error("Deployment failed", err);
    })
};