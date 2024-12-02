
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {
    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    struct Voter {
        bool voted;
        uint vote;
        bool registered;
    }

    address public admin;
    uint public candidateCount;
    bool public votingEnded;

    mapping(address => Voter) public voters;
    mapping(uint => Candidate) public candidates;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier votingActive() {
        require(!votingEnded, "Voting has ended");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function registerVoter(address _voter) public onlyAdmin {
        require(!voters[_voter].registered, "Voter already registered");
        voters[_voter] = Voter(false, 0, true);
    }

    function addCandidate(string memory _name) public onlyAdmin {
        candidateCount++;
        candidates[candidateCount] = Candidate(candidateCount, _name, 0);
    }

    function vote(uint _candidateId) public votingActive {
        require(voters[msg.sender].registered, "Not a registered voter");
        require(!voters[msg.sender].voted, "Already voted");
        require(_candidateId > 0 && _candidateId <= candidateCount, "Invalid candidate");

        voters[msg.sender].voted = true;
        voters[msg.sender].vote = _candidateId;
        candidates[_candidateId].voteCount++;
    }

    function endVoting() public onlyAdmin {
        votingEnded = true;
    }

    function getWinner() public view returns (string memory winnerName, uint winnerVoteCount) {
        require(votingEnded, "Voting is not yet ended");
        
        uint maxVotes = 0;
        for (uint i = 1; i <= candidateCount; i++) {
            if (candidates[i].voteCount > maxVotes) {
                maxVotes = candidates[i].voteCount;
                winnerName = candidates[i].name;
                winnerVoteCount = maxVotes;
            }
        }
    }
}
