// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract SOLSURVIVORS is ERC721A, Ownable, ReentrancyGuard {
    using Strings for uint256;

    uint256 public MAX_MINTS;
    uint256 public MAX_MINT_PER_TRANSACTION;
    uint256 public MAX_SUPPLY;
    uint256 public mintRate;
    bool public paused = false;
    string public notRevealedURI;
    string public baseURI;
    address public artist;
    uint256 royaltyFee = 5;
    bool public revealed = false;
    bool public publicSale = false;
    bytes32 public merkleRoot;
    string public baseExtension = ".json";

    constructor(
        uint256 _mintRate,
        uint256 _maxSupply,
        uint256 _maxMints,
        uint256 _maxMintsPerTransaction,
        bytes32 _root,
        string memory _initBaseURI,
        string memory _initNotRevealedURI,
        address _artist
    ) ERC721A("SOLSURVIVORS", "SLV") {
        mintRate = _mintRate;
        MAX_SUPPLY = _maxSupply;
        MAX_MINTS = _maxMints;
        MAX_MINT_PER_TRANSACTION = _maxMintsPerTransaction;
        baseURI = _initBaseURI;
        notRevealedURI = _initNotRevealedURI;
        merkleRoot = _root;
        artist = _artist;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function publicSaleMint(uint256 tokens) public payable nonReentrant {
        require(!paused, "Contract is paused");
        require(publicSale, "Sale hasn't started yet");
        uint256 supply = totalSupply();
        require(tokens <= MAX_MINT_PER_TRANSACTION, "Max mint amount per transaction exceeded");
        require(msg.value >= (mintRate * tokens), "Not enough ether sent");
        require(supply + tokens <= MAX_SUPPLY, "We are sold out");
        require(_numberMinted(_msgSender()) + tokens <= MAX_MINTS, "Max NFT per wallet exceeded");

        if (msg.value > 0) {
            uint256 royalty = (msg.value * royaltyFee) / 100;
            _payRoyalty(royalty);

            (bool success2, ) = payable(owner()).call{value: msg.value - royalty}("");
            require(success2);
        }

        _safeMint(_msgSender(), tokens);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721AMetadata: URI query for nonexistent token");

        if (revealed == false) {
            return notRevealedURI;
        }

        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0 ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension)) : "";
    }

    function numberMinted(address owner) public view returns (uint256) {
        return _numberMinted(owner);
    }

    function reveal(bool _state) public onlyOwner {
        revealed = _state;
    }

    function setMintRate(uint256 _mintRate) public onlyOwner {
        mintRate = _mintRate;
    }

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
    }

    function transferFrom(address from, address to, uint256 tokenId) public payable override {
        if (msg.value > 0) {
            uint256 royalty = (msg.value * royaltyFee) / 100;
            _payRoyalty(royalty);

            (bool success2, ) = payable(from).call{value: msg.value - royalty}("");
            require(success2);
        }
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public payable override {
        if (msg.value > 0) {
            uint256 royalty = (msg.value * royaltyFee) / 100;
            _payRoyalty(royalty);

            (bool success2, ) = payable(from).call{value: msg.value - royalty}("");
            require(success2);
        }
        super.safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public payable override {
        if (msg.value > 0) {
            uint256 royalty = (msg.value * royaltyFee) / 100;
            _payRoyalty(royalty);

            (bool success2, ) = payable(from).call{value: msg.value - royalty}("");
            require(success2);
        }
        super.safeTransferFrom(from, to, tokenId, _data);
    }

    function _payRoyalty(uint256 _royaltyFee) internal {
        (bool success1, ) = payable(artist).call{value: _royaltyFee}("");
        require(success1);
    }

    function setMaxSupply(uint256 _maxSupply) public onlyOwner {
        MAX_SUPPLY = _maxSupply;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
        baseExtension = _newBaseExtension;
    }

    function togglePublicSale(bool _state) external onlyOwner {
        publicSale = _state;
    }

    function withdraw() external payable onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
