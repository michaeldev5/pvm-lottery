// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MonthlyLottery is ReentrancyGuard {
    IERC20 public immutable token;
    address public immutable owner;
    uint256 public constant FEE_PERCENT = 5;
    address[] private participants;
    uint256 public lotteryStart;
    uint256 public constant LOTTERY_DURATION = 30 days;

    event EnteredLottery(address indexed participant);
    event WinnerSelected(address indexed winner, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor(address tokenAddress) {
        require(tokenAddress != address(0), "Invalid token address");
        token = IERC20(tokenAddress);
        owner = msg.sender;
        lotteryStart = block.timestamp;
    }

    function enterLottery() external nonReentrant {
        require(token.transferFrom(msg.sender, address(this), 1 ether), "Token transfer failed");
        participants.push(msg.sender);
        emit EnteredLottery(msg.sender);
    }

    function selectWinner() external onlyOwner nonReentrant {
        require(block.timestamp >= lotteryStart + LOTTERY_DURATION, "Lottery ongoing");
        require(participants.length > 0, "No participants");

        uint256 randomNumber = uint256(
            keccak256(
                abi.encodePacked(block.prevrandao, block.timestamp, participants.length)
            )
        );
        uint256 winnerIndex = randomNumber % participants.length;
        address winner = participants[winnerIndex];

        uint256 totalBalance = token.balanceOf(address(this));
        uint256 fee = (totalBalance * FEE_PERCENT) / 100;
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
