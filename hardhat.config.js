// require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config({ path: ".env" });

require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");

const QUICKNODE_HTTP_URL = process.env.NEXT_PUBLIC_ALCHEMY_RPC_URL;
const PRIVATE_KEY = process.env.METAMASK_PRIVATE_KEY;
const SCAN_KEY = process.env.ETHERSCAN_API_KEY;
const MAINNET = process.env.ALCHEMY_MAINNET_URL;

module.exports = {
  solidity: "0.8.4",
  networks: {
    polygonMumbai: {
      url: QUICKNODE_HTTP_URL,
      accounts: [PRIVATE_KEY],
    },
    mainnet: {
      url: MAINNET,
      accounts: [PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: {
      polygon: SCAN_KEY,
      polygon: SCAN_KEY,
    },
  },
};

// etherscan: {
//   apiKey: {
//     polygonMumbai: POLYGONSCAN_KEY,
//   },
