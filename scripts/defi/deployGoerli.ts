import { ethers } from 'hardhat';
import MockERC20 from '../../artifacts/@openzeppelin/contracts/token/ERC20/ERC20.sol/ERC20.json';
import { getWallet } from '../../utils/getWallet';
import chains from '../../chains.json'

async function main() {

    const privateKey = process.env.PRIVATE_KEY;

    const connectedWallet = getWallet(chains[2].rpc)

    const gatewayGoerli = '0xe432150cce91c13a887f7D836923d5597adD8E31'
    const gasServiceGoerli = '0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6'

    const swapRouterGoerli = '0xE592427A0AEce92De3Edee1F18E0157C05861564'
    if (!privateKey) throw new Error("Invalid private key. Make sure the PRIVATE_KEY environment variable is set.");


    const defiCrosschain = await ethers.deployContract(
        'InterchainDefi',
        [gatewayGoerli, gasServiceGoerli]
    );

    const wethAddr = '0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6'
    const wmaticAddr = '0x21ba4f6aEdA155DD77Cc33Fb93646910543F0380'

    // const mockERC20 = new ethers.Contract(wethAddr, MockERC20.abi, connectedWallet)
    const mockERC20 = new ethers.Contract(wmaticAddr, MockERC20.abi, connectedWallet)

    await mockERC20.approve(defiCrosschain.target, 1e18.toString())

    console.log(
        `goerli contract address: ${defiCrosschain.target}`
    );

}


main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
