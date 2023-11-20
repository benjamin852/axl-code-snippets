// import { Wallet, getDefaultProvider } from "ethers"
import { ethers } from 'hardhat';
import MockERC20 from "../../artifacts/@openzeppelin/contracts/token/ERC20/IERC20.sol/IERC20.json";

async function main() {

    const privateKey = process.env.PRIVATE_KEY;

    const gatewayMumbai = '0xBF62ef1486468a6bd26Dd669C06db43dEd5B849B'
    const gasServiceMumbai = '0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6'


    if (!privateKey) throw new Error("Invalid private key. Make sure the PRIVATE_KEY environment variable is set.")

    const gameInterchain = await ethers.deployContract('InterchainGaming', [gatewayMumbai, gasServiceMumbai]);

    const wallet = new ethers.Wallet(privateKey);
    const connectedWallet = wallet.connect(ethers.provider);


    const aUSDC = new ethers.Contract(
        '0x2c852e740B62308c46DD29B982FBb650D063Bd07',
        MockERC20.abi,
        connectedWallet
    );
    // const wFTM = new ethers.Contract(
    //     '0x62b6F2A4eE6a4801bfcD2056d19c6d71654D2582',
    //     MockERC20.abi,
    //     connectedWallet
    // );

    await aUSDC.approve(gameInterchain.target, "1234567895");
    // await wFTM.approve(gameInterchain.address, "1234567895");

    console.log(`mumbai contract address: ${gameInterchain.target}`);

}


main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
