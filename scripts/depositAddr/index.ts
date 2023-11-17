//link to: https://github.com/axelarnetwork/axelar-examples/blob/main/examples/evm/deposit-address/index.js

import { ethers } from 'hardhat';
import chains from '../../chains.json'
import { AxelarAssetTransfer, AxelarQueryAPI, CHAINS, Environment } from '@axelar-network/axelarjs-sdk';
import MockERC20 from "../artifacts/@openzeppelin/contracts/token/ERC20/IERC20.sol/IERC20.json";


async function sendAsset(source: string, destination: string, destinationAddress: string, token: string) {
    const sdk = new AxelarAssetTransfer({
        environment: Environment.TESTNET,
        auth: 'local',
    });

    //temp deposit address
    const generateDepositAddr = await sdk.getDepositAddress(source, destination, destinationAddress, token);

    const connectedWallet = getWallet('<privateKey>', '<rpc>');

    const aUSDCAddress = '0x2c852e740B62308c46DD29B982FBb650D063Bd07' //mumbai

    const aUSDC = new ethers.Contract(
        aUSDCAddress,
        MockERC20.abi,
        connectedWallet
    );

    aUSDC.transfer(generateDepositAddr)

}

async function getWallet(privateKey: string, chainRpc: string) {
    const wallet = new ethers.Wallet(privateKey);

    const provider = ethers.getDefaultProvider(chainRpc);
    return wallet.connect(provider);

}