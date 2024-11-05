// contracts/ProfileManager.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ProfileManager is Ownable {
    using Counters for Counters.Counter;
    
    struct Profile {
        string name;
        string bio;
        string avatar;
        uint256 gitcoinScore;
        bool isVerified;
        uint256 timestamp;
    }
    
    mapping(address => Profile) public profiles;
    mapping(address => bool) public registeredUsers;
    
    address public gitcoinPassportContract;
    uint256 public minimumPassportScore;
    
    event ProfileCreated(address indexed user, string name);
    event ProfileUpdated(address indexed user);
    event VerificationStatusChanged(address indexed user, bool isVerified);
    
    constructor(address _gitcoinPassportContract, uint256 _minimumScore) {
        gitcoinPassportContract = _gitcoinPassportContract;
        minimumPassportScore = _minimumScore;
    }
    
    function createProfile(string memory name, string memory bio, string memory avatar) external {
        require(!registeredUsers[msg.sender], "Profile already exists");
        
        uint256 passportScore = getGitcoinScore(msg.sender);
        require(passportScore >= minimumPassportScore, "Insufficient Gitcoin score");
        
        profiles[msg.sender] = Profile({
            name: name,
            bio: bio,
            avatar: avatar,
            gitcoinScore: passportScore,
            isVerified: true,
            timestamp: block.timestamp
        });
        
        registeredUsers[msg.sender] = true;
        emit ProfileCreated(msg.sender, name);
    }
    
    function updateProfile(string memory name, string memory bio, string memory avatar) external {
        require(registeredUsers[msg.sender], "Profile does not exist");
        
        Profile storage profile = profiles[msg.sender];
        profile.name = name;
        profile.bio = bio;
        profile.avatar = avatar;
        profile.timestamp = block.timestamp;
        
        emit ProfileUpdated(msg.sender);
    }
    
    function getGitcoinScore(address user) public view returns (uint256) {
        // Implementation would interact with Gitcoin Passport contract
        // Placeholder for now
        return 100;
    }
    
    function updateGitcoinPassportContract(address newContract) external onlyOwner {
        gitcoinPassportContract = newContract;
    }
    
    function updateMinimumPassportScore(uint256 newScore) external onlyOwner {
        minimumPassportScore = newScore;
    }
    
    function getProfile(address user) external view 
        returns (string memory name, string memory bio, string memory avatar, 
                uint256 gitcoinScore, bool isVerified, uint256 timestamp) {
        Profile memory profile = profiles[user];
        return (
            profile.name,
            profile.bio,
            profile.avatar,
            profile.gitcoinScore,
            profile.isVerified,
            profile.timestamp
        );
    }
}