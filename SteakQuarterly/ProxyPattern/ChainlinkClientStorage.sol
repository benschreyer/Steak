// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;


import "https://raw.githubusercontent.com/smartcontractkit/chainlink/develop/evm-contracts/src/v0.6/interfaces/ENSInterface.sol";
import "https://raw.githubusercontent.com/smartcontractkit/chainlink/develop/evm-contracts/src/v0.6/interfaces/LinkTokenInterface.sol";
import "https://raw.githubusercontent.com/smartcontractkit/chainlink/develop/evm-contracts/src/v0.6/interfaces/ChainlinkRequestInterface.sol";
import "https://raw.githubusercontent.com/smartcontractkit/chainlink/develop/evm-contracts/src/v0.6/interfaces/PointerInterface.sol";


/**
 * @title The ChainlinkClient contract
 * @notice Contract writers can inherit this contract in order to create requests for the
 * Chainlink network
 */
contract ChainlinkClientStorage {


  uint256 constant internal LINK = 10**18;
  uint256 constant internal AMOUNT_OVERRIDE = 0;
  address constant internal SENDER_OVERRIDE = address(0);
  uint256 constant internal ARGS_VERSION = 1;
  bytes32 constant internal ENS_TOKEN_SUBNAME = keccak256("link");
  bytes32 constant internal ENS_ORACLE_SUBNAME = keccak256("oracle");
  address constant internal LINK_TOKEN_POINTER = 0xC89bD4E1632D3A43CB03AAAd5262cbe4038Bc571;

  ENSInterface internal ens;
  bytes32 internal ensNode;
  LinkTokenInterface internal link;
  ChainlinkRequestInterface internal oracle;
  uint256 internal requestCount = 1;
  mapping(bytes32 => address) internal pendingRequests;


}
