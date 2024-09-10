const DBank = artifacts.require("DBank");

module.exports = function (deployer, network, accounts) {
  // Deploy DBank contract
  deployer.deploy(DBank);
};
