const { expect } = require("chai");
const { ethers } = require("hardhat");
const { list } = require("postcss");

describe("NFTMarket", function () {
  it("Check if listingPrice is 0.05", async function () {
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

    // test to receive listing price
    let listingPrice = await market.getListingPrice();
    console.log("listingPrice => ", listingPrice);
    listingPrice = parseInt(listingPrice.toString());
    console.log("to string listingPrice => ", listingPrice);

    expect(listingPrice).to.equal(50000000000000000);
  });
});
