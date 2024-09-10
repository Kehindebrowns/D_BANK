const DBANK = artifacts.require("Bank");
const { expect } = require("chai");

contract("DBANK", (accounts) => {
  let DBANK;
  const [owner, addr1, addr2] = accounts;

  beforeEach(async () => {
    DBANK = await DBANK.new({ from: owner });
  });

  it("should set the owner to the deployer", async () => {
    const contractOwner = await DBANK.owner();
    expect(contractOwner).to.equal(owner);
  });

  it("should allow deposits and update balances", async () => {
    // Deposit by addr1
    await DBANK.deposit({ from: addr1, value: web3.utils.toWei("1", "ether") });
    const balance1 = await bank.balances(addr1);
    expect(balance1.toString()).to.equal(web3.utils.toWei("1", "ether"));

    // Deposit by addr2
    await DBANK.deposit({ from: addr2, value: web3.utils.toWei("2", "ether") });
    const balance2 = await bank.balances(addr2);
    expect(balance2.toString()).to.equal(web3.utils.toWei("2", "ether"));
  });

  it("should allow withdrawals", async () => {
    // Deposit by addr1
    await DBANK.deposit({ from: addr1, value: web3.utils.toWei("1", "ether") });

    // Withdraw by addr1
    await DBANK.withdraw(web3.utils.toWei("0.5", "ether"), { from: addr1 });
    const balance = await DBANK.balances(addr1);
    expect(balance.toString()).to.equal(web3.utils.toWei("0.5", "ether"));
  });

  it("should allow transfers between accounts", async () => {
    // Deposit by addr1
    await DBANK.deposit({ from: addr1, value: web3.utils.toWei("1", "ether") });

    // Transfer to addr2
    await DBANK.transfer(addr2, web3.utils.toWei("0.5", "ether"), { from: addr1 });
    const balance1 = await bank.balances(addr1);
    const balance2 = await bank.balances(addr2);

    expect(balance1.toString()).to.equal(web3.utils.toWei("0.5", "ether"));
    expect(balance2.toString()).to.equal(web3.utils.toWei("0.5", "ether"));
  });
});
