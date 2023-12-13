const { ethers, upgrades } = require("hardhat");

async function main() {
  const NFTMarketplace = await ethers.getContractFactory("NFTMarketplace");
  console.log("Deploying NFTMarketplace...");
  const nftMarketplace = await upgrades.deployProxy(NFTMarketplace);
  await nftMarketplace.deployed();
  console.log("NFTMarketplace deployed to:", nftMarketplace.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
