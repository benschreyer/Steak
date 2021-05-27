
/*
DO NOT COPY OR REPRODUCE THESE WORKS WITHOUT THE WRITTEN PERMISSION FROM BENJAMIN SCHREYER
COPYRIGHT BENJAMIN SCHREYER
*/

//Last updated 4/1/2021
//bensch
//Kovan Test Network contract to facilitate purchase of Numerai model submission for a buyer Numerai account 

//Note 4/1/2021 currently late sub.s is checked by a failure of a node to callback because Numerai returned null to an API call for pending payout,
//this works now, but if nodes ever switch to taking null to be 0 this will not work and late submissions will be accepted which is an error.

// --COMPILE WITH ENABLE OPTIMIZATION AT 800 RUNS SO IT IS SMALL ENOUGH FOR ETH-- OLD DEP.

pragma solidity ^0.6.0;

import "./ChainlinkClientStorage.sol";
import "./SteakStorage.sol"

/**
 * @title Proxy
 * @dev Implements delegation of calls to other contracts, with proper
 * forwarding of return values and bubbling of failures.
 * It defines a fallback function that delegates all calls to the address
 * returned by the abstract _implementation() internal function.
 */
contract SteakQuarterlyProxy is SteakStorage, ChainlinkClientStorage
{
    
    constructor() public
    {
        birthStamp = now;
        owner = msg.sender;
    }
    
    /**
     * @dev Fallback function.
     * Implemented entirely in `_fallback`.
     */
    fallback () payable external {
        _delegate();
    }

    /**
     * @dev Receive function.
     * Implemented entirely in `_fallback`.
     */
    receive () payable external {
        _delegate();
    }

    /**
     * @return The Address of the implementation.
     */


    /**
     * @dev Delegates execution to an implementation contract.
     * This is a low level function that doesn't return to its internal call site.
     * It will return to the external caller whatever the implementation returns.
     * 
     */
    function _delegate() internal {
        
        
        address implementation =  0x270d05292Bc96690b6c066444fB282ad261aD016;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }


}
