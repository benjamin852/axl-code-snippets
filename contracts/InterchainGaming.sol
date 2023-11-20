// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {AxelarExecutable} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";
import {IAxelarGateway} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";
import {IAxelarGasService} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";

contract InterchainGaming is AxelarExecutable {
    uint256 public lastRoll;
    uint256 public lastBetAmount;
    address public lastPlayer;
    address public lastWinner;

    address[] public uniqueTokens;

    IAxelarGasService public immutable gasService;

    constructor(
        address _gateway,
        address _gasService
    ) AxelarExecutable(_gateway) {
        gasService = IAxelarGasService(_gasService);
    }

    function rollDice(
        string memory _destChain,
        string memory _destContractAddr,
        uint256 _guess,
        string memory _symbol,
        uint256 _amount
    ) external payable {
        require(_guess >= 1 && _guess <= 6, "Guess must be between 1 and 6");
        require(msg.value > 0, "Insufficient gas");

        bytes memory encodedBetPayload = abi.encode(msg.sender, _guess);

        address tokenAddress = gateway.tokenAddresses(_symbol);

        //send funds to this contract
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), _amount);

        //approve gateway to spend funds
        IERC20(tokenAddress).approve(address(gateway), _amount);

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

    function _executeWithToken(
        string calldata,
        string calldata,
        bytes calldata _payload,
        string calldata _symbol,
        uint256 _amount
    ) internal override {
        (address player, uint256 guess) = abi.decode(
            _payload,
            (address, uint256)
        );

        address tokenAddress = gateway.tokenAddresses(_symbol);

        _addUniqueTokenAddress(tokenAddress);

        uint256 diceResult = (block.timestamp % 6) + 1;

        bool won = guess == diceResult;

        lastRoll = diceResult;
        lastBetAmount = _amount;
        lastPlayer = player;

        if (won) {
            _payOutAllTokensToWinner(player);
        }
    }

    function _addUniqueTokenAddress(address tokenAddress) internal {
        bool found = false;

        for (uint256 i = 0; i < uniqueTokens.length; i++) {
            if (uniqueTokens[i] == tokenAddress) {
                found = true;
                break;
            }
        }
        if (!found) {
            uniqueTokens.push(tokenAddress);
        }
    }

    function _payOutAllTokensToWinner(address _player) internal {
        lastWinner = _player;

        for (uint256 i = 0; i < uniqueTokens.length; i++) {
            address token = uniqueTokens[i];
            uint256 transferAmount = IERC20(token).balanceOf(address(this));
            IERC20(token).transfer(_player, transferAmount);
        }
    }
}
