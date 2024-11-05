// scripts/deploy.js
const hre = require("hardhat");

async function main() {
  // Deploy SkillRegistry
  const skillSchema = ethers.utils.id("SKILL_ATTESTATION_SCHEMA");
  const SkillRegistry = await hre.ethers.getContractFactory("SkillRegistry");
  const skillRegistry = await SkillRegistry.deploy(
    process.env.EAS_CONTRACT_ADDRESS,
    skillSchema
  );
  await skillRegistry.deployed();
  console.log("SkillRegistry deployed to:", skillRegistry.address);

  // Deploy ProfileManager
  const ProfileManager = await hre.ethers.getContractFactory("ProfileManager");
  const profileManager = await ProfileManager.deploy(
    process.env.GITCOIN_PASSPORT_CONTRACT,
    50 // minimum score
  );
  await profileManager.deployed();
  console.log("ProfileManager deployed to:", profileManager.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });