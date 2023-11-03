// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {AxelarExecutable} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";
import {IAxelarGateway} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";
import {IAxelarGasService} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

contract InterchainDefi is AxelarExecutable {
    address public wethDestAddr = 0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa; //mumbai

    address public wethAddr = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6; //goerli
    address public uniAddr = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984; //goerli

    IAxelarGasService public immutable gasService;

    ISwapRouter public immutable swapRouter =
        ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);

    constructor(
        address _gateway,
        address _gasService
    ) AxelarExecutable(_gateway) {
        gasService = IAxelarGasService(_gasService);
    }

    function swapToken(
        string memory _destChain,
        string memory _destContractAddr,
        string memory _symbol, // "WETH"
        uint256 _amount
    ) external payable {
        require(msg.value > 0, "Gas payment required");

        uint24 poolFee = 3000;

        uint256 amount = 0.001 ether;

        // Transfer the specified amount of DAI to this contract.
        TransferHelper.safeTransferFrom(
            wethMumbai,
            msg.sender,
            address(this),
            amount
        );

        // Approve the router to spend DAI.
        TransferHelper.safeApprove(wethMumbai, address(swapRouter), amount);

        ISwapRouter.ExactInputSingleParams memory swapParams = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: wethAddr,
                tokenOut: uniAddr,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp + 1 days,
                amountIn: amount,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        //encode recipient addressess tx on destiantion chain
        bytes memory encodedSwapPayload = abi.encode(swapParams);

        gasService.payNativeGasForContractCallWithToken{value: msg.value}(
            address(this),
            _destChain,
            _destContractAddr,
            encodedSwapPayload,
            _symbol,
            _amount,
            msg.sender
        );

        gateway.callContractWithToken(
            _destChain,
            _destContractAddr,
            encodedSwapPayload,
            _symbol,
            _amount
        );
    }

    function _execute(
        string calldata,
        string calldata,
        bytes calldata _payload
    ) internal override {
        ISwapRouter.ExactInputSingleParams memory decodedGmpMessage = abi
            .decode(_payload, (ISwapRouter.ExactInputSingleParams));

        TransferHelper.safeApprove(
            wethDestAddr,
            address(swapRouter),
            decodedGmpMessage.amountIn
        );

        swapRouter.exactInputSingle(decodedGmpMessage);
    }
}
