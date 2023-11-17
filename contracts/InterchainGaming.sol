// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {AxelarExecutable} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";
import {IAxelarGateway} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";
import {IAxelarGasService} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";

//interchain bet --> more assets, extra logic to cheaper chains, increase pool of players
//option 2 all logic on chain A. only send winner to chain B and payout winner there
contract RockPaperScissors is AxelarExecutable {
    address public player1;
    address public player2;

    IAxelarGasService public immutable gasService;

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

    uint256 public wager;
    uint256 public pot;

    //BUG: Assumes address with playerOne deploys on both chains
    constructor(
        address _gateway,
        address _gasService,
        uint256 _wager
    ) AxelarExecutable(_gateway) {
        gasService = IAxelarGasService(_gasService);
        player1 = msg.sender;
        wager = _wager;
    }

    function joinGame() public {
        require(player2 == address(0), "Game is already full.");
        player2 = msg.sender;
    }

    function makeChoice(
        string memory _destChain,
        string memory _destContractAddr,
        string memory _symbol,
        uint256 _amount,
        Move _move
    ) public payable {
        require(
            msg.sender == player1 || msg.sender == player2,
            "You are not a participant."
        );
        require(!gameCompleted, "Game is already completed.");
        require(wager == _amount, "invalid amount");

        Choice memory currentChoice = (msg.sender == player1)
            ? choice1
            : choice2;

        require(
            _move == Move.Rock || _move == Move.Paper || _move == Move.Scissors,
            "Invalid choice."
        );

        // currentChoice.player = msg.sender;
        // currentChoice.move = _move;

        //SEND TOKEN FROM MY ADDRESS TO THIS CONTRACT
        address tokenAddress = gateway.tokenAddresses(_symbol);

        IERC20(tokenAddress).transferFrom(msg.sender, address(this), _amount);
        IERC20(tokenAddress).approve(address(gateway), _amount);

        bytes memory encodedBetPayload = abi.encode(currentChoice);

        // call contract with token to send gmp message with token
        gasService.payNativeGasForContractCallWithToken{value: msg.value}(
            address(this),
            _destChain,
            _destContractAddr,
            encodedBetPayload,
            _symbol,
            _amount,
            msg.sender
        );

        gateway.callContractWithToken(
            _destChain,
            _destContractAddr,
            encodedBetPayload,
            _symbol,
            _amount
        );
    }

    // function determineWinner() internal {
    function _executeWithToken(
        string calldata,
        string calldata,
        bytes calldata _payload,
        string calldata _symbol,
        uint256 _amount
    ) internal override {
        require(!gameCompleted, "Game is already completed.");

        Choice memory decodedGmpMessage = abi.decode(_payload, (Choice));

        pot += _amount;

        Choice storage currentChoice = (decodedGmpMessage.player == player1)
            ? choice1
            : choice2;

        currentChoice.player = msg.sender;
        currentChoice.move = decodedGmpMessage.move;

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

        address tokenAddress = gateway.tokenAddresses(_symbol);

        IERC20(tokenAddress).transfer(winner, pot);
    }
}
