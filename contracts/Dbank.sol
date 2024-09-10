// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract DBank {

    struct Transaction {
        address to;
        string txType;
        uint256 amount;
        uint256 timestamp;
        address from;
    }

    struct Account {
        uint256 deposit;
        uint256 balance;
        uint256 lastDeposit;
        uint256 lastWithDraw;
        address accountHolder;
    }

    mapping(address => Account) public accounts;
    mapping(address => Transaction[]) public transactions;

    event Withdraw(address indexed account, uint256 amount);
    event Deposit(address indexed account, uint256 amount);
    event Transfer(address indexed from, uint256 amount, address indexed to);

    address public owner;

    modifier onlyOwner {
        require(owner == msg.sender, "It is the owner's contract");
        _;
    }

    constructor() {
        owner = msg.sender; // Set the owner to the address deploying the contract
    }

    // Deposit function for adding funds to an account
    function deposit() public payable {
        require(msg.value > 0, "Deposit must be greater than zero");

        // Update account information
        Account storage userAccount = accounts[msg.sender];
        userAccount.balance += msg.value;
        userAccount.deposit += msg.value;
        userAccount.lastDeposit = block.timestamp;

        // Log the transaction
        transactions[msg.sender].push(Transaction({
            to: address(this),
            txType: "Deposit",
            amount: msg.value,
            timestamp: block.timestamp,
            from: msg.sender
        }));

        // Emit deposit event
        emit Deposit(msg.sender, msg.value);
    }

    // Withdraw function to allow users to withdraw funds
    function withdraw(uint256 amount) public {
        Account storage userAccount = accounts[msg.sender];

        // Check if the user has enough balance
        require(userAccount.balance >= amount, "Insufficient balance");

        // Update account balance and last withdrawal time
        userAccount.balance -= amount;
        userAccount.lastWithDraw = block.timestamp;

        // Transfer the amount to the user
        payable(msg.sender).transfer(amount);

        // Log the transaction
        transactions[msg.sender].push(Transaction({
            to: msg.sender,
            txType: "Withdraw",
            amount: amount,
            timestamp: block.timestamp,
            from: address(this)
        }));

        // Emit the withdraw event
        emit Withdraw(msg.sender, amount);
    }

    // Transfer function to allow sending funds to another address
    function transfer(address to, uint256 amount) public {
        Account storage userAccount = accounts[msg.sender];

        // Ensure sender has enough balance
        require(userAccount.balance >= amount, "Insufficient balance");

        // Update sender and receiver balances
        userAccount.balance -= amount;
        accounts[to].balance += amount;

        // Log the transaction for both sender and receiver
        transactions[msg.sender].push(Transaction({
            to: to,
            txType: "Transfer",
            amount: amount,
            timestamp: block.timestamp,
            from: msg.sender
        }));

        transactions[to].push(Transaction({
            to: to,
            txType: "Transfer",
            amount: amount,
            timestamp: block.timestamp,
            from: msg.sender
        }));

        // Emit the transfer event
        emit Transfer(msg.sender, amount, to);
    }
}
