import { ethers } from "hardhat";
import { SimpleVoting } from "../typechain-types";


async function main() {
    let simpleVotes: SimpleVoting;

    const simpleVotingFactory = await ethers.getContractFactory("SimpleVoting");
    simpleVotes = await simpleVotingFactory.deploy();
    await simpleVotes.deployed();

    console.log("SampleERC deployed to:", simpleVotes.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

