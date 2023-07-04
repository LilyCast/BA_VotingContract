// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VotingContract {
    address public admin;
    bool public votingOpen;
    uint256 public totalTopics;

    mapping(uint256 => Topic) public topics;
    mapping(address => mapping(uint256 => bool)) public hasVoted;

    struct Topic {
        string name;
        string description;
        uint256 voteCount;
        mapping(uint256 => uint256) voteResults;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier onlyWhenVotingOpen() {
        require(votingOpen, "Voting is not open");
        _;
    }

    constructor() {
        admin = msg.sender;
        votingOpen = false;
        totalTopics = 0;
    }

    function setAdmin(address newAdmin) external onlyAdmin {
        admin = newAdmin;
    }

    function openVoting() external onlyAdmin {
        require(!votingOpen, "Voting is already open");
        votingOpen = true;
    }

    function closeVoting() external onlyAdmin {
        require(votingOpen, "Voting is already closed");
        votingOpen = false;
        settleVotes();
    }

    function addTopic(string calldata name, string calldata description) external onlyAdmin onlyWhenVotingOpen {
        uint256 topicId = totalTopics + 1;
        topics[topicId].name = name;
        topics[topicId].description = description;
        totalTopics++;
    }

    function vote(uint256 topicId, uint256 voteOption) external onlyWhenVotingOpen {
        require(topicId <= totalTopics && topicId > 0, "Invalid topic ID");
        require(!hasVoted[msg.sender][topicId], "You have already voted for this topic");

        Topic storage topic = topics[topicId];
        require(voteOption < topic.voteCount, "Invalid vote option");

        topic.voteResults[voteOption]++;
        hasVoted[msg.sender][topicId] = true;
    }

    function settleVotes() internal {
        for (uint256 i = 1; i <= totalTopics; i++) {
            Topic storage topic = topics[i];
            uint256 maxVotes = 0;
            uint256 winningOption = 0;

            for (uint256 j = 0; j < topic.voteCount; j++) {
                if (topic.voteResults[j] > maxVotes) {
                    maxVotes = topic.voteResults[j];
                    winningOption = j;
                }
            }

            // Award some rewards to the winning option
            // (You need to implement your own reward mechanism here)

            delete topic.voteResults[winningOption];
            topic.voteCount = 0;
        }
    }
}
