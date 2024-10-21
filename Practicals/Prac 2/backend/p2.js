const express = require("express");
const cors = require("cors");
const SHA256 = require("crypto-js/sha256");

// Block class
class Block {
  constructor(id, data, previousHash = "") {
    this.id = id;
    this.timestamp = new Date();
    this.data = data;
    this.previousHash = previousHash;
    this.hash = this.calculateHash();
  }

  calculateHash() {
    return SHA256(
      this.id + this.timestamp + this.previousHash + JSON.stringify(this.data)
    ).toString();
  }

  updateData(newData) {
    this.data = newData;
    this.hash = this.calculateHash(); // Recalculate hash after data change
  }
}

// Blockchain class
class Blockchain {
  constructor() {
    this.chain = [this.createGenesisBlock()];
  }

  createGenesisBlock() {
    return new Block(0, "Genesis Block", "0");
  }

  getLatestBlock() {
    return this.chain[this.chain.length - 1];
  }

  addBlock(newBlock) {
    newBlock.previousHash = this.getLatestBlock().hash;
    newBlock.hash = newBlock.calculateHash();
    this.chain.push(newBlock);
  }

  editBlock(id, newData) {
    const block = this.chain.find((block) => block.id === id);
    if (block) {
      block.updateData(newData);
    } else {
      throw new Error("Block not found");
    }
  }

  validateChain() {
    for (let i = 1; i < this.chain.length; i++) {
      const currentBlock = this.chain[i];
      const previousBlock = this.chain[i - 1];

      if (currentBlock.hash !== currentBlock.calculateHash()) {
        return false;
      }

      if (currentBlock.previousHash !== previousBlock.hash) {
        return false;
      }
    }
    return true;
  }
}

// Create an instance of Blockchain
const myBlockchain = new Blockchain();

// Express setup
const app = express();
app.use(express.json());
app.use(cors()); // Enable CORS

// Get the entire blockchain
app.get("/blockchain", (req, res) => {
  res.json(myBlockchain);
});

// Add a new block
app.post("/blockchain/addBlock", (req, res) => {
  const { id, data } = req.body;

  if (typeof id !== "number" || !data) {
    return res.status(400).send("Invalid block data");
  }

  const newBlock = new Block(id, data);
  myBlockchain.addBlock(newBlock);
  res.status(201).send(newBlock);
});

// Edit a block
app.put("/blockchain/editBlock/:id", (req, res) => {
  const blockId = parseInt(req.params.id);
  const { data } = req.body;

  try {
    myBlockchain.editBlock(blockId, data);
    res.status(200).send(`Block ${blockId} edited successfully`);
  } catch (error) {
    res.status(404).send(error.message);
  }
});

// Validate the blockchain
app.get("/blockchain/validate", (req, res) => {
  const isValid = myBlockchain.validateChain();
  res.status(200).send({ isValid });
});

// Start the server
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
