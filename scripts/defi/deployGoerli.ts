import { ethers } from 'hardhat';

async function main() {

    const privateKey = process.env.PRIVATE_KEY;

    const gatewayGoerli = '0xe432150cce91c13a887f7D836923d5597adD8E31'
    const gasServiceGoerli = '0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6'

    const swapRouterGoerli = '0xE592427A0AEce92De3Edee1F18E0157C05861564'
    if (!privateKey) throw new Error("Invalid private key. Make sure the PRIVATE_KEY environment variable is set.");


    const defiCrosschain = await ethers.deployContract(
        'InterchainDefi',
        [gatewayGoerli, gasServiceGoerli, swapRouterGoerli]
    );

    console.log(
        `goerli contract address: ${defiCrosschain.target}`
    );

}


main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
