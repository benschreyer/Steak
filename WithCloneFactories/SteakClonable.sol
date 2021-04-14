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

contract SteakClonable is ChainlinkClient {


    
    
    
    
    event Constructed(string, uint256, uint256);
  
    event BuyerModelNameRegistered(string, uint256);
    
    event Kicked(string);
  
    event Locked(string, string);
    
    event Claimed(int256, int256, uint256, uint256, uint256, uint256);
    
    event Reclaimed();
    
    //bensch Kovan Test Network wallet
    address payable private bensch;
    
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
    int256 public buyerLiveCorrelation;
    int256 public dataScientistLiveCorrelation;
    bool private getBuyerCorrelation;

    //Ensure both submissions are on time by requiring they have pending payout
    
    //int256[2] public payoutPending;
    uint256 payoutPendingCounter;

    

    
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
    
    address public libraryAddress;
    
    /**
     * Network: Kovan
     * Oracle: Chainlink - https://market.link/nodes/ef076e87-49f4-486b-9878-c4806781c7a0/adapters?network=42
     * Job ID: Chainlink - https://market.link/jobs/c2387021-cf1c-44a0-ae79-66fcdf39cff3?network=42
     * Fee: 0.1 LINK
     */
     
    //Seller of the submission A.K.A. data scientist constructs the contract promising to stake _dataScientistStakePromise NMR on their submission on _dataScientistModelName and expects atleast _costETH ethereum for their submission
    //Note 1 Ethereum is represented on the block chain as an unsigned integer with value of 10 ** 18 or 10 ^ 18 or 1000000000000000000, the same is true for LINK and NMR
    constructor() public 
    {
        

        birthStamp = now;

        bensch = 0xa9187C8C9f692Fe2ca6b80069e87dF23b34157A3;
        buyerLiveCorrelation = -1;
        dataScientistLiveCorrelation = 1;
        getBuyerCorrelation = false;

        //payout pending must have non 0 value to ensure verification

        //Set to zero since it is atleast extremely rare to get exactly 0 payout so there should almost never be a time where the submission was on time but a refund is granted
        //Edit 4/1/21 Kovan nodes from alphavantage error and do not callback if they get null for int256, conveniently null is returned for pending stake if the sub was late, so instead of checking for non 0 payout to check for late sub,
        //just stop the confirmation call chain early and never reach full confirmation if the node throws an error because it is trying to multiply null and doesnt callback
        //payoutPending = [0, 0];
        payoutPendingCounter = 0;

        //Not a possible stake value on Numer.ai, used to give the variable a value for being unitialized
        dataScientistStakeActual = 1;
        //state variables
        locked = false;
        verified = false;
        
        //Store cost and promises by data scientist

        
        //Give ownership to contract creator
        
        
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

        
        //metricNames = ["correlation", "mmc", "fnc"];
        
        emit Constructed(dataScientistModelName, costETH, dataScientistStakePromise);

    }
    
    
    function initialize(string memory _dataScientistModelName, uint256 _costETH,uint256 _dataScientistStakePromise, address _libraryAddress) external
    {
        
        require(_dataScientistStakePromise >= 10000000000000000,"Data scientist must stake atleast 0.01 NMR for verification purposes");
        owner = msg.sender;
        costETH = _costETH;
        dataScientistModelName = _dataScientistModelName;
        dataScientistStakePromise = _dataScientistStakePromise;
        libraryAddress = _libraryAddress;
        
    }
    
    //Buyer enters agreement to get dataScientistModelName submissions for the upcoming round by calling this function with atleast costETH payment to be payed to the data scientist upon verification
    function registerBuyerModelName(string memory _buyerModelName) payable public
    {
        
        libraryAddress.delegatecall(abi.encodeWithSignature("registerBuyerModelName(string)",_buyerModelName));

    }
   
    
    
    
    
    //Data scientist can kick a user out of a contract if it has not been locked in
    function kick() public returns (bool success)
    {

        libraryAddress.delegatecall(abi.encodeWithSignature("kick()"));
        
        return buyer == address(0);
    }
    
    
    
    
    //Locks in the contract, retreives the modelID to be used for submissions based off of the model name, buyer should have already provided data scientist an upload only API key (private and public)
    function lock() public returns (bool success)
    {
        libraryAddress.delegatecall(abi.encodeWithSignature("lock()"));
        
        return locked;
    }
    
    
    
    
    
    
    
    
    //Allows a buyer to reclaim the ETH payment if the data scientist fails to produce equivalent live performance on both parties models
    function reclaim() public returns (bool success)
    {
        libraryAddress.delegatecall(abi.encodeWithSignature("reclaim()"));
       
       return true;
    }
    
    
    
    
    //Calls a chain of API call functions to confirm submissions are equivalent on buyer and data scientist models and updated for the most recently started round, if they are destroys the contract sending the ETH and leftover LINK to the data scientist, otherwise just send leftover LINK to the data scientist
    function claim() public returns (bool success)
    {
        libraryAddress.delegatecall(abi.encodeWithSignature("claim()"));
        return true;
    }
    
    
    
    
    
    
 
        


}