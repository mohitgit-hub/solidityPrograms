// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Vote {


    struct Voter {
        string name;
        uint age;
        uint voterId;
        Gender gender;
        uint voteCandidateId;
        address voterAddress;
    }


    struct Candidate {
        string name;
        string party;
        uint age;
        Gender gender;
        uint candidateId;
        address candidateAddress;
        uint votes;
    }


    address electionCommission;
    address public winner;
    uint nextVoterId = 1;
    uint nextCandidateId = 1;
    uint startTime;
    uint endTime;
    bool stopVoting;


    mapping(uint => Voter) voterDetails;
    mapping(uint => Candidate) candidateDetails;


    enum VotingStatus {NotStarted, InProgress, Ended}
    enum Gender {NotSpecified, Male, Female, Other}


    constructor() {
        electionCommission = msg.sender;
    }


    modifier isVotingOver() {
        require(block.timestamp  < endTime && stopVoting == false,"Voting is over" );
      _;
    }


    modifier onlyCommissioner() {
        require(electionCommission == msg.sender,"You're not Election Commission");
        _;
    }

    modifier isValidAge(uint _age) {
        require(_age >= 18,"Your Age Is Not Valid");
        _;
    }
    

    function registerCandidate(
        string calldata _name,
        string calldata _party,
        uint _age,
        Gender _gender
    ) external isValidAge(_age) {
        require(isCandidateNotRegistered(msg.sender),"You're already Registered");
        require(msg.sender != electionCommission,"You're Not Allowed To Register");
        require(nextCandidateId <3,"Maximum Candidate Registered");
        
       candidateDetails[nextCandidateId] = Candidate ( {
        name : _name,
        party : _party,
        age : _age,
        gender : _gender,
        candidateAddress : msg.sender,
        candidateId : nextCandidateId,
        votes:0
        
       } );
       nextCandidateId++;
       
    }


    function isCandidateNotRegistered(address _person) internal view returns (bool) {
        for (uint i = 1; i < nextCandidateId;i ++) {
            if (candidateDetails[i].candidateAddress == _person) {
                return false;
            }
        }
         return true;
           
    }


    function getCandidateList() public view returns (Candidate[] memory) {
       Candidate [] memory candidateList = new Candidate [] (nextCandidateId -1);
         for(uint i = 0; i < candidateList.length;i++) {
            candidateList[i] = candidateDetails[i+1];
         }
         return candidateList;
    }


    function isVoterNotRegistered(address _person) internal view returns (bool) {
        for (uint i = 0; i < nextVoterId;i++) {
            if(voterDetails[i].voterAddress == _person) {
                return false;
            }
        }
        return true;
    }


    function registerVoter(
        string calldata _name,
        uint _age,
        Gender _gender
    ) external isValidAge (_age){
        require(isVoterNotRegistered(msg.sender),"You're Already Registered");
        

        voterDetails[nextVoterId] = Voter ({
           name : _name,
         age : _age,
         voterId : nextVoterId,
         gender : _gender,
         voteCandidateId: 0,
         voterAddress : msg.sender
        });
            nextVoterId++;

    }


    function getVoterList() public view returns (Voter[] memory) {
        Voter [] memory voterList = new Voter [] (nextVoterId-1);
        for(uint i = 0;i < voterList.length;i++) {
        voterList[i] = voterDetails[i+1];
    }
     return voterList;
    }


    function castVote(uint _voterId, uint _candidateId) external {
      require(block.timestamp >= startTime && block.timestamp <= endTime,"Voting time is invalid");  
      require(voterDetails[_voterId].voteCandidateId == 0,"You've already voted");
      require(voterDetails[_voterId].voterAddress == msg.sender,"Your Address is invalid" );   
      require(_candidateId >= 1 && _candidateId < 3);


      voterDetails[_voterId].voteCandidateId = _candidateId;
      candidateDetails[_candidateId].votes++;
    }


    function setVotingPeriod(uint _startTime, uint _endTime) external onlyCommissioner() {
        startTime = block.timestamp + _startTime;
        endTime = startTime + _endTime;
    }


    function getVotingStatus() public view returns (VotingStatus) {
            if(startTime == 0 ) {
                return VotingStatus.NotStarted;
            }
            else if (endTime > block.timestamp && stopVoting == false) {
                return VotingStatus.InProgress;
            }
            else {
                return VotingStatus.Ended;
            }
    }


    function announceVotingResult() external onlyCommissioner() {
            uint max = 0;
            for (uint i = 1; i < nextCandidateId;i++) {
                if(candidateDetails[i].votes > max) {
                    max = candidateDetails[i].votes;
                    winner = candidateDetails[i].candidateAddress;
                }
            }
    }


    function emergencyStopVoting() public onlyCommissioner() {
       stopVoting = true;
    }
}
