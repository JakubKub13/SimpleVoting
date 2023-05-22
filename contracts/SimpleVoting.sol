// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; // to prevent reentrancy attacks
import "@openzeppelin/contracts/access/Ownable.sol"; // to give special rights to owner of the contract
// overflows and underflows are prevented by default from 0.8.0; version


contract SimpleVoting is Ownable, ReentrancyGuard {

    struct Candidate {
        uint id;
        string name;
        uint256 voteCount;
    }

    uint public candidatesCount;
    bool public isVotingAllowed;

    mapping(address => bool) public voters;
    mapping(uint => Candidate) public candidates;
    mapping (string => bool) existingCandidates;

    // Variables to keep track of the current winner
    string public currentWinnerName;
    uint public currentWinnerVoteCount;

    error CandidateAlreadyAdded();
    error VotingNotActive();
    error NotRegisteredVoter();
    error InvalidCandidate();
    error VotingNotEnded();
    error CandidateNameEmpty();

    constructor() {}

    function addVoter(address _voter) external onlyOwner {
        voters[_voter] = true;
    }

    function addCandidate(string memory _name) external onlyOwner {
        if (bytes(_name).length == 0) revert CandidateNameEmpty();
        if (existingCandidates[_name]) revert CandidateAlreadyAdded();

        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
        existingCandidates[_name] = true;
    }

    function vote(uint _candidateId) external nonReentrant {
        if (!isVotingAllowed) revert VotingNotActive();
        if (!voters[msg.sender]) revert NotRegisteredVoter();
        if (!(_candidateId > 0 && _candidateId <= candidatesCount)) revert InvalidCandidate();

        voters[msg.sender] = false; 

        candidates[_candidateId].voteCount++;

        // Update the current winner if necessary
        if (candidates[_candidateId].voteCount > currentWinnerVoteCount) {
            currentWinnerVoteCount = candidates[_candidateId].voteCount;
            currentWinnerName = candidates[_candidateId].name;
        }
    }

    function winner() external view returns (string memory, uint256) {
        if (isVotingAllowed) revert VotingNotEnded();

        return (currentWinnerName, currentWinnerVoteCount);
    }

    function startVoting() external onlyOwner {
        isVotingAllowed = true;
    }

    function endVoting() external onlyOwner {
        isVotingAllowed = false;
    }
}