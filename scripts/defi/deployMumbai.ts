// import { Wallet, getDefaultProvider } from "ethers"
import { ethers } from 'hardhat';
import { deployContract } from "@axelar-network/axelar-local-dev";

async function main() {

  const privateKey = process.env.PRIVATE_KEY;

  const gatewayMumbai = '0xBF62ef1486468a6bd26Dd669C06db43dEd5B849B'
  const gasServiceMumbai = '0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6'

  const swapRouterMumbai = '0xE592427A0AEce92De3Edee1F18E0157C05861564'

  if (!privateKey) {
    throw new Error(
      "Invalid private key. Make sure the PRIVATE_KEY environment variable is set."
    );
  }

  const tokenAddr = '0x30341a332C828A0462D03162CC52D6b48b2BFdE4'

  const defiCrosschain = await ethers.deployContract('InterchainDefi',
    [gatewayMumbai, gasServiceMumbai, swapRouterMumbai]
  );


  console.log(
    `mumbai contract address: ${defiCrosschain.target}`
  );

}


main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
