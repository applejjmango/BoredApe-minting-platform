const { expect } = require("chai");
const { ethers } = require("hardhat");
const { list } = require("postcss");

describe("NFTMarket", function () {
  beforeEach(async function () {
    // test to receive contract addresses
    const Market = await ethers.getContractFactory("NFTMarket");
    const market = await Market.deploy();
    await market.deployed();
    // console.log("deployed market => ", market);
    const marketAddress = market.address;

    const NFT = await ethers.getContractFactory("NFT");
    const nft = await NFT.deploy(marketAddress);
    await nft.deployed();
    // console.log("deployed nft ==========> ", nft);
    const nftContractAddress = nft.address;
  });

  it("Should check if listingPrice is 0.05", async function () {
    // test to receive listing price
    // test to receive contract addresses
    const Market = await ethers.getContractFactory("NFTMarket");
    const market = await Market.deploy();
    await market.deployed();
    // console.log("deployed market => ", market);
    const marketAddress = market.address;

    const NFT = await ethers.getContractFactory("NFT");
    const nft = await NFT.deploy(marketAddress);
    await nft.deployed();
    // console.log("deployed nft ==========> ", nft);
    const nftContractAddress = nft.address;

    let listingPrice = await market.getListingPrice();
    listingPrice = parseInt(listingPrice.toString());

    expect(listingPrice).to.equal(50000000000000000);
  });

  it("Should mint and trade NFTs", async function () {
    // test to receive contract addresses
    const Market = await ethers.getContractFactory("NFTMarket");
    const market = await Market.deploy();
    await market.deployed();
    const marketAddress = market.address;

    const NFT = await ethers.getContractFactory("NFT");
    const nft = await NFT.deploy(marketAddress);
    await nft.deployed();
    const nftContractAddress = nft.address;

    let listingPrice = await market.getListingPrice();
    listingPrice = listingPrice.toString();

    const auctionPrice = ethers.utils.parseUnits("10", "ether");

    await nft.createToken("hello-first-token");
    await nft.createToken("hello-second-token");

    await market.createMarketItem(nftContractAddress, 1, auctionPrice, {
      value: listingPrice,
    });
    await market.createMarketItem(nftContractAddress, 2, auctionPrice, {
      value: listingPrice,
    });

    const [_, buyerAddress] = await ethers.getSigners();

    // create a market sale with address, id and price
    await market.connect(buyerAddress).createMarketSale(nftContractAddress, 1, {
      value: auctionPrice,
    });

    let items = await market.fetchMarketItems();

    items = await Promise.all(
      items.map(async (i) => {
        // Get the URI of the value
        const tokenUri = await nft.tokenURI(i.tokenId);
        let item = {
          price: i.price.toString(),
          tokenId: i.tokenId.toString(),
          seller: i.seller,
          owner: i.owner,
          tokenUri,
        };
        return item;
      })
    );
    // Test out all the items
    console.log("after items ===> ", items);
  });
});
