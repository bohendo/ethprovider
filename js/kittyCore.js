var coreAddress = "0x06012c8cf97BEaD5deAe237070F9587f8E7A266d"
var coreABI = [
  {
    "constant": false,
    "inputs": [
      { "name": "_to", "type": "address" },
      { "name": "_tokenId", "type": "uint256" }
    ],
    "name": "approve",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "totalSupply",
    "outputs": [
      { "name": "", "type": "uint256" }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "pregnantKitties",
    "outputs": [
      { "name": "", "type": "uint256" }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [
      { "name": "_kittyId", "type": "uint256" }
    ],
    "name": "isPregnant",
    "outputs": [
      { "name": "", "type": "bool" }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "siringAuction",
    "outputs": [
      { "name": "", "type": "address" }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      { "name": "_kittyId", "type": "uint256" },
      { "name": "_startingPrice", "type": "uint256" },
      { "name": "_endingPrice", "type": "uint256" },
      { "name": "_duration", "type": "uint256" }
    ],
    "name": "createSaleAuction",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [
      { "name": "", "type": "uint256" }
    ],
    "name": "sireAllowedToAddress",
    "outputs": [
      { "name": "", "type": "address" }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [
      { "name": "_matronId", "type": "uint256" },
      { "name": "_sireId", "type": "uint256" }
    ],
    "name": "canBreedWith",
    "outputs": [
      { "name": "", "type": "bool" }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      { "name": "_kittyId", "type": "uint256" },
      { "name": "_startingPrice", "type": "uint256" },
      { "name": "_endingPrice", "type": "uint256" },
      { "name": "_duration", "type": "uint256" }
    ],
    "name": "createSiringAuction",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [
      { "name": "_tokenId", "type": "uint256" }
    ],
    "name": "ownerOf",
    "outputs": [
      { "name": "owner", "type": "address" }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [
      { "name": "_owner", "type": "address" }
    ],
    "name": "balanceOf",
    "outputs": [
      { "name": "count", "type": "uint256" }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [
      { "name": "_owner", "type": "address" }
    ],
    "name": "tokensOfOwner",
    "outputs": [
      { "name": "ownerTokens", "type": "uint256[]" }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      { "name": "_matronId", "type": "uint256" }
    ],
    "name": "giveBirth",
    "outputs": [
      { "name": "", "type": "uint256" }
    ],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [
      { "name": "", "type": "uint256" }
    ],
    "name": "cooldowns",
    "outputs": [
      { "name": "", "type": "uint32" }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      { "name": "_to", "type": "address" },
      { "name": "_tokenId", "type": "uint256" }
    ],
    "name": "transfer",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "autoBirthFee",
    "outputs": [
      { "name": "", "type": "uint256" }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [
      { "name": "_kittyId", "type": "uint256" }
    ],
    "name": "isReadyToBreed",
    "outputs": [
      { "name": "", "type": "bool" }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "saleAuction",
    "outputs": [
      { "name": "", "type": "address" }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [
      { "name": "_id", "type": "uint256" }
    ],
    "name": "getKitty",
    "outputs": [
      { "name": "isGestating", "type": "bool" },
      { "name": "isReady", "type": "bool" },
      { "name": "cooldownIndex", "type": "uint256" },
      { "name": "nextActionAt", "type": "uint256" },
      { "name": "siringWithId", "type": "uint256" },
      { "name": "birthTime", "type": "uint256" },
      { "name": "matronId", "type": "uint256" },
      { "name": "sireId", "type": "uint256" },
      { "name": "generation", "type": "uint256" },
      { "name": "genes", "type": "uint256" }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      { "name": "_sireId", "type": "uint256" },
      { "name": "_matronId", "type": "uint256" }
    ],
    "name": "bidOnSiringAuction",
    "outputs": [],
    "payable": true,
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "gen0CreatedCount",
    "outputs": [
      { "name": "", "type": "uint256" }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      { "name": "_matronId", "type": "uint256" },
      { "name": "_sireId", "type": "uint256" }
    ],
    "name": "breedWithAuto",
    "outputs": [],
    "payable": true,
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "anonymous": false,
    "inputs": [
      { "indexed": false, "name": "owner", "type": "address" },
      { "indexed": false, "name": "matronId", "type": "uint256" },
      { "indexed": false, "name": "sireId", "type": "uint256" },
      { "indexed": false, "name": "cooldownEndBlock", "type": "uint256" }
    ],
    "name": "Pregnant",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      { "indexed": false, "name": "from", "type": "address" },
      { "indexed": false, "name": "to", "type": "address" },
      { "indexed": false, "name": "tokenId", "type": "uint256" }
    ],
    "name": "Transfer",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      { "indexed": false, "name": "owner", "type": "address" },
      { "indexed": false, "name": "approved", "type": "address" },
      { "indexed": false, "name": "tokenId", "type": "uint256" }
    ],
    "name": "Approval",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      { "indexed": false, "name": "owner", "type": "address" },
      { "indexed": false, "name": "kittyId", "type": "uint256" },
      { "indexed": false, "name": "matronId", "type": "uint256" },
      { "indexed": false, "name": "sireId", "type": "uint256" },
      { "indexed": false, "name": "genes", "type": "uint256" }
    ],
    "name": "Birth",
    "type": "event"
  }
]
