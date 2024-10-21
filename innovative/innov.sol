// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleDecentralizedChat {
    struct User {
        bool exists;     // Check if user is registered
        string username; // Username of the user
        bool loggedIn;   // Check if user is currently logged in
    }

    struct Message {
        string content;  // Message content
        string sender;   // Sender's username
        string receiver; // Receiver's username
        uint256 timestamp; // Time sent
    }

    // Mappings
    mapping(string => User) private users;     // User details mapped by username
    mapping(address => string) private loggedInUser; // Address mapped to logged in username
    Message[] private messageLedger;           // Array to store all messages

    // Events
    event UserRegistered(address indexed user, string username);
    event UserLoggedIn(address indexed user, string username);
    event UserLoggedOut(address indexed user, string username);
    event MessageSent(string sender, string receiver, string content, uint256 timestamp);
    event MessageDeleted(string receiver, uint256 messageId);

    // Register a new user
    function register(string calldata username) external {
        require(!users[username].exists, "User already registered");
        require(bytes(username).length > 0, "Username cannot be empty");

        users[username] = User(true, username, false);
        emit UserRegistered(msg.sender, username);
    }

    // Login as an existing user
    function login(string calldata username) external {
        require(users[username].exists, "User not registered");
        
        // Check if there is a user already logged in with this address
        string memory currentUser = loggedInUser[msg.sender];
        if (bytes(currentUser).length > 0) {
            // Log out the current user
            users[currentUser].loggedIn = false;
            emit UserLoggedOut(msg.sender, currentUser);
        }

        // Proceed to log in the new user
        require(!users[username].loggedIn, "User already logged in");

        users[username].loggedIn = true;
        loggedInUser[msg.sender] = username;
        emit UserLoggedIn(msg.sender, username);
    }

    // Send a message to another user
    function sendMessage(string calldata receiver, string calldata content) external {
        string memory senderName = loggedInUser[msg.sender];
        require(users[senderName].loggedIn, "You must be logged in to send a message");
        require(users[receiver].exists, "Receiver is not registered");
        require(bytes(content).length > 0, "Message cannot be empty");

        // Create the message and add it to the ledger
        messageLedger.push(Message(content, senderName, receiver, block.timestamp));

        emit MessageSent(senderName, receiver, content, block.timestamp);
    }

    // View all messages in formatted output
    function viewFormattedMessages() external view returns (string memory) {
        string memory allMessages = "";

        for (uint256 i = 0; i < messageLedger.length; i++) {
            Message storage message = messageLedger[i];

            // Format: Sender: [sender username], Message: [content], Receiver: [receiver username]
            allMessages = string(abi.encodePacked(
                allMessages, 
                "Sender: ", 
                message.sender, 
                ", Message: ", 
                message.content, 
                ", Receiver: ", 
                message.receiver, 
                ";\n"
            ));
        }

        return allMessages;
    }

    // Delete a message (only the receiver can delete)
    function deleteMessage(uint256 messageId) external {
        require(messageId < messageLedger.length, "Message does not exist");

        Message storage message = messageLedger[messageId];
        string memory receiverName = loggedInUser[msg.sender];
        require(users[receiverName].loggedIn, "You must be logged in to delete a message");
        require(keccak256(abi.encodePacked(message.receiver)) == keccak256(abi.encodePacked(receiverName)), "Only the receiver can delete the message");

        // Remove the message by shifting subsequent messages
        for (uint256 i = messageId; i < messageLedger.length - 1; i++) {
            messageLedger[i] = messageLedger[i + 1]; // Shift messages to the left
        }
        messageLedger.pop(); // Remove the last element

        emit MessageDeleted(receiverName, messageId);
    }

    // Get total message count in the ledger
    function getMessageCount() external view returns (uint256) {
        return messageLedger.length;
    }
}
