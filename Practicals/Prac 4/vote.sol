// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract SimpleVoting {
    
    // Candidate structure with name and voteCount
    struct Candidate {
        string name;
        uint voteCount;
    }

    address public owner; // Election owner
    Candidate[] public candidates; // List of candidates

    // Constructor to initialize the owner
    constructor() {
        owner = msg.sender;
    }

    // Modifier to ensure only the owner can call certain functions
    modifier ownerOnly() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    // Add a new candidate (only owner can add)
    function addCandidate(string memory _name) ownerOnly public {
        candidates.push(Candidate(_name, 0)); // Add candidate with 0 votes initially
    }

    // Function for anyone to vote for a candidate by ID
    function vote(uint candidateId) public {
        require(candidateId < candidates.length, "Invalid candidate ID"); // Check valid candidate ID
        candidates[candidateId].voteCount += 1; // Increment vote count for the selected candidate
    }

    // View function to get total votes for each candidate
    function getVotes() public view returns (string[] memory, uint[] memory) {
        uint[] memory votes = new uint[](candidates.length); // Array to store vote counts
        string[] memory names = new string[](candidates.length); // Array to store candidate names
        for (uint i = 0; i < candidates.length; i++) {
            votes[i] = candidates[i].voteCount; // Get the vote count for each candidate
            names[i] = candidates[i].name; // Get the name for each candidate
        }
        return (names, votes); // Return candidate names and their vote counts
    }
}
