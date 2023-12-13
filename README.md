# Upgradable ERC-721 NFT marketplace SmartCOntract Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

This smart contract is able to list an ERC-721 NFT with:
• Fixed price (eg., 0.0001 eth).
• An auction based listing for a specific time period, where the highest bid secures the NFT.

The smart contract includes the following functionalities:

1. List an NFT for fixed price (price should be provided by user).
2. List an NFT on auction basis for a specific time (highest bidder acquires the NFT).
3. Retrieve data of NFT(s) listed at a fixed price.
4. Retrieve data of NFT(s) listed on an auction basis.
5. Retrieve the auction end time for a specific NFT ID.
6. Retrieve wallets addresses of bidders for specific NFT ID.
7. Also a function to mint ERC-721 NFTs. (Note: Only wallet addresses with “MINTER_ROLE” can mint the
   NFT, use the AccessControl smart contract).

This project is using hardhat and OpenZeppelin 5.0 contracts
