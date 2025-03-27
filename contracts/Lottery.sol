// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract MonthlyLottery {
    IERC20 public token;
    address public owner;
    uint256 public feePercent = 5;
    address[] public participants;
    uint256 public lotteryStart;
    uint256 public lotteryDuration = 30 days;

    event EnteredLottery(address indexed participant);
    event WinnerSelected(address indexed winner, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor(address tokenAddress) {
        require(tokenAddress != address(0), "Invalid token address");
        token = IERC20(tokenAddress);
        owner = msg.sender;
        lotteryStart = block.timestamp;
    }

    function enterLottery() external {
        require(token.transferFrom(msg.sender, address(this), 1 ether), "Token transfer failed");
        participants.push(msg.sender);
        emit EnteredLottery(msg.sender);
    }

    function selectWinner() external onlyOwner {
        require(block.timestamp >= lotteryStart + lotteryDuration, "Lottery still ongoing");
        require(participants.length > 0, "No participants");

        uint256 randomNumber = uint256(
            keccak256(
                abi.encodePacked(block.prevrandao, block.timestamp, participants.length)
            )
        );
        uint256 winnerIndex = randomNumber % participants.length;
        address winner = participants[winnerIndex];

        uint256 totalBalance = token.balanceOf(address(this));
        uint256 fee = (totalBalance * feePercent) / 100;
        uint256 prizeAmount = totalBalance - fee;

        require(token.transfer(owner, fee), "Fee transfer failed");
        require(token.transfer(winner, prizeAmount), "Prize transfer failed");

        emit WinnerSelected(winner, prizeAmount);

        delete participants;
        lotteryStart = block.timestamp;
    }

    function getParticipants() external view returns (address[] memory) {
        return participants;
    }
}
