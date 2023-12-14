const { ethers } = require("hardhat");
const { artifacts } = require("hardhat");
const Web3 = require("web3");

const contractArtifact = artifacts.readArtifactSync("NFTMarketplace");

// Connect to the Ethereum node
const web3 = new Web3("http://localhost:8545"); // Or connect to testnet or mainnet

// Load the ABI
let ABI = contractArtifact.abi;

// Address of the deployed smart contract
let contractAddress = "your_contract_address"; // Your deployed contract address

// Create new contract instance
let NFTMarketplace = new web3.eth.Contract(ABI, contractAddress);

// Function to Mint NFT
const mintNFT = async (to, nftId) => {
  try {
    let mintTx = await NFTMarketplace.methods
      .mintNFT(to, nftId)
      .send({ from: web3.eth.defaultAccount });
    console.log(mintTx);
  } catch (err) {
    console.error(err);
  }
};

// Invoke the mintNFT function
mintNFT("address_to_mint_NFT_to", 1);
