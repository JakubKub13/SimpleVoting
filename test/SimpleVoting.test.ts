import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers"
import { expect } from "chai";
import { ethers } from "hardhat";
import { SimpleVoting, SimpleVoting__factory } from "../typechain-types";
import { experimentalAddHardhatNetworkMessageTraceHook } from "hardhat/config";

interface Candidate {
    id: number;
    name: string;
    voteCount: number;
}

describe("SimpleVoting", function () {
    let owner: SignerWithAddress;
    let acc1: SignerWithAddress;
    let acc2: SignerWithAddress;
    let acc3: SignerWithAddress;
    let acc4: SignerWithAddress;
    let acc5: SignerWithAddress;
    let acc6: SignerWithAddress;
    let simpleVoting: SimpleVoting;
    let simpleVotingFactory: SimpleVoting__factory;


    beforeEach(async () => {
        [owner, acc1, acc2, acc3, acc4, acc5, acc6] = await ethers.getSigners();

        simpleVotingFactory = await ethers.getContractFactory("SimpleVoting");
        simpleVoting = await simpleVotingFactory.deploy();
        await simpleVoting.deployed();

        console.log("SimpleVoting deployed to: ", simpleVoting.address);
    })

    describe("Deployment", () => {
        it("Should be deployed as expected", async () => {
            expect(simpleVoting.address).to.eq("0x5FbDB2315678afecb367f032d93F642f64180aa3");
        });

        it("Voting should not be allowed by default", async () => {
            expect(await simpleVoting.isVotingAllowed()).to.eq(false);
        });

        it("Should set the correct owner", async () => {
            expect(await simpleVoting.owner()).to.eq(owner.address);
        });
    });

    describe("Voting", () => {
        it("Should not allow other account than owner to start voting", async () => {
            await expect(simpleVoting.connect(acc1).startVoting()).to.be.revertedWith("Ownable: caller is not the owner");
        });

        // TO DO--------------------------------------------------------------------------------------------------------
        it("Should allow owner to start voting", async () => {
            await simpleVoting.startVoting();
            expect(await simpleVoting.isVotingAllowed()).to.eq(true);
        });

        it("Should not allow other account than owner to stop voting", async () => {
            await simpleVoting.startVoting();
            await expect(simpleVoting.connect(acc1).endVoting()).to.be.revertedWith("Ownable: caller is not the owner");
        });

        it("Should allow owner to stop voting", async () => {
            await simpleVoting.startVoting();
            await simpleVoting.endVoting();
            expect(await simpleVoting.isVotingAllowed()).to.eq(false);
        });

        it("Should not allow other account than owner to add candidate", async () => {
            await expect(simpleVoting.connect(acc1).addCandidate("Candidate 1")).to.be.revertedWith("Ownable: caller is not the owner");
        });

        it("Should allow owner to add candidate", async () => {
            await simpleVoting.addCandidate("Candidate 1");
            await simpleVoting.addCandidate("Candidate 2");
            await simpleVoting.addCandidate("Candidate 3");
            await simpleVoting.addCandidate("Candidate 4");
            expect(await simpleVoting.candidatesCount()).to.eq(4);


        });

        it("Should allow voters to vote for candidate", async () => {

        });

        it("Should allow voter to vote only once", async () => {});

        it("Should not allow voter to vote if voting is not allowed", async () => {});

        it("Shoould not allow to add same candidate twice", async () => {});

        it("Should not allow to add candidate with empty name", async () => {});
    });
});