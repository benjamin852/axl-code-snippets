//link to: https://github.com/axelarnetwork/axelar-examples/blob/main/examples/evm/deposit-address/index.js

import { ethers } from 'hardhat';

import { AxelarAssetTransfer, AxelarQueryAPI, CHAINS, Environment } from '@axelar-network/axelarjs-sdk';

async function sendAsset(source: string, destination: string, destinationAddress: string, token: string) {
    const sdk = new AxelarAssetTransfer({
        environment: Environment.TESTNET,
        auth: 'local',
    });

    //temp deposit address
    const generateDepositAddr = await sdk.getDepositAddress(source, destination, destinationAddress, token);

    const connectedWallet = getWallet('<privateKey>', '<rpc>');

    const aUSDC = new ethers.Contract(
        chain.aUSDC,
        aUSDC.abi,
        connectedWallet
    );

    aUSDC.transfer(generateDepositAddr)

}

async function getWallet(privateKey: string, chainRpc: string) {
    const wallet = new ethers.Wallet(privateKey);

    const provider = ethers.getDefaultProvider(chainRpc);
    return wallet.connect(provider);

}