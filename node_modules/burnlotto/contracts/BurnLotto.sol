// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.18;

// Created by @tunnckoCore / @wgw_eth / wgw.eth

interface IERC20Burnable {
    function burn(uint256 value) external;

    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

error RoundOpened();
error RoundNotOpened();
error RoundPeriodTooLong();
error RoundPeriodTooShort();
error RoundTimeOver();
error RoundMaxEntriesExceeded();

contract BurnLotto {
    IERC20Burnable private _token;

    mapping(address => uint256) private depositsCount;
    mapping(address => uint256) private depositsAmount;
    mapping(uint256 => address) private roundWinner;
    address[] private allRoundWinners;
    address[] private depositors;

    bool private roundIsOpened;
    uint256 private roundId;
    uint256 private roundStartTime;
    uint256 private roundEndTime;

    bytes private deployerSignature;
    bytes[] private signaturesOfClosers;
    address private deployer = msg.sender;
    address private roundStarter;
    address private roundCloser;

    // PROD: uncomment when deploying
    event RoundStarted(
        address indexed creator,
        uint256 indexed roundStartTime,
        uint256 indexed period,
        uint256 roundId
    );

    // TEST: comment when deploying
    // event RoundStarted(
    //     address indexed creator,
    //     uint256 indexed period,
    //     uint256 roundId
    // );

    event RoundEntered(address indexed depositor, uint256 indexed amount);

    // PROD: uncomment when deploying
    event RoundEnded(
        address indexed winner,
        uint256 indexed tokensToWinner,
        uint256 indexed tokensToBurn,
        uint256 roundId,
        address roundCloser
    );

    // TEST: comment when deploying
    // event RoundEnded(
    //     uint256 indexed tokensToWinner,
    //     uint256 indexed tokensToBurn,
    //     uint256 roundId,
    //     address roundCloser
    // );

    constructor(address token, bytes memory signature) {
        _token = IERC20Burnable(token);
        deployerSignature = signature;
    }

    function startRound(uint256 period) external {
        if (roundIsOpened) {
            revert RoundOpened();
        }
        if (period > 10080) {
            revert RoundPeriodTooLong();
        }
        // PROD: uncomment when deploying
        if (period < 10) {
            revert RoundPeriodTooShort();
        }

        roundStartTime = block.timestamp;
        roundIsOpened = true;
        roundId += 1;
        roundStarter = msg.sender;

        // PROD: uncomment when deploying
        roundEndTime = roundStartTime + (period * 1 minutes);

        // TEST: comment when deploying
        // roundEndTime = roundStartTime + (period);

        // PROD: uncomment when deploying
        emit RoundStarted(roundStarter, roundStartTime, period, roundId);

        // TEST: comment when deploying
        // emit RoundStarted(roundStarter, period, roundId);
    }

    function enterRound(uint256 amount) external {
        if (!roundIsOpened) {
            revert RoundNotOpened();
        }
        if (block.timestamp > roundEndTime) {
            revert RoundTimeOver();
        }
        if (depositsCount[msg.sender] > 2) {
            revert RoundMaxEntriesExceeded();
        }

        depositors.push(msg.sender);
        depositsCount[msg.sender] += 1;
        depositsAmount[msg.sender] += amount;

        IERC20Burnable(_token).transferFrom(msg.sender, address(this), amount);

        emit RoundEntered(msg.sender, amount);
    }

    function endRound(
        uint256 percent,
        bytes memory signature
    ) external returns (address) {
        if (block.timestamp <= roundEndTime) {
            revert RoundOpened();
        }

        roundCloser = msg.sender;
        roundIsOpened = false;

        // Draw a winner randomly from the depositors array
        uint256 randomIdx = _getRandomUint(signature);
        address winner = depositors[randomIdx];

        allRoundWinners.push(winner);
        roundWinner[roundId] = winner;

        // Burn x% of the ERC-20 tokens that are deposited
        // the rest are transfered to the chosen winner
        uint256 deposited = IERC20Burnable(_token).balanceOf(address(this));
        uint256 tokensToBurn = (deposited / 100) * percent;
        uint256 tokensToWinner = deposited - tokensToBurn;

        // reset the state for the next round
        depositors = new address[](0);
        depositsCount[msg.sender] = 0;
        depositsAmount[msg.sender] = 0;

        IERC20Burnable(_token).burn(tokensToBurn);
        IERC20Burnable(_token).transfer(winner, tokensToWinner);

        // PROD: uncomment when deploying
        emit RoundEnded(
            winner,
            tokensToWinner,
            tokensToBurn,
            roundId,
            roundCloser
        );

        // TEST: comment when deploying
        // emit RoundEnded(tokensToWinner, tokensToBurn, roundId, roundCloser);

        return winner;
    }

    /**
     * View functions
     */

    function getTokenBalance() external view returns (uint256) {
        return IERC20Burnable(_token).balanceOf(address(this));
    }

    function getDepositors() external view returns (address[] memory) {
        return depositors;
    }

    function getDepositsCount(address player) external view returns (uint256) {
        return depositsCount[player];
    }

    function getDepositsAmount(address player) external view returns (uint256) {
        return depositsAmount[player];
    }

    function getRoundStartTime() external view returns (uint256) {
        return roundStartTime;
    }

    function getRoundEndTime() external view returns (uint256) {
        return roundEndTime;
    }

    function getRoundId() external view returns (uint256) {
        return roundId;
    }

    function getRoundWinner(uint256 _roundId) external view returns (address) {
        return roundWinner[_roundId];
    }

    function getAllWinners() external view returns (address[] memory) {
        return allRoundWinners;
    }

    function getRoundStarter() external view returns (address) {
        return roundStarter;
    }

    function getRoundCloser() external view returns (address) {
        return roundCloser;
    }

    function getDeployer() external view returns (address) {
        return deployer;
    }

    function isRoundStarted() external view returns (bool) {
        return roundIsOpened;
    }

    /**
     * Util functions
     */

    function _getRandomUint(
        bytes memory closerSignature
    ) internal view returns (uint) {
        uint randomNumber = uint(
            keccak256(
                abi.encode(
                    deployer,
                    closerSignature,
                    roundId,
                    msg.sender,
                    signaturesOfClosers,
                    allRoundWinners,
                    block.timestamp,
                    deployerSignature
                )
            )
        );

        return (randomNumber % depositors.length) - 1;
    }
}
