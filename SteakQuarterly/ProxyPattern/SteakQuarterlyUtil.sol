
/*
DO NOT COPY OR REPRODUCE THESE WORKS WITHOUT THE WRITTEN PERMISSION FROM BENJAMIN SCHREYER
COPYRIGHT BENJAMIN SCHREYER
*/

//Last updated 4/1/2021
//bensch
//Kovan Test Network contract to facilitate purchase of Numerai model submission for a buyer Numerai account 

//Note 4/1/2021 currently late sub.s is checked by a failure of a node to callback because Numerai returned null to an API call for pending payout,
//this works now, but if nodes ever switch to taking null to be 0 this will not work and late submissions will be accepted which is an error.

// COMPILE WITH ENABLE OPTIMIZATION AT 800 RUNS SO IT IS SMALL ENOUGH FOR ETH

pragma solidity ^0.6.0;

library SteakQuarterlyUtil
{
    //https://ethereum.stackexchange.com/questions/2519/how-to-convert-a-bytes32-to-string
    function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }

    
        /// @notice converts number to string
    /// @dev source: https://github.com/provable-things/ethereum-api/blob/master/oraclizeAPI_0.5.sol#L1045
    /// @param _i integer to convert
    /// @return _uintAsString
    function uintToStr(uint _i) public pure returns (string memory _uintAsString) {
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
