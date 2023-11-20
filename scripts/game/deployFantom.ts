// import { Wallet, getDefaultProvider } from "ethers"
import { ethers } from 'hardhat';

async function main() {

    const privateKey = process.env.PRIVATE_KEY;

    const gatewayFantom = '0x97837985Ec0494E7b9C71f5D3f9250188477ae14'
    const gasServiceFantom = '0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6'

    if (!privateKey) throw new Error("Invalid private key. Make sure the PRIVATE_KEY environment variable is set.")

    const gameInterchain = await ethers.deployContract('InterchainGaming', [gatewayFantom, gasServiceFantom]);

    console.log(`fantom contract address: ${gameInterchain.target}`);

}


main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
