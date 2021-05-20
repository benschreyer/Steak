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

// --COMPILE WITH ENABLE OPTIMIZATION AT 800 RUNS SO IT IS SMALL ENOUGH FOR ETH-- OLD DEP.

pragma solidity ^0.6.0;

import "https://raw.githubusercontent.com/smartcontractkit/chainlink/develop/evm-contracts/src/v0.6/ChainlinkClient.sol";
import "./interfaces/ENSInterface.sol";
import "./interfaces/LinkTokenInterface.sol";
import "./interfaces/ChainlinkRequestInterface.sol";
import "./interfaces/PointerInterface.sol";

contract SteakQuarterlyProxy
{
    address public delegate =  0xC89bD4E1632D3A43CB03AAAd5262cbe4038Bc571;//REPLACE WITH KOVAN TESTNET DELEGATE;
    
    uint256 constant internal LINK = 10**18;
    uint256 constant private AMOUNT_OVERRIDE = 0;
    address constant private SENDER_OVERRIDE = address(0);
    uint256 constant private ARGS_VERSION = 1;
    bytes32 constant private ENS_TOKEN_SUBNAME = keccak256("link");
    bytes32 constant private ENS_ORACLE_SUBNAME = keccak256("oracle");
    address constant private LINK_TOKEN_POINTER = 0xC89bD4E1632D3A43CB03AAAd5262cbe4038Bc571;

    ENSInterface private ens;
    bytes32 private ensNode;
    LinkTokenInterface private link;
    ChainlinkRequestInterface private oracle;
    uint256 private requestCount = 1;
    mapping(bytes32 => address) private pendingRequests;

    event ChainlinkRequested(bytes32 indexed id);
    event ChainlinkFulfilled(bytes32 indexed id);
    event ChainlinkCancelled(bytes32 indexed id);

    
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
    uint256 public totalFee = 3 * feeInt + 2 * feeBytes32;
    

    //State variables
    //locked: buyer cannot be kicked from the contract, contract cannot receive payment, model names cannot be changed. Contract must be locked but unverified for a refund request to go through
    bool public locked;
    

    //UNIX stamp for contract construction
    uint public birthStamp;
    

    //Cost to buy sumbissions
    uint256 public costETH;
    
    //Promised model stake by seller, should be a conservative underestimate ie 50% or less of actual stake
    uint256 public sellerStakePromise;
    
    
  function() external payable {

        assembly {
            let _target := sload(0)
            calldatacopy(0x0, 0x0, calldatasize())
            let result := delegatecall(gas(), _target, 0x0, calldatasize(), 0x0, 0)
            returndatacopy(0x0, 0x0, returndatasize())
            switch result case 0 {revert(0, 0)} default {return (0, returndatasize())}
        }
    }

}
