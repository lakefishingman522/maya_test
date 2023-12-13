// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract NFTMarketplace is
    Initializable,
    ERC721Upgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    using AddressUpgradeable for address;

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

    function initialize() public initializer {
        __ERC721_init("NFTMarketplace", "NFTM");
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}

    function listNFTForFixedPrice(uint256 _nftId, uint256 _price) public {
        require(
            msg.sender == ownerOf(_nftId),
            "Only NFT owner can list for fixed price"
        );
        require(_price > 0, "Price must be greater than zero");

        nftsForSale[_nftId] = NFT(msg.sender, _price, 0, 0, address(0));
    }

    function listNFTForAuction(
        uint256 _nftId,
        uint256 _startingPrice,
        uint256 _duration
    ) public {
        require(
            msg.sender == ownerOf(_nftId),
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
            msg.sender
        );
    }

    // Rest of the contract code goes here...
    function listNFTForAuction(
        uint256 _nftId,
        uint256 _startingPrice,
        uint256 _duration
    ) public {
        require(
            msg.sender == ERC721.ownerOf(_nftId),
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
            msg.sender
        );
    }

    function getNFTsForFixedPrice() public view returns (uint256[] memory) {
        uint256[] memory nftIds = new uint256[](
            ERC721.balanceOf(address(this))
        );
        uint256 count = 0;

        for (uint256 i = 0; i < ERC721.balanceOf(address(this)); i++) {
            uint256 nftId = ERC721.tokenOfOwnerByIndex(address(this), i);
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
            ERC721.balanceOf(address(this))
        );
        uint256 count = 0;

        for (uint256 i = 0; i < ERC721.balanceOf(address(this)); i++) {
            uint256 nftId = ERC721.tokenOfOwnerByIndex(address(this), i);
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

    function getBiddersForNFT(
        uint256 _nftId
    ) public view returns (address[] memory) {
        require(
            nftsForSale[_nftId].auctionEndTime > 0,
            "NFT is not listed for auction"
        );

        address[] memory bidders = new address[](
            ERC721.balanceOf(address(this))
        );
        uint256 count = 0;

        for (uint256 i = 0; i < ERC721.balanceOf(address(this)); i++) {
            address bidder = ERC721.ownerOf(_nftId);
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
        ERC721.safeTransferFrom(msg.sender, _to, _nftId);
    }

    function bid(uint256 _nftId) public payable {
        require(
            nftsForSale[_nftId].auctionEndTime > 0,
            "NFT is not listed for auction"
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

        if (block.timestamp >= nftsForSale[_nftId].auctionEndTime) {
            payable(nftsForSale[_nftId].owner).transfer(
                nftsForSale[_nftId].highestBid
            );
            ERC721.safeTransferFrom(address(this), msg.sender, _nftId);
            delete nftsForSale[_nftId];
            delete bidsForNFT[_nftId];
        }
    }
}
