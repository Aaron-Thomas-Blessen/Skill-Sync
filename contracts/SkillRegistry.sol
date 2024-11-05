// contracts/SkillRegistry.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./interfaces/IEAS.sol";

contract SkillRegistry is Ownable {
    using Counters for Counters.Counter;
    
    IEAS public immutable eas;
    bytes32 public immutable SKILL_SCHEMA;
    
    struct Skill {
        string name;
        string category;
        uint256 endorsementCount;
        mapping(address => bool) endorsers;
    }
    
    mapping(address => mapping(bytes32 => Skill)) public userSkills;
    mapping(address => bytes32[]) public userSkillList;
    
    event SkillAdded(address indexed user, bytes32 skillId, string name);
    event SkillEndorsed(address indexed endorser, address indexed recipient, bytes32 skillId);
    
    constructor(address easAddress, bytes32 skillSchema) {
        eas = IEAS(easAddress);
        SKILL_SCHEMA = skillSchema;
    }
    
    function addSkill(string memory name, string memory category) external returns (bytes32) {
        bytes32 skillId = keccak256(abi.encodePacked(name, category));
        require(userSkills[msg.sender][skillId].endorsementCount == 0, "Skill already exists");
        
        Skill storage newSkill = userSkills[msg.sender][skillId];
        newSkill.name = name;
        newSkill.category = category;
        newSkill.endorsementCount = 0;
        
        userSkillList[msg.sender].push(skillId);
        
        emit SkillAdded(msg.sender, skillId, name);
        return skillId;
    }
    
    function endorseSkill(address user, bytes32 skillId) external {
        require(user != msg.sender, "Cannot endorse own skill");
        require(userSkills[user][skillId].endorsementCount > 0, "Skill does not exist");
        require(!userSkills[user][skillId].endorsers[msg.sender], "Already endorsed");
        
        // Create attestation
        bytes memory attestationData = abi.encode(
            user,
            skillId,
            userSkills[user][skillId].name,
            block.timestamp
        );
        
        bytes32 attestationUID = eas.attest(SKILL_SCHEMA, attestationData);
        
        userSkills[user][skillId].endorsers[msg.sender] = true;
        userSkills[user][skillId].endorsementCount++;
        
        emit SkillEndorsed(msg.sender, user, skillId);
    }
    
    function getUserSkills(address user) external view returns (bytes32[] memory) {
        return userSkillList[user];
    }
    
    function getSkillDetails(address user, bytes32 skillId) external view 
        returns (string memory name, string memory category, uint256 endorsementCount) {
        Skill storage skill = userSkills[user][skillId];
        return (skill.name, skill.category, skill.endorsementCount);
    }
}