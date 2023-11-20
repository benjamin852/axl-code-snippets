// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {AxelarExecutable} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";
import {IAxelarGateway} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";
import {IAxelarGasService} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

//1. send WMATIC Goerli --> Mumbai
//2. swap WMATIC on Goerli to WETH

//https://testnet.axelarscan.io/gmp/0xf5abf4988691381d6b83e07e2cb45b96970fbfef361f327966e786b418492b79:19

//Mumbai -> Goerli
contract InterchainDefi is AxelarExecutable {
    address public wethGoerli = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6; //goerli
    address public wmaticGoerli = 0x21ba4f6aEdA155DD77Cc33Fb93646910543F0380; //goerli

    address public wethAddr = 0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa; //mumbai
    address public wmaticAddr = 0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889; //mumbai

    IAxelarGasService public immutable gasService;

    ISwapRouter public immutable swapRouter =
        ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);

    constructor(
        address _gateway,
        address _gasService
    ) AxelarExecutable(_gateway) {
        gasService = IAxelarGasService(_gasService);
    }

    function interchainSwap(
        string memory _destChain, // Polygon
        string memory _destContractAddr, //address(this)
        string memory _symbol // "WMATIC"
    ) external payable {
        require(msg.value > 0, "Gas payment required");

        uint24 poolFee = 3000;

        uint256 amount = 0.001 ether;

        // Transfer the specified amount of DAI to this contract.
        TransferHelper.safeTransferFrom(
            wmaticGoerli,
            msg.sender,
            address(this),
            amount
        );

        // Approve the router to spend DAI.
        TransferHelper.safeApprove(wmaticGoerli, address(gateway), amount);

        ISwapRouter.ExactInputSingleParams memory swapParams = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: wmaticAddr, //wmatic mumbai
                tokenOut: wethAddr, //weth mumbai
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp + 1 hours,
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
            _symbol, //WMATIC goerli
            amount,
            msg.sender
        );

        gateway.callContractWithToken(
            _destChain,
            _destContractAddr,
            encodedSwapPayload,
            _symbol, //WMATIC goerli
            amount
        );
    }

    function _executeWithToken(
        string calldata,
        string calldata,
        bytes calldata _payload,
        string calldata,
        uint256
    ) internal override {
        ISwapRouter.ExactInputSingleParams memory decodedGmpMessage = abi
            .decode(_payload, (ISwapRouter.ExactInputSingleParams));

        TransferHelper.safeApprove(
            wmaticAddr,
            address(swapRouter),
            decodedGmpMessage.amountIn
        );

        swapRouter.exactInputSingle(decodedGmpMessage);
    }
}
