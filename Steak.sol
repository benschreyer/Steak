// SPDX-License-Identifier: MIT
/*
MIT License
Copyright (c) 2021 Benjamin Schreyer
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice (including the next paragraph) shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

//Last updated 3/28/2021
//bensch
//Kovan Test Network contract to facilitate purchase of Numerai model submission for a buyer Numerai account 

// COMPILE WITH ENABLE OPTIMIZATION AT 200 RUNS SO IT IS SMALL ENOUGH FOR ETH

pragma solidity ^0.6.0;

import "https://raw.githubusercontent.com/smartcontractkit/chainlink/develop/evm-contracts/src/v0.6/ChainlinkClient.sol";

contract Steak is ChainlinkClient {
    

    
    
    
    
    event Constructed(string, uint256, uint256);
  
    event BuyerModelNameRegistered(string, uint256);
    
    event Kicked(string);
  
    event Locked(string, string);
    
    event Claimed(int256, int256, int256, int256, int256, int256, uint256, uint256, uint256, uint256);
    
    event Reclaimed();
    
    //bensch Kovan Test Network wallet
    address payable private bensch = 0xa9187C8C9f692Fe2ca6b80069e87dF23b34157A3;
    
    //Name of the models on Numerai tournament
    string public dataScientistModelName;
    string public buyerModelName;
    
    
    string[2] public modelNames;
    //Numerai Model ID which is used to upload via Numerapi or similar
    string public dataScientistModelId;
    string public buyerModelId;
    
    //Cost of submission of model for the week
    uint256 public costETH;
    
    //Data Scientist promises to stake this much on their model
    uint256 public dataScientistStakePromise;
    
    //To store the actual stake of the data scientist after round scores have been released
    uint256 public dataScientistStakeActual;
    
    //To store the most recent submission round for both parties
    uint256[2] public latestSubmissionRounds;
    
    //Counter to aid in writing each submission round to latestSubmissionRounds
    uint256 public latestSubmissionCounter;
    
    //Official round number reported by Numerai
    uint256 public roundNumber;
    
    //Store fire live performance stat of each model (Listed below CORR, MMC, FNC)
    int256[6] public metrics;
    uint256 metricsCounter;

    //Ensure both submissions are on time by requiring they have pending payout
    
    int256[2] public payoutPending;
    uint256 payoutPendingCounter;

    
    //Hold name of metrics to enable clean retreival of live performance for verification of contract success
    string[3] public metricNames;
    
    //Seconds since Unix epoch
    uint256 public startTimestamp;
  
    //Who deployed the contract and who engaged the contract
    address payable public owner;
    address payable public buyer;
    
    //Orcale, jobId, and fee for getting the buyer's mode Id
    address private oracleBuyerModelId;
    bytes32 private jobIdBuyerModelId;
    uint256 private feeBuyerModelId;
    
    //Orcale, jobId, and fee for getting float
    address private oracleFloat;
    bytes32 private jobIdFloat;
    uint256 private feeFloat;
    
    //Orcale, jobId, and fee for getting uint
    address private  oracleUint;
    bytes32 private  jobIdUint;
    uint256 private  feeUint;
    
    //Total fee needed for full contract execution
    uint256 public totalFee;
    
    //State variables
    //locked: buyer cannot be kicked from the contract, contract cannot receive payment, model names cannot be changed. Contract must be locked but unverified for a refund request to go through
    bool public locked;
    //verified: allows contract owner to collect payment, should only be true after submissions are found to have matching performance on live and stake promise met by data scientist
    bool public verified;
    

    //UNIX stamp for contract construction
    uint public birthStamp;
    
    /**
     * Network: Kovan
     * Oracle: Chainlink - https://market.link/nodes/ef076e87-49f4-486b-9878-c4806781c7a0/adapters?network=42
     * Job ID: Chainlink - https://market.link/jobs/c2387021-cf1c-44a0-ae79-66fcdf39cff3?network=42
     * Fee: 0.1 LINK
     */
     
    //Seller of the submission A.K.A. data scientist constructs the contract promising to stake _dataScientistStakePromise NMR on their submission on _dataScientistModelName and expects atleast _costETH ethereum for their submission
    //Note 1 Ethereum is represented on the block chain as an unsigned integer with value of 10 ** 18 or 10 ^ 18 or 1000000000000000000, the same is true for LINK and NMR
    constructor(string memory _dataScientistModelName, uint256 _costETH,uint256 _dataScientistStakePromise) public 
    {

        birthStamp = now;

        //payout pending must have non 0 value to ensure verification
        require(_dataScientistStakePromise >= 10000000000000000,"Data scientist must stake atleast 0.01 NMR for verification purposes");
        //Set to zero since it is atleast extremely rare to get exactly 0 payout so there should almost never be a time where the submission was on time but a refund is granted
        payoutPending = [0, 0];
        payoutPendingCounter = 0;

        //Not a possible stake value on Numer.ai, used to give the variable a value for being unitialized
        dataScientistStakeActual = 1;
        //state variables
        locked = false;
        verified = false;
        
        //Store cost and promises by data scientist
        costETH = _costETH;
        dataScientistModelName = _dataScientistModelName;
        dataScientistStakePromise = _dataScientistStakePromise;
        
        //Give ownership to contract creator
        owner = msg.sender;
        
        //Chainlink setup
        setPublicChainlinkToken();
        
        //Orcale, jobId, and fee for getting the buyer's mode Id
        oracleBuyerModelId = 0xAA1DC356dc4B18f30C347798FD5379F3D77ABC5b;
        jobIdBuyerModelId = "b7285d4859da4b289c7861db971baf0a";
        feeBuyerModelId = 0.1 * 10 ** 18;
        
        //Orcale, jobId, and fee for getting float
        oracleFloat = 0xAA1DC356dc4B18f30C347798FD5379F3D77ABC5b;
        jobIdFloat = "50d7bca4dcf7462a83e7282b62646466";
        feeFloat = 0.1 * 10 ** 18;
        
        //Orcale, jobId, and fee for getting uint
        oracleUint = 0xAA1DC356dc4B18f30C347798FD5379F3D77ABC5b;
        jobIdUint = "c7dd72ca14b44f0c9b6cfcd4b7ec0a2c";
        feeUint = 0.1 * 10 ** 18;
        
        //Total fee needed for full contract execution
        totalFee = feeBuyerModelId + 8 * feeFloat + 4 * feeUint;

        
        //Holds what should be latest submission round for both parties
        latestSubmissionRounds = [2,1];
        latestSubmissionCounter = 0;
        
        //Metrics for each party correlation, mmc, fnc
        metrics = [-1, -1, -1, 1, 1, 1];
        metricsCounter = 0;
        
        metricNames = ["correlation", "mmc", "fnc"];
        
        emit Constructed(dataScientistModelName, costETH, dataScientistStakePromise);

    }
    
    
    
    
    //Buyer enters agreement to get dataScientistModelName submissions for the upcoming round by calling this function with atleast costETH payment to be payed to the data scientist upon verification
    function registerBuyerModelName(string memory _buyerModelName) payable public
    {
        uint tempStamp = now;
        
        require(msg.sender != owner, "Data scientist can not enter their own contract.");
        require(buyer == address(0), "Contract already has buyer.");
        require(msg.value >= costETH,"Insufficient ETH sent to enter contract.");
        require((getWeekday(tempStamp) == 6 && getHour(tempStamp) > 17) || (getWeekday(tempStamp) == 0),"Contract can only be entered by buyer between Saturday 18:00 UTC and Sunday 24:00 UTC");
        
        require(!locked, "Cannot register buyerModelName on locked contract.");

        buyer = msg.sender;
        
        bytes memory tempStringAsBytes = bytes(_buyerModelName);
        require(tempStringAsBytes.length != 0,"Model name must not be empy/NULL string.");
        
        bytes memory tempStringAsBytes2 = bytes(buyerModelName);
        require(tempStringAsBytes2.length == 0, "Model must not already have buyerModelName.");
        
        
        

        
        buyerModelName = _buyerModelName;
        startTimestamp = tempStamp;
        modelNames = [buyerModelName, dataScientistModelName];
        
        emit BuyerModelNameRegistered(buyerModelName, msg.value);
    }
   
    
    
    
    
    //Data scientist can kick a user out of a contract if it has not been locked in
    function kick() public returns (bool success)
    {
        uint tempStamp = now;
        
        
        require(msg.sender == owner, "Only owner can kick from contract.");
        require(!locked, "Cannot kick locked contract.");
        require(buyer != address(0), "No buyer to kick.");
        
        
        require((tempStamp - startTimestamp) < 158400,"Cannot kick buyer from contract that was entered by buyer over 44 hours ago.");
        require((getWeekday(tempStamp) == 0) || (getWeekday(tempStamp) == 1 && getHour(tempStamp) < 14),"Contract buyer can only be kicked in between Sunday 00:00 UTC and Monday 14:00 UTC");
        
        buyer.transfer(address(this).balance);
        require(address(this).balance == 0, "Failed to return ETH to buyer. Cannot kick.");
        
        emit Kicked(buyerModelName);
        
        buyer = address(0);
        buyerModelName = "";
        startTimestamp = 0;
        
        return true;
    }
    
    
    
    
    //Locks in the contract, retreives the modelID to be used for submissions based off of the model name, buyer should have already provided data scientist an upload only API key (private and public)
    function lock() public returns (bool success)
    {
        uint tempStamp = now;
        
        
        require(msg.sender == owner, "Only owner can lock contract.");
        require(!locked, "Cannot lock contract that is already locked.");
        require(buyer != address(0),"No buyer to lock.");
        bytes memory tempStringAsBytes = bytes(buyerModelName);
        require(tempStringAsBytes.length != 0,"No buyerModelName to lock.");
        require((tempStamp - startTimestamp) < 158400,"Cannot lock contract that was entered by buyer over 44 hours ago.");
        require((getWeekday(tempStamp) == 0) || (getWeekday(tempStamp) == 1 && getHour(tempStamp) < 14),"Contract can only be locked in between Sunday 00:00 UTC and Monday 14:00 UTC");
        
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(link.balanceOf(address(this)) >= totalFee, "Contract requires 0.1 LINK total to operate once locked, current LINK balance is under 0.1.");

        

        
        locked = true;
        
        getBuyerModelId();
        
        
        
        return true;
    }
    
    
    
    
     //Auxilliary API call functions for lock
    function getBuyerModelId() private returns(bytes32 requestId)
    {
        Chainlink.Request memory request = buildChainlinkRequest(jobIdBuyerModelId, address(this), this.fulfillBuyerModelId.selector);
        
        request.add("get",string(abi.encodePacked("https://api-tournament.numer.ai/graphql?query={v2UserProfile(username:\"",buyerModelName,"\"){id}}")));
        request.add("path","data.v2UserProfile.id");
        
        return sendChainlinkRequestTo(oracleBuyerModelId, request, feeBuyerModelId);
    }
    
    function fulfillBuyerModelId(bytes32 _requestId, bytes32 _APIresult) external recordChainlinkFulfillment(_requestId)
    {
        validateChainlinkCallback(_requestId);
        buyerModelId = bytes32ToString(_APIresult);
        emit Locked(buyerModelName, buyerModelId);
    }
    
    
    
    
    
    //Allows a buyer to reclaim the ETH payment if the data scientist fails to produce equivalent live performance on both parties models
    function reclaim() public returns (bool success)
    {
        uint tempStamp = now;
        require(tempStamp - startTimestamp > 712800, "Must wait 198 hours (8.25 days) from buyer model name registration to reclaim failed contract.");
        require(msg.sender == buyer, "Only the buyer can trigger a payment reclaim.");
        require(!verified, "Cannot reclaim verified contract.");
        

        //TIMING COMMENTED FOR TESTING ONLY
        //require((now - startTimestamp) > 777600, "Cannot reclaim contract payment before 9 days have elapsed since registerBuyerModelName.");
        
        
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
  
        link.transfer(owner, link.balanceOf(address(this)));
        
        emit Reclaimed();
        
        selfdestruct(buyer);
        return true;
    }
    
    
    
    
    //Calls a chain of API call functions to confirm submissions are equivalent on buyer and data scientist models and updated for the most recently started round, if they are destroys the contract sending the ETH and leftover LINK to the data scientist, otherwise just send leftover LINK to the data scientist
    function claim() public returns (bool success)
    {
        uint tempStamp = now;
        
        require(msg.sender == owner, "Only the owner can trigger a payment claim.");
        require(locked, "Cannot claim an unlocked contract.");
        
        require((getWeekday(tempStamp) == 5) || getWeekday(tempStamp) == 6 || getWeekday(tempStamp) == 0, "Contract reward can only be validated and claimed on Friday, Saturday, or Sunday UTC.");
        require((tempStamp - startTimestamp > 345600) && (tempStamp - startTimestamp < 712800),"Must claim contract before Monday UTC of the week following the contract being engaged by the buyer and after Thursday UTC of the week the contract was engaged by the buyer. Cannot claim otherwise.");
        
        
        //TIMING COMMENTED FOR TESTING ONLY
        //require((now - startTimestamp) > 604800,"Cannot claim payment before 7 days have elapsed since reigsterBuyerModelName.");
        //require((now - startTimestamp) < 777600,"Cannot claim payment after 9 days have elapsed since reigsterBuyerModelName.");
        
        
        latestSubmissionCounter = 0;
        metricsCounter = 0;
        getDataScientistStake();
        latestSubmissionCounter = 0;
        metricsCounter = 0;


        
        return true;
    }
    
    
    
    
    
    
    //Start of API call and callback chain to verify contract conditiosn before payout
     function getDataScientistStake() private returns(bytes32 requestId)
    {
        Chainlink.Request memory request = buildChainlinkRequest(jobIdUint, address(this), this.fulfillDataScientistStake.selector);
        
        //dataScientistModelName = string(abi.encodePacked("https://api-tournament.numer.ai/graphql?query={roundSubmissionPerformance(latestSubmissionRound:",uintToStr(latestSubmissionRound),",username:\"",buyerModelName,"\"){roundDailyPerformances{correlation}}}"));
        request.add("get",string(abi.encodePacked("https://api-tournament.numer.ai/graphql?query={v2UserProfile(username:\"",dataScientistModelName,"\"){totalStake}}")));
        request.add("path","data.v2UserProfile.totalStake");
        request.addInt("times", 10**18);
        
        return sendChainlinkRequestTo(oracleUint, request, feeUint);
    }
    
    
    
    function fulfillDataScientistStake(bytes32 _requestId, uint256 _APIresult) external recordChainlinkFulfillment(_requestId)
    {
        validateChainlinkCallback(_requestId);
        dataScientistStakeActual = _APIresult;
        latestSubmissionCounter = 0;
        getLatestSubmissionRound(modelNames[latestSubmissionCounter]);


    }
    
    function getLatestSubmissionRound(string memory username) private returns(bytes32 requestId)
    {
        
        Chainlink.Request memory request = buildChainlinkRequest(jobIdUint, address(this), this.fulfillLatestSubmissionRound.selector);
        
        //dataScientistModelName = string(abi.encodePacked("https://api-tournament.numer.ai/graphql?query={roundSubmissionPerformance(latestSubmissionRound:",uintToStr(latestSubmissionRound),",username:\"",buyerModelName,"\"){roundDailyPerformances{correlation}}}"));
        request.add("get",string(abi.encodePacked("https://api-tournament.numer.ai/graphql?query={userActivities(username:\"",username,"\",tournament:8){roundNumber}}")));
        request.add("path","data.userActivities.0.roundNumber");
        request.addInt("times", 1);
        
        return sendChainlinkRequestTo(oracleUint, request, feeUint);
    }
    
    
    
    function fulfillLatestSubmissionRound(bytes32 _requestId, uint256 _APIresult) external recordChainlinkFulfillment(_requestId)
    {
        validateChainlinkCallback(_requestId);
        latestSubmissionRounds[latestSubmissionCounter] = _APIresult;
        latestSubmissionCounter++;
        if(latestSubmissionCounter == 1)
        {
            getLatestSubmissionRound(modelNames[latestSubmissionCounter]);
        }
        else
        {
            latestSubmissionCounter = 0;
            getRoundNumber();
        }

    }

    function getRoundNumber() private returns(bytes32 requestId)
    {
        Chainlink.Request memory request = buildChainlinkRequest(jobIdUint, address(this), this.fulfillRoundNumber.selector);
        
        //dataScientistModelName = string(abi.encodePacked("https://api-tournament.numer.ai/graphql?query={roundSubmissionPerformance(latestSubmissionRound:",uintToStr(latestSubmissionRound),",username:\"",buyerModelName,"\"){roundDailyPerformances{correlation}}}"));
        request.add("get","https://api-tournament.numer.ai/graphql?query={rounds{number}}");
        request.add("path","data.rounds.0.number");
        request.addInt("times", 1);
        
        return sendChainlinkRequestTo(oracleUint, request, feeUint);
    }
    
    
    
    function fulfillRoundNumber(bytes32 _requestId, uint256 _APIresult) external recordChainlinkFulfillment(_requestId)
    {
        validateChainlinkCallback(_requestId);
        roundNumber = _APIresult;
        require(roundNumber == latestSubmissionRounds[0] && latestSubmissionRounds[0] == latestSubmissionRounds[1],"All submissions on models must be current round and equal.");
        
        getPayoutPending();
    }
    

    function getPayoutPending() private returns(bytes32 requestId)
    {
        Chainlink.Request memory request = buildChainlinkRequest(jobIdFloat, address(this), this.fulfillGetPayoutPending.selector);
        string memory username;
        if(payoutPendingCounter == 0)
        {
             username = buyerModelName;
        }
        else
        {
            username = dataScientistModelName;
        }
        uint _roundNumber = roundNumber;
        request.add("get",string(abi.encodePacked("https://api-tournament.numer.ai/graphql?query={roundSubmissionPerformance(roundNumber:",uintToStr(_roundNumber),",username:\"",username,"\"){roundDailyPerformances{payoutPending}}}")));
        
        request.add("path","data.roundSubmissionPerformance.roundDailyPerformances.0.payoutPending");

        request.addInt("times", 10 ** 18);
        
        return sendChainlinkRequestTo(oracleFloat, request, feeFloat);
    }
    function fulfillGetPayoutPending(bytes32 _requestId, int256 _APIresult) external recordChainlinkFulfillment(_requestId)
    {
        validateChainlinkCallback(_requestId);
        payoutPending[payoutPendingCounter] = _APIresult;
        if(payoutPendingCounter >= 1)
        {
            payoutPendingCounter = 0;
            getMetricFloat();
        }
        else
        {
            payoutPendingCounter++;
            getPayoutPending();
        }
    }

    function getMetricFloat() private returns(bytes32 requestId)
    {
 
        Chainlink.Request memory request = buildChainlinkRequest(jobIdFloat, address(this), this.fulfillFloat.selector);
        
        //-1 FOR TESTING ONLY
        uint _roundNumber = roundNumber;
        string memory username;
        if(metricsCounter > 2)
        {
            username = buyerModelName;
        }
        else
        {
            username = dataScientistModelName;
        }
        string memory metric;
        
        metric = metricNames[metricsCounter % 3];
        

        request.add("get",string(abi.encodePacked("https://api-tournament.numer.ai/graphql?query={roundSubmissionPerformance(roundNumber:",uintToStr(_roundNumber),",username:\"",username,"\"){roundDailyPerformances{",metric,"}}}")));
        
        request.add("path",string(abi.encodePacked("data.roundSubmissionPerformance.roundDailyPerformances.0.",metric)));

        request.addInt("times", 10 ** 18);
        
        return sendChainlinkRequestTo(oracleFloat, request, feeFloat);
    }
    
    //End of API call and callback chain
    function fulfillFloat(bytes32 _requestId, int256 _APIresult) external recordChainlinkFulfillment(_requestId)
    {
        validateChainlinkCallback(_requestId);
        metrics[metricsCounter] = _APIresult;
        metricsCounter++;
        if(metricsCounter == 6)
        {
            metricsCounter = 0;
            latestSubmissionCounter = 0;
            //mmc corr fnc

            if(metrics[0] == metrics[3] && metrics[1] == metrics[4] &&  metrics[2] == metrics[5] && roundNumber == latestSubmissionRounds[0] && latestSubmissionRounds[0] == latestSubmissionRounds[1] && dataScientistStakeActual >= dataScientistStakePromise && payoutPending[0] != 0 && payoutPending[1] != 0)
            {
                verified = true;
                //require(latestSubmissionRounds[0] == latestSubmissionRounds[1] && roundNumber == latestSubmissionRounds[0]);
            
                LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
    
                link.transfer(owner, link.balanceOf(address(this)));
                //COMMENT FOR TEST
                
                emit Claimed(metrics[0], metrics[1], metrics[2], metrics[3], metrics[4], metrics[5], roundNumber, latestSubmissionRounds[0], latestSubmissionRounds[1], dataScientistStakeActual);
                
                //1% fee if the contract is successfull
                bensch.transfer(address(this).balance / 100);
                
                selfdestruct(owner);
            }
            else
            {
                verified = false;
                //require(latestSubmissionRounds[0] == latestSubmissionRounds[1] && roundNumber == latestSubmissionRounds[0]);
                
                
                LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
    
                link.transfer(owner, link.balanceOf(address(this)));
                
                emit Claimed(metrics[0], metrics[1], metrics[2], metrics[3], metrics[4], metrics[5], roundNumber, latestSubmissionRounds[0], latestSubmissionRounds[1], dataScientistStakeActual);

            }
           
        }
        else
        {
            getMetricFloat();
        }
    }
    
    
    
   
    
    
    
   
    
    //Stack overflow copy pasted utility functions ;]
    
    //Convert a bytes32 to a string
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
