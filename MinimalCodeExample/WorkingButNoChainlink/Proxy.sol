

//Last updated 4/1/2021
//bensch
//Kovan Test Network contract to facilitate purchase of Numerai model submission for a buyer Numerai account 

//Note 4/1/2021 currently late sub.s is checked by a failure of a node to callback because Numerai returned null to an API call for pending payout,
//this works now, but if nodes ever switch to taking null to be 0 this will not work and late submissions will be accepted which is an error.

// --COMPILE WITH ENABLE OPTIMIZATION AT 800 RUNS SO IT IS SMALL ENOUGH FOR ETH-- OLD DEP.

pragma solidity ^0.6.0;

import "https://raw.githubusercontent.com/smartcontractkit/chainlink/develop/evm-contracts/src/v0.6/ChainlinkClient.sol";
import "https://raw.githubusercontent.com/smartcontractkit/chainlink/develop/evm-contracts/src/v0.6/interfaces/ENSInterface.sol";
import "https://raw.githubusercontent.com/smartcontractkit/chainlink/develop/evm-contracts/src/v0.6/interfaces/LinkTokenInterface.sol";
import "https://raw.githubusercontent.com/smartcontractkit/chainlink/develop/evm-contracts/src/v0.6/interfaces/ChainlinkRequestInterface.sol";
import "https://raw.githubusercontent.com/smartcontractkit/chainlink/develop/evm-contracts/src/v0.6/interfaces/PointerInterface.sol";


/**
 * @title Proxy
 * @dev Implements delegation of calls to other contracts, with proper
 * forwarding of return values and bubbling of failures.
 * It defines a fallback function that delegates all calls to the address
 * returned by the abstract _implementation() internal function.
 */
contract Proxy {
    
    
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
    

    constructor() public
    {
        owner = msg.sender;
    }
    
    /**
     * @dev Fallback function.
     * Implemented entirely in `_fallback`.
     */
    fallback () payable external {
        _fallback();
    }

    /**
     * @dev Receive function.
     * Implemented entirely in `_fallback`.
     */
    receive () payable external {
        _fallback();
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
        
        
        address implementation = 0x2E3b1C1bFFf641bC469818f18761A72D846D0168;
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

    /**
     * @dev Function that is run as the first thing in the fallback function.
     * Can be redefined in derived contracts to add functionality.
     * Redefinitions must call super._willFallback().
     */
    function _willFallback() internal virtual {
    }

    /**
     * @dev fallback implementation.
     * Extracted to enable manual triggering.
     */
    function _fallback() internal {
        _willFallback();
        _delegate();
    }
}