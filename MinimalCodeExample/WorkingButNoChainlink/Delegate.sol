

//Last updated 4/1/2021
//bensch
//Kovan Test Network contract to facilitate purchase of Numerai model submission for a buyer Numerai account 

//Note 4/1/2021 currently late sub.s is checked by a failure of a node to callback because Numerai returned null to an API call for pending payout,
//this works now, but if nodes ever switch to taking null to be 0 this will not work and late submissions will be accepted which is an error.

// --COMPILE WITH ENABLE OPTIMIZATION AT 800 RUNS SO IT IS SMALL ENOUGH FOR ETH-- OLD DEP.

pragma solidity ^0.6.0;




contract Delegate
{
    

    address public debugAddr;

    
    

    //State variables
    //locked: buyer cannot be kicked from the contract, contract cannot receive payment, model names cannot be changed. Contract must be locked but unverified for a refund request to go through
    bool public locked;
    

    //UNIX stamp for contract construction
    uint public birthStamp;
    

    //Cost to buy sumbissions
    uint256 public costETH;
    
    address payable owner;

  
    event Locked(string, string);
    

    /**
     * Network: Kovan
     * market.link
     * Fee: 0.1 LINK
     */
     
     constructor() public
     {
         owner = msg.sender;
     }
     

    
    
    
    

    
    
    



    
    //Locks in the contract, buyer should have already provided data scientist an upload only API key and their model ID 
    function lock() public returns (bool success)
    {
        
        debugAddr = msg.sender;
        
        uint tempStamp = now;
        
        //THIS IS THE REQUIRE THAT FAILS WHEN IT SHOULDNT WHEN I UNCOMMENT THIS AND DEPLOY/RUN
        require(msg.sender == owner, "Only owner can lock contract.");
        
        //require(!locked, "Cannot lock contract that is already locked.");
        //require(buyer != address(0),"No buyer to lock.");
        //require(bytes(buyerModelName).length != 0,"No buyerModelName to lock.");

        //require((tempStamp - startTimestamp) < 158400,"Cannot lock contract that was entered by buyer over 44 hours ago.");
        //require((getWeekday(tempStamp) == 0) || (getWeekday(tempStamp) == 1 && getHour(tempStamp) < 14),"Contract can only be locked in between Sunday 00:00 UTC and Monday 14:00 UTC");
        

        //require(link.balanceOf(address(this)) >= totalFee, "Contract requires 0.5 LINK total to operate once locked, current LINK balance is under 0.5.");

        
        locked = true;
    

        return true;
    }
    

}
