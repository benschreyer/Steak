// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;



contract SteakStorage {


     
    mapping(bytes32 => int256) internal dataAPIFloat;

    mapping(bytes32 => string) internal dataAPIString;
    
    
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

    uint256 internal callbackCount = 0;
    
    bytes32 internal numeraiLatestRoundRequestId;

    bytes32 internal buyerCorrelationRequestId;

    bytes32 internal sellerCorrelationRequestId;
    
    bytes32 internal sellerStakeRequestId;

    bytes32 internal sellerControlRequestId;

    bytes32 internal buyerControlRequestId;

    
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
    bool public locked = false;

    //Whether or not constrctor args have been passed
    bool public initialized = false;
    

    //UNIX stamp for contract construction
    uint public birthStamp;
    

    //Cost to buy sumbissions
    uint256 public costETH;
    
    //Promised model stake by seller, should be a conservative underestimate ie 50% or less of actual stake
    uint256 public sellerStakePromise;


}
