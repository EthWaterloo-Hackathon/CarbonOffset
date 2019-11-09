const CarbonGuiltToken = artifacts.require("CarbonGuiltToken.sol");

const config = require("../config");
const fs = require("fs");

console.log(config.get("token:initialSupply"))

let token;

module.exports = function (deployer, network, accounts) {
    deployer.then(async () => {
            token = await deployer.deploy(CarbonGuiltToken, config.get("token:initialSupply"));
        })
        .catch((err) => {
            console.error("Deployment failed", err);
        })
};