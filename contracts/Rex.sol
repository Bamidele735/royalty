// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract REX is ERC721A, Ownable, ReentrancyGuard {
    using Strings for uint256;

    uint public constant MAX_TOKENS = 1000;
    
    uint public PRESALE_LIMIT = 500;
    uint public presaleTokensSold = 0;
    // uint public constant NUMBER_RESERVED_TOKENS = 2;
    uint256 public PRICE = 0.0001 ether;
    uint256 public WHITELIST_SALE_PRICE = 0.00002 ether;
    uint public MAX_WHITELIST_MINT = 10;
    uint public perAddressLimit = 10;

    
    bool public saleIsActive = false;
    bool public preSaleIsActive = false;
    bool public whitelist = false;
    bool public revealed = false;
    bool public paused = false;

    uint public reservedTokensMinted = 0;
    string private _baseTokenURI;
    string public notRevealedUri;
    bytes32 public merkleRoot = 0;

        // boolean to keep track of whether presale started or not
    bool public presaleStarted;
    bytes32 root;

    // timestamp for when presale would end
    uint256 public presaleEnded;

    bool public _paused;

    modifier onlyWhenNotPaused {
        require(!_paused, "Contract currently paused");
        _;
    }

    mapping(address => uint) public addressMintedBalance;
    // mapping(address => bool) public whitelistClaimed;

    constructor() ERC721A("REX", "rex") {}

    function startPresale() public onlyOwner {
        preSaleIsActive = true;
        // Set presaleEnded time as current timestamp + 5 minutes
        // Solidity has cool syntax for timestamps (seconds, minutes, hours, days, years)
        presaleEnded = block.timestamp + 24 hours;
    }

    function preSaleMint(uint256 amount, bytes32[]  calldata merkleProof) public payable nonReentrant {
    // Verify whitelist requirements
    require(preSaleIsActive && block.timestamp < presaleEnded, "Presale is not running");
    require(preSaleIsActive, 'The whitelist sale is not enabled!');
    require(MerkleProof.verify(merkleProof, merkleRoot, keccak256(abi.encodePacked(msg.sender))), " You are not in the whitelist");
    require(_numberMinted(_msgSender()) + amount <= MAX_WHITELIST_MINT, "Max NFT Per Wallet exceeded");
    require(preSaleIsActive || saleIsActive, "Sale must be active to mint");
    require(!preSaleIsActive || presaleTokensSold + amount <= PRESALE_LIMIT, "Purchase would exceed max supply");
    require(msg.value >= WHITELIST_SALE_PRICE * amount, "Not enough ETH for transaction");
    require(addressMintedBalance[msg.sender] + amount <= perAddressLimit, "Max NFT per tx exceeded");

    // addressMintedBalance[_msgSender()] = true;
    _safeMint(_msgSender(), amount);
    }

    function mint(uint256 quantity) external payable {
        // _safeMint's second argument now takes in a quantity, not a tokenId.
        require(quantity + _numberMinted(msg.sender) <= perAddressLimit, "Exceeded the limit");
        require(totalSupply() + quantity <= MAX_TOKENS, "Not enough tokens left");
        require(msg.value >= (PRICE * quantity), "Not enough ether sent");
        _safeMint(msg.sender, quantity);
    }



    function setPaused(bool val) public onlyOwner {
        _paused = val;
    }
    function numberMinted(address owner) public view returns (uint256) {
    return _numberMinted(owner);
  }
  function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }
    function setPerAddressLimit(uint newLimit) external onlyOwner 
    {
        perAddressLimit = newLimit;
    }
    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }
    function reveal() public onlyOwner {
        revealed = true;
    }
    // function mintReservedTokens(address to, uint256 amount) external onlyOwner 
    // {
    //     require(reservedTokensMinted + amount <= NUMBER_RESERVED_TOKENS, "This amount is more than max allowed");

    //     for (uint i = 0; i < amount; i++) 
    //     {
    //         _safeMint(to, totalSupply() + 1);
    //         reservedTokensMinted++;
    //     }
    // }
    function mintForAddress(uint256 _mintAmount, address _receiver) public onlyOwner {
    _safeMint(_receiver, _mintAmount);
    }
    
    ////
    //URI management part
    ////
    
    function _setBaseURI(string memory baseURI) internal virtual {
        _baseTokenURI = baseURI;
    }


    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }
    
    function setBaseURI(string memory baseURI) external onlyOwner {
        _setBaseURI(baseURI);
    }
  function setPUBLIC_SALE_PRICE(uint256 _newCost) public onlyOwner {
    PRICE = _newCost;
  }
  
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if(revealed == false) {
            return notRevealedUri;
        }

        string memory _tokenURI = super.tokenURI(tokenId);
        return bytes(_tokenURI).length > 0 ? string(abi.encodePacked(_tokenURI, ".json")) : "";
    }

    function withdraw() public onlyOwner  {
        payable(owner()).transfer(address(this).balance);
    }

}
