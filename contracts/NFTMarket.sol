//SPDX -License-Identifier: MIT
pragma solidity ^0.8.4;

// security against transactions for multiple requests
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "hardhat/console.sol";

contract NFTMarket is ReentrancyGuard {
    using Counters for Counters.Counter;

    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    address payable owner;
    uint listingPrice = 0.05 ether; // 수수료

    constructor() {
        owner = payable(msg.sender);
    }

    struct MarketItem {
        uint itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    // tokenId returns which MarketItem - fetch which one it is
    mapping (uint256=>MarketItem) private idToMarketItem;

    event MarketItemCreated (
        uint indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    // Get the listing price
    function getListingPrice() public view returns(uint256) {
        return listingPrice;
    }

    // Two functions to interact with contract
    // 1. Create a market item to put it up for sale
    // 2. Create a market sale for buying and selling between parties
    function createMarketItem(
        address _nftContract,
        uint256 _tokenId,
        uint256 _price
        // nonReentrant is a modifier to prevent reentry attack
    ) public payable nonReentrant {
        require(_price > 0, "Price must be at least 1 wei");
        require(msg.value == listingPrice, "Price must be equal to listing price");

        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        // Putting it up for sale - No Owner
        idToMarketItem[itemId] = MarketItem(
            itemId,
            _nftContract,
            _tokenId,
            payable(msg.sender),
            payable(address(0)),
            _price,
            false
        );

        // NFT Transaction
        IERC721(_nftContract).transferFrom(msg.sender, address(this), _tokenId);

        emit MarketItemCreated(
            itemId, 
            _nftContract, 
            _tokenId, 
            msg.sender, 
            address(0), 
            _price, 
            false
        );
    }

    // Sell Item(NFTs)
    function createMarketSale(
        address _nftContract, 
        uint256 _itemId
    ) public payable nonReentrant {
        uint price = idToMarketItem[_itemId].price;
        uint tokenId = idToMarketItem[_itemId].tokenId;

        require(msg.value == price, "Please submit the asking price in order to complete the purchase");

        // transfer the amount to the seller
        idToMarketItem[_itemId].seller.transfer(msg.value);

        // transfer the token(ownership of digital goods) from contract address to the buyer
        IERC721(_nftContract).transferFrom(address(this), msg.sender, tokenId);

        idToMarketItem[_itemId].owner = payable(msg.sender);
        idToMarketItem[_itemId].sold = true;
        _itemsSold.increment();

        payable(owner).transfer(listingPrice);        
    }

    // Returns all unsold market items
    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint itemCount = _itemIds.current();

        // fetch items not been sold out by anyone
        uint unsoldItemCount = _itemIds.current() - _itemsSold.current();
        uint currentIndex = 0;
        
        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        for (uint i = 0; i < itemCount; i++) {
            // unsold items
            if (idToMarketItem[i + 1].owner == address(0)) {
                uint currentId = idToMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    // Fetch(get) my items that I purchased
    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint totalItemCount = _itemIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                uint currentId = idToMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    // function for returning an array of minted NFTs
    function fetchItemsCreated() public view returns (MarketItem[] memory) {
        // Instead of Owner, It will be the seller
        uint totalItemCount = _itemIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                uint currentId = idToMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
}