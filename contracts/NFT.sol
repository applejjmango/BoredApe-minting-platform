//SPDX -License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721URIStorage {
    // counters allow us to keep track of tokenIds
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds; // Unique Token Number

    // address of marketplace for NFTs to interact
    address contractAddress;

    constructor(address marketplaceAddress) ERC721("My Open Sea Tokens", "MOST") {
        contractAddress = marketplaceAddress;
    }

    function createToken(string memory tokenURI) public returns (uint) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        _mint(msg.sender, newItemId);

        // set the token URI: id and URL
        _setTokenURI(newItemId, tokenURI);

        // give the marketplace the approval to transact between users
        setApprovalForAll(contractAddress, true);
        return newItemId;
    }
}


