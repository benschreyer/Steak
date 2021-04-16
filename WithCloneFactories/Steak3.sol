// SPDX-License-Identifier: MIT
/*
MIT License
Copyright (c) 2021 Benjamin Schreyer
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice (including the next paragraph) shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

//Last updated 4/1/2021
//bensch
//Kovan Test Network contract to facilitate purchase of Numerai model submission for a buyer Numerai account 

//Note 4/1/2021 currently late sub.s is checked by a failure of a node to callback because Numerai returned null to an API call for pending payout,
//this works now, but if nodes ever switch to taking null to be 0 this will not work and late submissions will be accepted which is an error.

// COMPILE WITH ENABLE OPTIMIZATION AT 800 RUNS SO IT IS SMALL ENOUGH FOR ETH

pragma solidity ^0.6.0;

import "https://raw.githubusercontent.com/smartcontractkit/chainlink/develop/evm-contracts/src/v0.6/ChainlinkClient.sol";

contract Steak is ChainlinkClient {
    

    
    mapping(bytes32 => int256) public dataAPI;

    
    
    
    event Constructed(string, uint256, uint256);
  
    event BuyerModelNameRegistered(string, uint256);
    
    event Kicked(string);
  
    event Locked(string, string);
    
    event Claimed(int256, int256, int256, int256, int256, int256);
    
    event Reclaimed();
    
    //bensch Kovan Test Network wallet for 1% fee
    address payable public bensch = 0xa9187C8C9f692Fe2ca6b80069e87dF23b34157A3;
    
    //Name of the models on Numerai tournament
    string public sellerModelName;
    string public buyerModelName;

    uint256 public callbackCount = 0;

    bytes32 public buyerCorrelationRequestId;
    bytes32 public sellerCorrelationRequestId;

    bytes32 public sellerLatestRoundRequestId;
    bytes32 public buyerLatestRoundRequestId;
    bytes32 public numeraiLatestRoundRequestId;
    
    bytes32 public sellerStakeRequestId;


    
    //Seconds since Unix epoch
    uint256 public startTimestamp;
  
    //Who deployed the contract and who engaged the contract
    address payable public owner;
    address payable public buyer;
    
    //Orcale, jobId, and fee for getting float
    address public oracleInt = 0x1b666ad0d20bC4F35f218120d7ed1e2df60627cC;
    bytes32 public jobIdInt = "553d941199004ceca20542cffd9c8555";
    uint256 public feeInt = 0.05 * 10 ** 18;
    

    
    //Total fee needed for full contract execution
    uint256 public totalFee = 8 * feeInt;
    
    //State variables
    //locked: buyer cannot be kicked from the contract, contract cannot receive payment, model names cannot be changed. Contract must be locked but unverified for a refund request to go through
    bool public locked;
    //verified: allows contract owner to collect payment, should only be true after submissions are found to have matching performance on live and stake promise met by data scientist
    bool public verified;
    

    //UNIX stamp for contract construction
    uint public birthStamp;
    
    //Cost to buy sumbissions
    uint256 public costETH;
    
    uint256 public sellerStakePromise;
    
    
    /**
     * Network: Kovan
     * Oracle: Chainlink - https://market.link/nodes/ef076e87-49f4-486b-9878-c4806781c7a0/adapters?network=42
     * Job ID: Chainlink - https://market.link/jobs/c2387021-cf1c-44a0-ae79-66fcdf39cff3?network=42
     * Fee: 0.1 LINK
     */
     
    //Seller of the submission A.K.A. data scientist constructs the contract promising to stake _sellerStakePromise NMR on their submission on _sellerModelName and expects atleast _costETH ethereum for their submission
    //Note 1 Ethereum is represented on the block chain as an unsigned integer with value of 10 ** 18 or 10 ^ 18 or 1000000000000000000, the same is true for LINK and NMR
    constructor(string memory _sellerModelName, uint256 _costETH,uint256 _sellerStakePromise) public 
    {


        birthStamp = now;
        //payout pending must have non 0 value to ensure verification
        require(_sellerStakePromise >= 10000000000000000,"Data scientist must stake atleast 0.01 NMR for verification purposes");



        //state variables
        locked = false;
        verified = false;
        
        //Store cost and promises by data scientist
        costETH = _costETH;
        sellerModelName = _sellerModelName;
        sellerStakePromise = _sellerStakePromise;
        
        //Give ownership to contract creator
        owner = msg.sender;
        
        //Chainlink setup
        setPublicChainlinkToken();
        
        emit Constructed(sellerModelName, costETH, sellerStakePromise);

    }
    
    
    
    
    //Buyer enters agreement to get sellerModelName submissions for the upcoming round by calling this function with atleast costETH payment to be payed to the data scientist upon verification
    function registerBuyerModelName(string memory _buyerModelName) payable public
    {
        uint tempStamp = now;
        
        require(msg.sender != owner, "Data scientist can not enter their own contract.");
        require(buyer == address(0), "Contract already has buyer.");
        require(msg.value >= costETH,"Insufficient ETH sent to enter contract.");
        //require((getWeekday(tempStamp) == 6 && getHour(tempStamp) > 17) || (getWeekday(tempStamp) == 0),"Contract can only be entered by buyer between Saturday 18:00 UTC and Sunday 24:00 UTC");
        
        require(!locked, "Cannot register buyerModelName on locked contract.");

        require(bytes(_buyerModelName).length != 0,"Model name must not be empy/NULL string.");
        
        require(bytes(buyerModelName).length == 0, "Model must not already have buyerModelName.");

        buyer = msg.sender;
        
        verified = false;
        
        
        buyerModelName = _buyerModelName;
        startTimestamp = tempStamp;
        
        emit BuyerModelNameRegistered(buyerModelName, msg.value);
    }
   
    
    
    
    
    //Data scientist can kick a user out of a contract if it has not been locked in
    function kick() public returns (bool success)
    {
        uint tempStamp = now;
        
        
        require(msg.sender == owner, "Only owner can kick from contract.");
        require(!locked, "Cannot kick locked contract.");
        require(buyer != address(0), "No buyer to kick.");
        
        
        //require((tempStamp - startTimestamp) < 158400,"Cannot kick buyer from contract that was entered by buyer over 44 hours ago.");
       // require((getWeekday(tempStamp) == 0) || (getWeekday(tempStamp) == 1 && getHour(tempStamp) < 14),"Contract buyer can only be kicked in between Sunday 00:00 UTC and Monday 14:00 UTC");
        
        buyer.transfer(address(this).balance);
        require(address(this).balance == 0, "Failed to return ETH to buyer. Cannot kick.");
        
        emit Kicked(buyerModelName);
        
        buyer = address(0);
        buyerModelName = "";
        startTimestamp = 0;
        
        return true;
    }
    
    
    
    
    //Locks in the contract, retreives the modelID to be used for submissions based off of the model name, buyer should have already provided data scientist an upload only API key (public and public)
    function lock() public returns (bool success)
    {
        uint tempStamp = now;
        
        
        require(msg.sender == owner, "Only owner can lock contract.");
        require(!locked, "Cannot lock contract that is already locked.");
        require(buyer != address(0),"No buyer to lock.");
        require(bytes(buyerModelName).length != 0,"No buyerModelName to lock.");
        //require((tempStamp - startTimestamp) < 158400,"Cannot lock contract that was entered by buyer over 44 hours ago.");
        //require((getWeekday(tempStamp) == 0) || (getWeekday(tempStamp) == 1 && getHour(tempStamp) < 14),"Contract can only be locked in between Sunday 00:00 UTC and Monday 14:00 UTC");
        
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(link.balanceOf(address(this)) >= totalFee, "Contract requires 0.1 LINK total to operate once locked, current LINK balance is under 0.1.");

        

        
        locked = true;
    
        
        
        return true;
    }
    
    function buildAndSendIntRequest(string memory get, string memory path, int256 times) public returns (bytes32 requestId)
    {
        Chainlink.Request memory ret = buildChainlinkRequest(jobIdInt, address(this), this.fulfillInt.selector);
        ret.addInt("times",times);
        ret.add("get",get);
        ret.add("path",path);
        return sendChainlinkRequestTo(oracleInt, ret, feeInt);
    }


     
    //Calls a chain of API call functions to confirm submissions are equivalent on buyer and data scientist models and updated for the most recently started round, if they are destroys the contract sending the ETH and leftover LINK to the data scientist, otherwise just send leftover LINK to the data scientist
    function claim() public returns (bool success)
    {
        uint tempStamp = now;
        
        require(msg.sender == owner, "Only the owner can trigger a payment claim.");
        require(locked, "Cannot claim an unlocked contract.");
        
        //require((getWeekday(tempStamp) == 5) || getWeekday(tempStamp) == 6 || getWeekday(tempStamp) == 0, "Contract reward can only be validated and claimed on Friday, Saturday, or Sunday UTC.");
        //require((tempStamp - startTimestamp > 345600) && (tempStamp - startTimestamp < 712800),"Must claim contract before Monday UTC of the week following the contract being engaged by the buyer and after Thursday UTC of the week the contract was engaged by the buyer. Cannot claim otherwise.");
        
        
        //TIMING COMMENTED FOR TESTING ONLY
        //require((now - startTimestamp) > 604800,"Cannot claim payment before 7 days have elapsed since reigsterBuyerModelName.");
        //require((now - startTimestamp) < 777600,"Cannot claim payment after 9 days have elapsed since reigsterBuyerModelName.");
        
        
        getInitialApiData();


        
        return true;
    }

    function getInitialApiData() public
    {



        numeraiLatestRoundRequestId = buildAndSendIntRequest("https://api-tournament.numer.ai/graphql?query={rounds{number}}","data.rounds.0.number",1);


    }

    function fulfillInt(bytes32 _requestId, int256 _APIresult) external recordChainlinkFulfillment(_requestId)
    {
        require(msg.sender == oracleInt, "only oracle can fullfil");

        dataAPI[_requestId] = _APIresult;
        
        if(callbackCount == 0)
        {
            sellerStakeRequestId = buildAndSendIntRequest(string(abi.encodePacked("https://api-tournament.numer.ai/graphql?query={v2UserProfile(username:\"",sellerModelName,"\"){totalStake}}")),
            "data.v2UserProfile.totalStake",10**18);
        }
        else if(callbackCount == 1)
        {
            sellerLatestRoundRequestId =  buildAndSendIntRequest(string(abi.encodePacked("https://api-tournament.numer.ai/graphql?query={userActivities(username:\"",sellerModelName,"\",tournament:8){roundNumber}}")),
            "data.userActivities.0.roundNumber",1);
        }
        else if(callbackCount == 2)
        {
            buyerLatestRoundRequestId = buildAndSendIntRequest(string(abi.encodePacked("https://api-tournament.numer.ai/graphql?query={userActivities(username:\"",buyerModelName,"\",tournament:8){roundNumber}}")),
            "data.userActivities.0.roundNumber",1);
        }
        else if(callbackCount == 3)
        {
            buyerCorrelationRequestId = buildAndSendIntRequest(string(abi.encodePacked("https://api-tournament.numer.ai/graphql?query={roundSubmissionPerformance(roundNumber:",uintToStr(uint256(dataAPI[numeraiLatestRoundRequestId])),",username:\"",buyerModelName,"\"){roundDailyPerformances{correlation}}}")),
            "data.roundSubmissionPerformance.roundDailyPerformances.0.correlation",10**18);
        }
        else if(callbackCount == 4)
        {
            sellerCorrelationRequestId = buildAndSendIntRequest(string(abi.encodePacked("https://api-tournament.numer.ai/graphql?query={roundSubmissionPerformance(roundNumber:",uintToStr(uint256(dataAPI[numeraiLatestRoundRequestId])),",username:\"",sellerModelName,"\"){roundDailyPerformances{correlation}}}")),
            "data.roundSubmissionPerformance.roundDailyPerformances.0.correlation",10**18);
        }
        else if(callbackCount == 5)
        {
            buildAndSendIntRequest(string(abi.encodePacked("https://api-tournament.numer.ai/graphql?query={roundSubmissionPerformance(roundNumber:",uintToStr(uint256(dataAPI[numeraiLatestRoundRequestId])),",username:\"",buyerModelName,"\"){roundDailyPerformances{payoutPending}}}")),
            "data.roundSubmissionPerformance.roundDailyPerformances.0.payoutPending",10**18);
        }
        else if(callbackCount == 6)
        {
            buildAndSendIntRequest(string(abi.encodePacked("https://api-tournament.numer.ai/graphql?query={roundSubmissionPerformance(roundNumber:",uintToStr(uint256(dataAPI[numeraiLatestRoundRequestId])),",username:\"",sellerModelName,"\"){roundDailyPerformances{payoutPending}}}")),
            "data.roundSubmissionPerformance.roundDailyPerformances.0.payoutPending",10**18);
        }
        else if(callbackCount == 7)
        {
            attemptPayout();
        }

        callbackCount++;


    }
    
    function attemptPayout() public
    {
        require(dataAPI[sellerCorrelationRequestId] == dataAPI[buyerCorrelationRequestId],"Model live correlations must match");

        require(uint256(dataAPI[sellerStakeRequestId]) >= sellerStakePromise,"Seller must stake as promised");

        require(dataAPI[sellerLatestRoundRequestId] == dataAPI[buyerLatestRoundRequestId] && dataAPI[buyerLatestRoundRequestId] == dataAPI[numeraiLatestRoundRequestId],"Latest round for both models must be latest Numerai round");


        callbackCount = 0;

        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
    
        link.transfer(owner, link.balanceOf(address(this)));
        
        
        //1% fee

        bensch.transfer(address(this).balance / 100);
        
        verified = true;
     
        emit Claimed(dataAPI[sellerCorrelationRequestId], dataAPI[buyerCorrelationRequestId], dataAPI[numeraiLatestRoundRequestId], dataAPI[buyerLatestRoundRequestId], dataAPI[sellerLatestRoundRequestId], dataAPI[sellerStakeRequestId]);
                
        owner.transfer(address(this).balance);

        require(address(this).balance <= 0);
        
        locked = false;
        buyer = address(0);
        buyerModelName = "";
        startTimestamp = 0;
        
        
            
        //selfdestruct(owner);
    }

    
    //Allows a buyer to reclaim the ETH payment if the data scientist fails to produce equivalent live performance on both parties models
    function reclaim() public returns (bool success)
    {
        uint tempStamp = now;
        //require(tempStamp - startTimestamp > 712800, "Must wait 198 hours (8.25 days) from buyer model name registration to reclaim failed contract.");
        //require(((tempStamp - startTimestamp > 345600) && ((getWeekday(tempStamp) == 1) || (getWeekday(tempStamp) == 2))) || tempStamp - startTimestamp > 712800 ,"Cannot claim contract before Monday of the week following the round.");
        require(msg.sender == buyer, "Only the buyer can trigger a payment reclaim.");
        require(!verified, "Cannot reclaim verified contract.");
        require(startTimestamp > 0,"Contract must have been started to be reclaimed");

        //TIMING COMMENTED FOR TESTING ONLY
        //require((now - startTimestamp) > 777600, "Cannot reclaim contract payment before 9 days have elapsed since registerBuyerModelName.");
        
        
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
  
        link.transfer(owner, link.balanceOf(address(this)));
        
        emit Reclaimed();
        
        buyer.transfer(address(this).balance);

        require(address(this).balance <= 0);
        
        locked = false;

        
        buyer = address(0);
        buyerModelName = "";
        startTimestamp = 0;
        
        
        return true;
    }
    
    
    

    
    function bytes32ToString(bytes32 _toString) internal pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && _toString[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _toString[i] != 0; i++) {
            bytesArray[i] = _toString[i];
        }
        return string(bytesArray);
    }
    
        /// @notice converts number to string
    /// @dev source: https://github.com/provable-things/ethereum-api/blob/master/oraclizeAPI_0.5.sol#L1045
    /// @param _i integer to convert
    /// @return _uintAsString
    function uintToStr(uint _i) internal pure returns (string memory _uintAsString) {
        uint number = _i;
        if (number == 0) {
            return "0";
        }
        uint j = number;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (number != 0) {
            bstr[k--] = byte(uint8(48 + number % 10));
            number /= 10;
        }
        return string(bstr);
    }
    
     /*
         *  Date and Time utilities for ethereum contracts
         * https://github.com/pipermerriam/ethereum-datetime/blob/master/contracts/DateTime.sol
         */


        uint constant DAY_IN_SECONDS = 86400;




        function getHour(uint timestamp) public pure returns (uint) {
                return uint((timestamp / 60 / 60) % 24);
        }

        function getMinute(uint timestamp) public pure returns (uint) {
                return uint((timestamp / 60) % 60);
        }

        function getSecond(uint timestamp) public pure returns (uint) {
                return uint(timestamp % 60);
        }

        function getWeekday(uint timestamp) public pure returns (uint) {
                return uint((timestamp / DAY_IN_SECONDS + 4) % 7);
        }


       
        


}
