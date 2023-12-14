const Web3 = require("web3");
const { artifacts } = require("hardhat");

// Connect to the local Ethereum node
const web3 = new Web3("http://localhost:8545"); // Update your Ethereum node address here

// Load the ABI
const contractArtifact = artifacts.readArtifactSync("NFTMarketplace");
let ABI = contractArtifact.abi;

// The address of the smart contract instance
let contractAddress = "your_contract_address"; // Your contract address

// Create the contract instance
let NFTMarketplace = new web3.eth.Contract(ABI, contractAddress);

// Function to get contract ETH Balance
const getContractEthBalance = async () => {
  let balance = await NFTMarketplace.methods.getContractEthBalance().call();
  console.log(balance);
};

// Function to Mint NFT
const mintNFT = async (to, nftId) => {
  let mintTx = await NFTMarketplace.methods.mintNFT(to, nftId);
  console.log(mintTx);
};

// Function to get the NFTs listed for a fixed price
const getNFTsForFixedPrice = async () => {
  let nftsForSale = await NFTMarketplace.methods.getNFTsForFixedPrice().call();
  console.log("NFTs for fixed price sale: ", nftsForSale);
};

// Function to get the NFTs listed for auction
const getNFTsForAuction = async () => {
  let nftsForAuction = await NFTMarketplace.methods.getNFTsForAuction().call();
  console.log("NFTs for auction: ", nftsForAuction);
};

// Function to get the auction end time for a particular NFT
const getAuctionEndTime = async (nftId) => {
  let auctionEndTime = await NFTMarketplace.methods
    .getAuctionEndTime(nftId)
    .call();
  console.log("Auction end time for NFT " + nftId + ": " + auctionEndTime);
};

// Function to get the bidders for a particular NFT
const getBiddersForNFT = async (nftId) => {
  let bidders = await NFTMarketplace.methods.getBiddersForNFT(nftId).call();
  console.log("Bidders for NFT " + nftId + ": ", bidders);
};
