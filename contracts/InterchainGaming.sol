// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {AxelarExecutable} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";
import {IAxelarGateway} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";
import {IAxelarGasService} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";

contract RockPaperScissors {
    address public player1;
    address public player2;

    enum Move {
        Rock,
        Paper,
        Scissors
    }

    struct Choice {
        address player;
        Move move;
    }

    Choice public choice1;
    Choice public choice2;

    bool public gameCompleted;
    address public winner;

    uint256 wager;

    constructor(uint256 _wager) {
        player1 = msg.sender;
        wager = _wager;
    }

    function joinGame() public {
        require(player2 == address(0), "Game is already full.");
        player2 = msg.sender;
    }

    function makeChoice(Move _move) public {
        require(
            msg.sender == player1 || msg.sender == player2,
            "You are not a participant."
        );
        require(!gameCompleted, "Game is already completed.");

        Choice storage currentChoice = (msg.sender == player1)
            ? choice1
            : choice2;

        require(
            _move == Move.Rock || _move == Move.Paper || _move == Move.Scissors,
            "Invalid choice."
        );

        currentChoice.player = msg.sender;
        currentChoice.move = _move;

        if (choice1.player != address(0) && choice2.player != address(0)) {
            determineWinner();
        }

        // call contract with token to send gmp message with token
        gasService.payNativeGasForContractCallWithToken{value: msg.value}(
            address(this),
            _destChain,
            _destContractAddr,
            recipientAddressEncoded,
            _symbol,
            _amount,
            msg.sender
        );

        gateway.callContractWithToken(
            _destChain,
            _destContractAddr,
            recipientAddressEncoded,
            _symbol,
            _amount
        );
    }

    function determineWinner() internal {
        require(!gameCompleted, "Game is already completed.");
        if (choice1.move == choice2.move) {
            winner = address(0); // It's a draw
        } else if (
            (choice1.move == Move.Rock && choice2.move == Move.Scissors) ||
            (choice1.move == Move.Paper && choice2.move == Move.Rock) ||
            (choice1.move == Move.Scissors && choice2.move == Move.Paper)
        ) {
            winner = choice1.player;
        } else {
            winner = choice2.player;
        }

        //pay winner
        gameCompleted = true;
    }
}
