
/*
DO NOT COPY OR REPRODUCE THESE WORKS WITHOUT THE WRITTEN PERMISSION FROM BENJAMIN SCHREYER
COPYRIGHT BENJAMIN SCHREYER
*/
//5/23/2021 DEBUG TIMING CONDITIONS PRESENT NOT FOR REAL USE 

//Last updated 4/1/2021
//bensch
//Kovan Test Network contract to facilitate purchase of Numerai model submission for a buyer Numerai account 

//Note 4/1/2021 currently late sub.s is checked by a failure of a node to callback because Numerai returned null to an API call for pending payout,
//this works now, but if nodes ever switch to taking null to be 0 this will not work and late submissions will be accepted which is an error.

// --COMPILE WITH ENABLE OPTIMIZATION AT 800 RUNS SO IT IS SMALL ENOUGH FOR ETH-- OLD DEP.

pragma solidity ^0.6.0;

import "https://raw.githubusercontent.com/smartcontractkit/chainlink/develop/evm-contracts/src/v0.6/ChainlinkClient.sol";
import "./SteakStorage.sol";



contract SteakQuarterlyUntimed is SteakStorage, ChainlinkClient
{
    

 
    
    
    /**
     * Network: Kovan
     * market.link
     * Fee: 0.1 LINK
     */
     
    //Seller of the submission A.K.A. data scientist constructs the contract promising to stake _sellerStakePromise NMR on their submission on _sellerModelName and expects atleast _costETH ethereum for their submission
    //Note 1 Ethereum is represented on the block chain as an unsigned integer with value of 10 ** 18 or 10 ^ 18 or 1000000000000000000, the same is true for LINK and NMR
    constructor() public 
    {

        birthStamp = now;


        

        //Give ownership to contract creator
        owner = msg.sender;
        

    }
    
    function initialize(string memory _sellerModelName, uint256 _costETH,uint256 _sellerStakePromise) public
    {

        require(!locked && !initialized, "Cannot initialize a locked or initialized contract");
        require(msg.sender == owner, "Only owner can initialize");
        //payout pending must have non 0 value to ensure verification
        require(_sellerStakePromise >= 10000000000000000,"Data scientist must stake atleast 0.01 NMR for verification purposes");

        //state variables
        locked = false;

        initialized = true;        

        //Store cost and promises by data scientist
        costETH = _costETH;
        sellerModelName = _sellerModelName;
        sellerStakePromise = _sellerStakePromise;
        
        if(firstUse)
        {
            setPublicChainlinkToken();
            emit Constructed(sellerModelName, costETH, sellerStakePromise);
        }
        else
        {
            emit Reused();
        }
        
        firstUse = false;
    }
    
    function reuse()
    {
        require(msg.sender == owner, "Only owner can reuse");
        require(!firstUse,"Must initialize with arguments for first initialization.");
        require(!locked,"Cannot reuse locked contract.");

        initialized = true;
        emit Reused();
    }
    
    
    
    //Buyer enters agreement to get sellerModelName submissions for the upcoming round by calling this function with atleast costETH payment to be payed to the data scientist upon verification
    function registerBuyerModelName(string memory _buyerModelName) payable public
    {
        require(initialized,"Contract must be initialized to function");

        uint tempStamp = now;
        
        require(msg.sender != owner, "Data scientist can not enter their own contract.");
        require(buyer == address(0), "Contract already has buyer.");
        require(msg.value >= costETH,"Insufficient ETH sent to enter contract.");
        require(!locked, "Cannot register buyerModelName on locked contract.");
        require(bytes(_buyerModelName).length != 0,"Model name must not be empy/NULL string.");
        require(bytes(buyerModelName).length == 0, "Model must not already have buyerModelName.");

        //require((getWeekday(tempStamp) == 6 && getHour(tempStamp) > 17) || (getWeekday(tempStamp) == 0 || (getWeekday(tempStamp) == 1 && getHour(tempStamp) < 14)),"Contract can only be entered by buyer between Saturday 18:00 UTC and Monday 14:00 UTC");      


        buyer = msg.sender;
        buyerModelName = _buyerModelName;
        startTimestamp = tempStamp;
        

        //1% fee
        bensch.transfer(address(this).balance / 100);
        

        emit BuyerModelNameRegistered(buyerModelName, msg.value);
    }
    
    
    
    
    //Data scientist can kick a user out of a contract if it has not been locked in
    function kick() public returns (bool success)
    {
        require(initialized,"Contract must be initialized to function");
        uint tempStamp = now;
        
        
        require(msg.sender == owner, "Only owner can kick from contract.");
        require(!locked, "Cannot kick locked contract.");
        require(buyer != address(0), "No buyer to kick.");
        
        //require((tempStamp - startTimestamp) < 158400,"Cannot kick buyer from contract that was entered by buyer over 44 hours ago.");
        //require((getWeekday(tempStamp) == 0) || (getWeekday(tempStamp) == 1 && getHour(tempStamp) < 14),"Contract buyer can only be kicked in between Sunday 00:00 UTC and Monday 14:00 UTC");
        

        buyer.transfer(address(this).balance);
        require(address(this).balance == 0, "Failed to return ETH to buyer. Cannot kick.");
        

        emit Kicked(buyerModelName);
        

        buyer = address(0);
        buyerModelName = "";
        startTimestamp = 0;
        

        return true;
    }
    
    
    
    
    //Locks in the contract, buyer should have already provided data scientist an upload only API key and their model ID 
    function lock() public returns (bool success)
    {
        require(initialized,"Contract must be initialized to function");
        uint tempStamp = now;
        
        
        require(msg.sender == owner, "Only owner can lock contract.");
        require(!locked, "Cannot lock contract that is already locked.");
        require(buyer != address(0),"No buyer to lock.");
        require(bytes(buyerModelName).length != 0,"No buyerModelName to lock.");

        //require((tempStamp - startTimestamp) < 158400,"Cannot lock contract that was entered by buyer over 44 hours ago.");
        require((getWeekday(tempStamp) == 0) || (getWeekday(tempStamp) == 1 && getHour(tempStamp) < 14),"Contract can only be locked in between Sunday 00:00 UTC and Monday 14:00 UTC");
        
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(link.balanceOf(address(this)) >= totalFee, "Contract requires 0.6 LINK total to operate once locked, current LINK balance is under 0.6.");

        
        locked = true;
    

        return true;
    }
    



    //Buyer reclaim ethereum is seller doesnt start the contract
    function reclaim() public returns (bool success)
    {
        require(initialized,"Contract must be initialized to function");
        uint256 tempStamp = now;
        require(msg.sender == buyer,"Only buyer can reclaim unlocked contract");
        require(!locked,"Cannot reclaim locked contract");
        //require((getWeekday(tempStamp) == 1 && getHour(tempStamp) >= 14) || (tempStamp - startTimestamp) > 172800 || (getWeekday(tempStamp) == 2), "Can only reclaim after seller lock period");
        
        buyer.transfer(address(this).balance);
        require(address(this).balance == 0, "Failed to return ETH to buyer. Cannot kick.");

        
        emit Kicked(buyerModelName);
        
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        
        link.transfer(owner, link.balanceOf(address(this)));
        
        buyer = address(0);
        buyerModelName = "";
        startTimestamp = 0;

        sellerModelName = "";
        sellerStakePromise = 1000000000000;
        costETH = 1000000000000;

        locked = false;
        initialized = false;

        
        return true;

    }
    



    //Send a chainlink request for a signed int with a URL, json path, and multiplication to remove n decimal places
    function buildAndSendIntRequest(string memory get, string memory path, int256 times) internal returns (bytes32 requestId)
    {
        Chainlink.Request memory ret = buildChainlinkRequest(jobIdInt, address(this), this.fulfillInt.selector);


        ret.addInt("times",times);
        ret.add("get",get);
        ret.add("path",path);


        return sendChainlinkRequestTo(oracleInt, ret, feeInt);
    }




    //Send a chainlink request for a string
    function buildAndSendBytes32Request(string memory get, string memory path) internal returns (bytes32 requestId)
    {
        Chainlink.Request memory ret = buildChainlinkRequest(jobIdBytes32, address(this), this.fulfillBytes32.selector);


        ret.add("get",get);
        ret.add("path",path);


        return sendChainlinkRequestTo(oracleBytes32, ret, feeBytes32);
    }




    //Attempt to cancel contract early since seller did not submit on time, submitted other predictions, didnt stake
    function contest() public returns (bool success)
    {
        require(initialized,"Contract must be initialized to function");
        uint tempStamp = now;
        
        require(msg.sender == buyer, "Only the buyer can trigger an audit.");
        require(locked, "Cannot contest an unlocked contract.");
        
        //require((getWeekday(tempStamp) == 5) || (getWeekday(tempStamp) == 6 && getHour(tempStamp) < 18), "Contract reward can only be validated and claimed on Friday, Saturday(Saturday before 18:00 UTC)");

        
        getInitialApiData();


        return true;
    }



     
    //Calls a chain of API call functions to confirm submissions are equivalent on buyer and data scientist models and updated for the most recently started round, if they are destroys the contract sending the ETH and leftover LINK to the data scientist, otherwise just send leftover LINK to the data scientist
    function claim() public returns (bool success)
    {
        require(initialized,"Contract must be initialized to function");
        uint tempStamp = now;
        
        require(msg.sender == owner, "Only the owner can trigger a payment claim.");
        require(locked, "Cannot claim an unlocked contract.");
        //DEBUG VERSION SET TO 11 when LAUNCHING
        //require(((tempStamp - startTimestamp) / 604800) > 0, "Cannot claim contract before 12 weeks have elapsed.");

        
        emit Claimed();
        
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        
        link.transfer(owner, link.balanceOf(address(this)));
        

        owner.transfer(address(this).balance);

        buyer = address(0);
        buyerModelName = "";
        startTimestamp = 0;


        locked = false;
        initialized = false;

        return true;
    }




    //Get Round number and control, we need these first otherwise behavior of other fetches may be undefined or unceccesary spending of LINK
    function getInitialApiData() internal
    {
        

        sellerControlRequestId = buildAndSendBytes32Request(string(abi.encodePacked("https://api-tournament.numer.ai/?query={v2UserProfile(username:\"", sellerModelName,"\"){control}}")),"data.v2UserProfile.control");

        buyerControlRequestId = buildAndSendBytes32Request(string(abi.encodePacked("https://api-tournament.numer.ai/?query={v2UserProfile(username:\"", buyerModelName,"\"){control}}")),"data.v2UserProfile.control");
    }




    //Take in int's and store by requestID, also trigger new requests to maximize the chainlink oracles paying for gas, since they pay for this callback but will not pay over a certain gas price (hence if statements to do one call at a time since all at once costs too much)
    function fulfillInt(bytes32 _requestId, int256 _APIresult) external recordChainlinkFulfillment(_requestId)
    {
        dataAPIFloat[_requestId] = _APIresult;

        //If the control of a model is null, then the returned string is empty and has length 0
        if(callbackCount >= 2 && (bytes(dataAPIString[sellerControlRequestId]).length < 1 || bytes(dataAPIString[buyerControlRequestId]).length < 1))
        {
            attemptCancel(true);
            return;
        }

        
        if(callbackCount == 2)
        {
            sellerStakeRequestId = buildAndSendIntRequest(string(abi.encodePacked("https://api-tournament.numer.ai/graphql?query={v2UserProfile(username:\"",sellerModelName,"\"){totalStake}}")),
            "data.v2UserProfile.totalStake",10**18);
        }
        else if(callbackCount == 3)
        {
            buyerCorrelationRequestId = buildAndSendIntRequest(string(abi.encodePacked("https://api-tournament.numer.ai/graphql?query={roundSubmissionPerformance(roundNumber:",uintToStr(uint256(dataAPIFloat[numeraiLatestRoundRequestId])),",username:\"",buyerModelName,"\"){roundDailyPerformances{correlation}}}")),
            "data.roundSubmissionPerformance.roundDailyPerformances.-1.correlation",10**18);
        }
        else if(callbackCount == 4)
        {
            sellerCorrelationRequestId = buildAndSendIntRequest(string(abi.encodePacked("https://api-tournament.numer.ai/graphql?query={roundSubmissionPerformance(roundNumber:",uintToStr(uint256(dataAPIFloat[numeraiLatestRoundRequestId])),",username:\"",sellerModelName,"\"){roundDailyPerformances{correlation}}}")),
            "data.roundSubmissionPerformance.roundDailyPerformances.-1.correlation",10**18);
        }
        else if(callbackCount == 5)
        {
            attemptCancel(false);
            return;
        }


        callbackCount++;
    }




    //Read in bytes32 from chainlink oracle, log that a callback was received
    function fulfillBytes32(bytes32 _requestId, bytes32 _APIresult) external recordChainlinkFulfillment(_requestId)
    {
        dataAPIString[_requestId] = bytes32ToString(_APIresult);
        
        if(callbackCount == 1)
        {
            numeraiLatestRoundRequestId = buildAndSendIntRequest("https://api-tournament.numer.ai/graphql?query={rounds{number}}","data.rounds.0.number",1);
        }
        
        callbackCount++;
    }
    



    //Final step, check if contract was broken (will have checked true if attempt cancel resulted from the seller not submitting on time or not staking)
    function attemptCancel(bool checked) internal
    {
        callbackCount = 0;

        uint256 tempStamp = now;


        if(!checked)
        {
            bool condition = uint256(dataAPIFloat[sellerStakeRequestId]) < sellerStakePromise || dataAPIFloat[sellerCorrelationRequestId] != dataAPIFloat[buyerCorrelationRequestId];

            require(condition,"Seller must have failed contract check to cancel.");

        }


        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        
        link.transfer(owner, link.balanceOf(address(this)));
        
        uint256 payout = ((tempStamp - startTimestamp) / 604800) * ((address(this).balance)/12);
        
        owner.transfer(payout);
        
        buyer.transfer(address(this).balance);
        
        buyer = address(0);
        buyerModelName = "";
        startTimestamp = 0;


        locked = false;
        initialized = false;
     
        emit Contested();
                
    }
    

    function bytes32ToString(bytes32 b32) public pure returns (string memory) 
    {
        uint8 i = 0;
        while(i < 32 && b32[i] != 0) 
        {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && b32[i] != 0; i++) 
        {
            bytesArray[i] = b32[i];
        }
        return string(bytesArray);
    }

    

    function uintToStr(uint it) public pure returns (string memory _uintAsString) 
    {
        uint number = it;
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
    



        uint constant DAY_IN_SECONDS = 86400;




        function getHour(uint timestamp) public pure returns (uint) 
        {
                return uint((timestamp / 60 / 60) % 24);
        }

        function getMinute(uint timestamp) public pure returns (uint) 
        {
                return uint((timestamp / 60) % 60);
        }

        function getSecond(uint timestamp) public pure returns (uint) 
        {
                return uint(timestamp % 60);
        }

        function getWeekday(uint timestamp) public pure returns (uint) 
        {
                return uint((timestamp / DAY_IN_SECONDS + 4) % 7);
        }
    

}


