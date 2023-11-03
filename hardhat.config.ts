import dotenv from 'dotenv'
import { HardhatUserConfig } from 'hardhat/config'
import '@nomicfoundation/hardhat-toolbox'
import chains from './chains.json'

dotenv.config()


const config: HardhatUserConfig = {
  solidity: '0.8.20',
  networks: {
    polygon: {
      url: chains[0].rpc,
      accounts: [`0x${process.env.PRIVATE_KEY}`],
      network_id: 80001,
    },
    fantom: {
      url: chains[1].rpc,
      accounts: [`0x${process.env.PRIVATE_KEY}`],
      network_id: 4002,
    },
    ethereum: {
      url: chains[2].rpc,
      accounts: [`0x${process.env.PRIVATE_KEY}`],
      network_id: 5,
    },
  },
}

export default config
