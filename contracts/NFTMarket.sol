// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract NFTMarketplace is
    Initializable,
    ERC721EnumerableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    // using AddressUpgradeable for address;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    struct NFT {
        address owner;
        uint256 price;
        uint256 auctionEndTime;
        uint256 highestBid;
        address highestBidder;
    }

    mapping(uint256 => NFT) public nftsForSale;
    mapping(uint256 => mapping(address => uint256)) public bidsForNFT;

    function initialize(string memory name, string memory symbol) public initializer {
        __ERC721_init(name, symbol);
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {}

    // function for getting the owner of a token
    function getOwnerOfToken(uint256 tokenId) public view returns (address) {
        return ownerOf(tokenId);
    }

    // function for getting all tokens of an owner
    function getTokensOfOwner(address owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 tokenCount = balanceOf(owner);

        uint256[] memory tokensId = new uint256[](tokenCount);
        for (uint256 i = 0; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(owner, i);
        }
        return tokensId;
    }

    // function for get ETH balance of contract
    function getContractEthBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function listNFTForFixedPrice(uint256 _nftId, uint256 _price) public {
        require(
            msg.sender == ownerOf(_nftId),
            "Only NFT owner can list for fixed price"
        );
        require(_price > 0, "Price must be greater than zero");

        nftsForSale[_nftId] = NFT(msg.sender, _price, 0, 0, address(0));
    }

    // Due to duplication of this named function in ERC721EnumerableUpgradeable and AccessControlUpgradeable
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721EnumerableUpgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // Rest of the contract code goes here...
    function listNFTForAuction(
        uint256 _nftId,
        uint256 _startingPrice,
        uint256 _duration
    ) public {
        require(
            msg.sender == ERC721Upgradeable.ownerOf(_nftId),
            "Only NFT owner can list for auction"
        );
        require(_startingPrice > 0, "Starting price must be greater than zero");
        require(_duration > 0, "Auction duration must be greater than zero");

        uint256 auctionEndTime = block.timestamp + _duration;
        nftsForSale[_nftId] = NFT(
            msg.sender,
            _startingPrice,
            auctionEndTime,
            _startingPrice,
            address(0)
        );
    }

    function getNFTsForFixedPrice() public view returns (uint256[] memory) {
        uint256[] memory nftIds = new uint256[](
            ERC721Upgradeable.balanceOf(address(this))
        );
        uint256 count = 0;

        for (
            uint256 i = 0;
            i < ERC721Upgradeable.balanceOf(address(this));
            i++
        ) {
            uint256 nftId = ERC721EnumerableUpgradeable.tokenOfOwnerByIndex(
                address(this),
                i
            );
            if (nftsForSale[nftId].price > 0) {
                nftIds[count] = nftId;
                count++;
            }
        }

        uint256[] memory result = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            result[i] = nftIds[i];
        }

        return result;
    }

    function getNFTsForAuction() public view returns (uint256[] memory) {
        uint256[] memory nftIds = new uint256[](
            ERC721Upgradeable.balanceOf(address(this))
        );
        uint256 count = 0;

        for (
            uint256 i = 0;
            i < ERC721Upgradeable.balanceOf(address(this));
            i++
        ) {
            uint256 nftId = ERC721EnumerableUpgradeable.tokenOfOwnerByIndex(
                address(this),
                i
            );
            if (nftsForSale[nftId].auctionEndTime > 0) {
                nftIds[count] = nftId;
                count++;
            }
        }

        uint256[] memory result = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            result[i] = nftIds[i];
        }

        return result;
    }

    function getAuctionEndTime(uint256 _nftId) public view returns (uint256) {
        require(
            nftsForSale[_nftId].auctionEndTime > 0,
            "NFT is not listed for auction"
        );
        return nftsForSale[_nftId].auctionEndTime;
    }

    function getBiddersForNFT(uint256 _nftId)
        public
        view
        returns (address[] memory)
    {
        require(
            nftsForSale[_nftId].auctionEndTime > 0,
            "NFT is not listed for auction"
        );

        address[] memory bidders = new address[](
            ERC721Upgradeable.balanceOf(address(this))
        );
        uint256 count = 0;

        for (
            uint256 i = 0;
            i < ERC721Upgradeable.balanceOf(address(this));
            i++
        ) {
            address bidder = ERC721Upgradeable.ownerOf(_nftId);
            if (bidsForNFT[_nftId][bidder] > 0) {
                bidders[count] = bidder;
                count++;
            }
        }

        address[] memory result = new address[](count);
        for (uint256 i = 0; i < count; i++) {
            result[i] = bidders[i];
        }

        return result;
    }

    function mintNFT(address _to, uint256 _nftId) public onlyRole(MINTER_ROLE) {
        _safeMint(_to, _nftId);
    }

    function bid(uint256 _nftId) public payable {
        require(
            nftsForSale[_nftId].auctionEndTime > 0,
            "NFT is not listed for auction"
        );
        require(
            block.timestamp < nftsForSale[_nftId].auctionEndTime,
            "Auction has already ended"
        );
        require(
            msg.value > nftsForSale[_nftId].highestBid,
            "Bid must be higher than current highest bid"
        );

        if (nftsForSale[_nftId].highestBidder != address(0)) {
            payable(nftsForSale[_nftId].highestBidder).transfer(
                nftsForSale[_nftId].highestBid
            );
            bidsForNFT[_nftId][nftsForSale[_nftId].highestBidder] = 0;
        }

        nftsForSale[_nftId].highestBidder = msg.sender;
        nftsForSale[_nftId].highestBid = msg.value;
        bidsForNFT[_nftId][msg.sender] = msg.value;
    }

    function finalizeAuction(uint256 _nftId) public payable  {
        require(
            msg.sender == nftsForSale[_nftId].owner,
            "Only the owner can finalize the auction"
        );
        require(
            block.timestamp >= nftsForSale[_nftId].auctionEndTime,
            "The auction has not ended yet"
        );
        

        payable(nftsForSale[_nftId].owner).transfer(
            nftsForSale[_nftId].highestBid
        );
        ERC721Upgradeable.safeTransferFrom(
            address(this),
            nftsForSale[_nftId].highestBidder,
            _nftId
        );
        delete nftsForSale[_nftId];

        // Reset bidder bids
        for (
            uint256 i = 0;
            i < ERC721Upgradeable.balanceOf(address(this));
            i++
        ) {
            address bidder = ERC721Upgradeable.ownerOf(_nftId);
            bidsForNFT[_nftId][bidder] = 0;
        }
    }
}
