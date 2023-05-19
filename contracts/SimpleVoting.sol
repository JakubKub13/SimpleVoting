// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; // to prevent reentrancy attacks
import "@openzeppelin/contracts/access/Ownable.sol"; // to give special rights to owner of the contract
// overflows and underflows are prevented by default from 0.8.0; version


contract SimpleVoting is Ownable, ReentrancyGuard {

    /**
    @notice Struct describing candidate
    @param id - id of candidate
    @param name - name of candidate
    @param voteCount - votes candidate has received
    */
    struct Candidate {
        uint id;
        string name;
        uint256 voteCount;
    }

    // Total number of canditates
    uint public candidatesCount;
    bool public isVotingAllowed;

    /**
    @notice mappings registering voters and canditates
    */
    mapping(address => bool) public voters;
    mapping(uint => Candidate) public candidates;
    mapping (string => bool) existingCandidates;

    /**
     * Custom errors to more gas efficient than regular require statements
     */
    error CandidateAlreadyAdded();
    error VotingNotActive();
    error NotRegisteredVoter();
    error InvalidCandidate();
    error VotingNotEnded();
    error CandidateNameEmpty();

    constructor() {}

    /**
    @notice function that can be called only by the owner of contract and allow address to vote by adding it to mapping of voters
    @param _voter - address that will be able to vote for candidate
    */
    function addVoter(address _voter) external onlyOwner {
        voters[_voter] = true;
    }

    /**
    @notice function that can be called only by the owner of contract and register Canditate voters can vote for
    @ _name - name of the canditate 
    */
    function addCandidate(string memory _name) external onlyOwner {
    // Checks if the candidate name is not empty
    //require(bytes(_name).length > 0, "Candidate name cannot be empty.");
    if (bytes(_name).length == 0) revert CandidateNameEmpty();
    // Checks if the candidate is already added
    //require(!existingCandidates[_name], "This candidate is already added.");
    if (existingCandidates[_name]) revert CandidateAlreadyAdded();

    candidatesCount++;
    candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);

    // Marks this candidate as added
    existingCandidates[_name] = true;
    }

    /**
    @notice external function vote only registered voters are able to vote for candidate reentrancy attacks are prevented by modifier nonReentrant -> mutex patter
    @param _candidateId -> id of candidate voter wants to vote for 
    */
    function vote(uint _candidateId) external nonReentrant {
        //require(isVotingAllowed, "Voting is not active");
        if (!isVotingAllowed) revert VotingNotActive();
        //require(voters[msg.sender], "Only registered voters can vote.");
        if (!voters[msg.sender]) revert NotRegisteredVoter();
        //require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate.");
        if (!(_candidateId > 0 && _candidateId <= candidatesCount)) revert InvalidCandidate();

        voters[msg.sender] = false; // to prevent double voting & reentrancy

        candidates[_candidateId].voteCount++;
    }

    /**
    @notice external view function returns the name of winning candidate
    */
    function winner() external view returns (string memory, uint256) {
        //require(!isVotingAllowed, "Voting is not ended");
        if (isVotingAllowed) revert VotingNotEnded();

        uint maxVote = 0;
        string memory winnerName;
        for (uint i = 1; i <= candidatesCount; i++) {
            if (candidates[i].voteCount > maxVote) {
                maxVote = candidates[i].voteCount;
                winnerName = candidates[i].name;
            }
        }
        return (winnerName, maxVote);
    }

    /**
    @notice external function that can be called only by owner and starts voting
    */
    function startVoting() external onlyOwner {
        isVotingAllowed = true;
    }

    /**
    @notice external function that can be called only by owner and ends voting
    */
    function endVoting() external onlyOwner {
        isVotingAllowed = false;
    }
}