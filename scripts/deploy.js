const hre = require("hardhat");

async function main() {
  const ERC721Insomnia = await hre.ethers.getContractFactory('ERC721Insomnia');
  const erc721Insomnia = await ERC721Insomnia.deploy("ERC721Insomnia", "INS");

  const address = await erc721Insomnia.waitForDeployment();
  console.log("ERC721Insomnia Token deployed: ", address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
