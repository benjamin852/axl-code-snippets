// import { Wallet, getDefaultProvider } from "ethers"
import { ethers } from 'hardhat';

async function main() {

    const privateKey = process.env.PRIVATE_KEY;

    const gatewayFantom = '0x97837985Ec0494E7b9C71f5D3f9250188477ae14'
    const gasServiceFantom = '0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6'


    if (!privateKey) {
        throw new Error(
            "Invalid private key. Make sure the PRIVATE_KEY environment variable is set."
        );
    }

    const tokenAddr = '0xfF635D5316701a6dbdab4739371B3172862AbdBE' //>>mumbai addr for nft

    const wagerAmount = 6000000


    const nftCrosschain = await ethers.deployContract(
        'RockPaperScissors',
        [gatewayFantom, gasServiceFantom, wagerAmount]
    );

    console.log(
        `fantom contract address: ${nftCrosschain.target}`
    );

}


main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
