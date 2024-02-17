const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ERC721Insomnia", function () {
  let ERC721Insomnia;
  let erc721Insomnia;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();
    ERC721Insomnia = await ethers.getContractFactory("ERC721Insomnia");
    erc721Insomnia = await ERC721Insomnia.deploy("MyNFT", "NFT");
    await erc721Insomnia.deployed();
  });

  it("Should mint a new NFT", async function () {
    const tokenId = 1;
    const uri = "ipfs://Qm123456";
    await erc721Insomnia.connect(owner).safeMint(addr1.address, uri);
    expect(await erc721Insomnia.ownerOf(tokenId)).to.equal(addr1.address);
    expect(await erc721Insomnia.tokenURI(tokenId)).to.equal(uri);
  });

  it("Should transfer NFT safely", async function () {
    const tokenId = 1;
    const uri = "ipfs://Qm123456";
    await erc721Insomnia.connect(owner).safeMint(addr1.address, uri);
    await erc721Insomnia.connect(addr1).safeTransferFrom(addr1.address, addr2.address, tokenId);
    expect(await erc721Insomnia.ownerOf(tokenId)).to.equal(addr2.address);
  });

  it("Should approve and transfer NFT", async function () {
    const tokenId = 1;
    const uri = "ipfs://Qm123456";
    await erc721Insomnia.connect(owner).safeMint(addr1.address, uri);
    await erc721Insomnia.connect(addr1).approve(addr2.address, tokenId);
    await erc721Insomnia.connect(addr2).transferFrom(addr1.address, addr2.address, tokenId);
    expect(await erc721Insomnia.ownerOf(tokenId)).to.equal(addr2.address);
  });

  it("Should set approval for all", async function () {
    await erc721Insomnia.connect(owner).setApprovalForAll(addr1.address, true);
    expect(await erc721Insomnia.isApprovedForAll(owner.address, addr1.address)).to.be.true;
  });
});
