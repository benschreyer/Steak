
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

import "SteakQuarterlyUtil.sol";

contract SteakQuarterly is ChainlinkClient 
{
    

    
    mapping(bytes32 => int256) private dataAPIFloat;

    mapping(bytes32 => string) private dataAPIString;
    
    
    event Constructed(string, uint256, uint256);
  
    event BuyerModelNameRegistered(string, uint256);
    
    event Kicked(string);
  
    event Locked(string, string);
    
    event Contested();
    
    event Claimed();
    
    
    //bensch Kovan Test Network wallet for 1% fee
    address payable public bensch = 0xa9187C8C9f692Fe2ca6b80069e87dF23b34157A3;
    
    //Name of the models on Numerai tournament
    string public sellerModelName;
    string public buyerModelName;

    uint256 private callbackCount = 0;
    
    bytes32 private numeraiLatestRoundRequestId;

    bytes32 private buyerCorrelationRequestId;

    bytes32 private sellerCorrelationRequestId;
    
    bytes32 private sellerStakeRequestId;

    bytes32 private sellerControlRequestId;

    bytes32 private buyerControlRequestId;

    
    //Seconds since Unix epoch
    uint256 public startTimestamp;
  

    //Who deployed the contract and who engaged the contract
    address payable public owner;
    address payable public buyer;


    //Oracle, jobId, and fee for getting bytes32
    address public oracleBytes32 = 0x56dd6586DB0D08c6Ce7B2f2805af28616E082455;
    bytes32 public jobIdBytes32 = "c128fbb0175442c8ba828040fdd1a25e";
    uint256 public feeBytes32 = 0.1 * 10 ** 18;
    
    //Orcale, jobId, and fee for getting float
    address public oracleInt = 0x56dd6586DB0D08c6Ce7B2f2805af28616E082455;
    bytes32 public jobIdInt = "2649fc4ca83c4016bfd2d15765592bee";
    uint256 public feeInt = 0.1 * 10 ** 18;
    
    //Total fee needed for full contract execution
    uint256 public totalFee = 4 * feeInt + 2 * feeBytes32;
    

    //State variables
    //locked: buyer cannot be kicked from the contract, contract cannot receive payment, model names cannot be changed. Contract must be locked but unverified for a refund request to go through
    bool public locked;
    

    //UNIX stamp for contract construction
    uint public birthStamp;
    

    //Cost to buy sumbissions
    uint256 public costETH;
    
    //Promised model stake by seller, should be a conservative underestimate ie 50% or less of actual stake
    uint256 public sellerStakePromise;
    
    
    /**
     * Network: Kovan
     * market.link
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
        require(!locked, "Cannot register buyerModelName on locked contract.");
        require(bytes(_buyerModelName).length != 0,"Model name must not be empy/NULL string.");
        require(bytes(buyerModelName).length == 0, "Model must not already have buyerModelName.");

        require((SteakQuarterlyUtil.getWeekday(tempStamp) == 6 && SteakQuarterlyUtil.getHour(tempStamp) > 17) || (SteakQuarterlyUtil.getWeekday(tempStamp) == 0),"Contract can only be entered by buyer between Saturday 18:00 UTC and Sunday 24:00 UTC");      


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
        uint tempStamp = now;
        
        
        require(msg.sender == owner, "Only owner can kick from contract.");
        require(!locked, "Cannot kick locked contract.");
        require(buyer != address(0), "No buyer to kick.");
        
        require((tempStamp - startTimestamp) < 158400,"Cannot kick buyer from contract that was entered by buyer over 44 hours ago.");
        require((SteakQuarterlyUtil.getWeekday(tempStamp) == 0) || (SteakQuarterlyUtil.getWeekday(tempStamp) == 1 && SteakQuarterlyUtil.getHour(tempStamp) < 14),"Contract buyer can only be kicked in between Sunday 00:00 UTC and Monday 14:00 UTC");
        

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
        uint tempStamp = now;
        
        
        require(msg.sender == owner, "Only owner can lock contract.");
        require(!locked, "Cannot lock contract that is already locked.");
        require(buyer != address(0),"No buyer to lock.");
        require(bytes(buyerModelName).length != 0,"No buyerModelName to lock.");

        require((tempStamp - startTimestamp) < 158400,"Cannot lock contract that was entered by buyer over 44 hours ago.");
        require((SteakQuarterlyUtil.getWeekday(tempStamp) == 0) || (SteakQuarterlyUtil.getWeekday(tempStamp) == 1 && SteakQuarterlyUtil.getHour(tempStamp) < 14),"Contract can only be locked in between Sunday 00:00 UTC and Monday 14:00 UTC");
        
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(link.balanceOf(address(this)) >= totalFee, "Contract requires 0.5 LINK total to operate once locked, current LINK balance is under 0.5.");

        
        locked = true;
    

        return true;
    }
    



    //Buyer reclaim ethereum is seller doesnt start the contract
    function reclaim() public returns (bool success)
    {
        uint256 tempStamp = now;
        require(msg.sender == buyer,"Only buyer can reclaim unlocked contract");
        require(!locked,"Cannot reclaim locked contract");
        require((SteakQuarterlyUtil.getWeekday(tempStamp) == 1 && SteakQuarterlyUtil.getHour(tempStamp) >= 14) || (tempStamp - startTimestamp) > 172800 || (SteakQuarterlyUtil.getWeekday(tempStamp) == 2), "Can only reclaim after seller lock period");
        
        buyer.transfer(address(this).balance);
        require(address(this).balance == 0, "Failed to return ETH to buyer. Cannot kick.");

        
        emit Kicked(buyerModelName);
        
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        
        link.transfer(owner, link.balanceOf(address(this)));
        
        buyer = address(0);
        buyerModelName = "";
        startTimestamp = 0;

        
        return true;

    }
    



    //Send a chainlink request for a signed int with a URL, json path, and multiplication to remove n decimal places
    function buildAndSendIntRequest(string memory get, string memory path, int256 times) private returns (bytes32 requestId)
    {
        Chainlink.Request memory ret = buildChainlinkRequest(jobIdInt, address(this), this.fulfillInt.selector);


        ret.addInt("times",times);
        ret.add("get",get);
        ret.add("path",path);


        return sendChainlinkRequestTo(oracleInt, ret, feeInt);
    }




    //Send a chainlink request for a string
    function buildAndSendBytes32Request(string memory get, string memory path) private returns (bytes32 requestId)
    {
        Chainlink.Request memory ret = buildChainlinkRequest(jobIdBytes32, address(this), this.fulfillBytes32.selector);


        ret.add("get",get);
        ret.add("path",path);


        return sendChainlinkRequestTo(oracleBytes32, ret, feeBytes32);
    }




    //Attempt to cancel contract early since seller did not submit on time, submitted other predictions, didnt stake
    function contest() public returns (bool success)
    {
        uint tempStamp = now;
        
        require(msg.sender == buyer, "Only the buyer can trigger an audit.");
        require(locked, "Cannot contest an unlocked contract.");
        
        require((SteakQuarterlyUtil.getWeekday(tempStamp) == 5) || (SteakQuarterlyUtil.getWeekday(tempStamp) == 6 && SteakQuarterlyUtil.getHour(tempStamp) < 18), "Contract reward can only be validated and claimed on Friday, Saturday(Saturday before 18:00 UTC)");

        
        getInitialApiData();


        return true;
    }



     
    //Calls a chain of API call functions to confirm submissions are equivalent on buyer and data scientist models and updated for the most recently started round, if they are destroys the contract sending the ETH and leftover LINK to the data scientist, otherwise just send leftover LINK to the data scientist
    function claim() public returns (bool success)
    {
        uint tempStamp = now;
        
        require(msg.sender == owner, "Only the owner can trigger a payment claim.");
        require(locked, "Cannot claim an unlocked contract.");
        //DEBUG VERSION SET TO 11 when LAUNCHING
        require(((tempStamp - startTimestamp) / 604800) > 0, "Cannot claim contract before 12 weeks have elapsed.");

        
        emit Claimed();
        
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        
        link.transfer(owner, link.balanceOf(address(this)));
        

        owner.transfer(address(this).balance);

        buyer = address(0);
        buyerModelName = "";
        startTimestamp = 0;

        return true;
    }




    //Get Round number and control, we need these first otherwise behavior of other fetches may be undefined or unceccesary spending of LINK
    function getInitialApiData() private
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
            buyerCorrelationRequestId = buildAndSendIntRequest(string(abi.encodePacked("https://api-tournament.numer.ai/graphql?query={roundSubmissionPerformance(roundNumber:",SteakQuarterlyUtil.uintToStr(uint256(dataAPIFloat[numeraiLatestRoundRequestId])),",username:\"",buyerModelName,"\"){roundDailyPerformances{correlation}}}")),
            "data.roundSubmissionPerformance.roundDailyPerformances.-1.correlation",10**18);
        }
        else if(callbackCount == 4)
        {
            sellerCorrelationRequestId = buildAndSendIntRequest(string(abi.encodePacked("https://api-tournament.numer.ai/graphql?query={roundSubmissionPerformance(roundNumber:",SteakQuarterlyUtil.uintToStr(uint256(dataAPIFloat[numeraiLatestRoundRequestId])),",username:\"",sellerModelName,"\"){roundDailyPerformances{correlation}}}")),
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
        dataAPIString[_requestId] = SteakQuarterlyUtil.bytes32ToString(_APIresult);
        
        if(callbackCount == 1)
        {
            numeraiLatestRoundRequestId = buildAndSendIntRequest("https://api-tournament.numer.ai/graphql?query={rounds{number}}","data.rounds.0.number",1);
        }
        
        callbackCount++;
    }
    



    //Final step, check if contract was broken (will have checked true if attempt cancel resulted from the seller not submitting on time or not staking)
    function attemptCancel(bool checked) private
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
        
        buyer.transfer(address(this).balance)
     
        emit Contested();
                
    }

}
