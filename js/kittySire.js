export default {
  address: "0xC7af99Fe5513eB6710e6D5f44F9989dA40F27F26",
  abi: [
  {
    "constant": false,
    "inputs": [
      { "name": "_tokenId", "type": "uint256" },
      { "name": "_startingPrice", "type": "uint256" },
      { "name": "_endingPrice", "type": "uint256" },
      { "name": "_duration", "type": "uint256" },
      { "name": "_seller", "type": "address" }
    ],
    "name": "createAuction",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      { "name": "_tokenId", "type": "uint256" }
    ],
    "name": "bid",
    "outputs": [],
    "payable": true,
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "isSiringClockAuction",
    "outputs": [
      { "name": "", "type": "bool" }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [
      { "name": "_tokenId", "type": "uint256" }
    ],
    "name": "getAuction",
    "outputs": [
      { "name": "seller", "type": "address" },
      { "name": "startingPrice", "type": "uint256" },
      { "name": "endingPrice", "type": "uint256" },
      { "name": "duration", "type": "uint256" },
      { "name": "startedAt", "type": "uint256" }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "ownerCut",
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
      { "name": "_tokenId", "type": "uint256" }
    ],
    "name": "cancelAuctionWhenPaused",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      { "name": "_tokenId", "type": "uint256" }
    ],
    "name": "cancelAuction",
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
    "name": "getCurrentPrice",
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
      { "name": "newOwner", "type": "address" }
    ],
    "name": "transferOwnership",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "anonymous": false,
    "inputs": [
      { "indexed": false, "name": "tokenId", "type": "uint256" },
      { "indexed": false, "name": "startingPrice", "type": "uint256" },
      { "indexed": false, "name": "endingPrice", "type": "uint256" },
      { "indexed": false, "name": "duration", "type": "uint256" }
    ],
    "name": "AuctionCreated",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      { "indexed": false, "name": "tokenId", "type": "uint256" },
      { "indexed": false, "name": "totalPrice", "type": "uint256" },
      { "indexed": false, "name": "winner", "type": "address" }
    ],
    "name": "AuctionSuccessful",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      { "indexed": false, "name": "tokenId", "type": "uint256" }
    ],
    "name": "AuctionCancelled",
    "type": "event"
  }
]}
