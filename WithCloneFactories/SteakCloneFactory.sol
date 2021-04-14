pragma solidity ^0.6.0;
import "./CloneFactory.sol";
import "./Steak.sol";
import "./SteakClonable.sol";

contract SteakCloneFactory is CloneFactory
{
    event SteakCreated(Steak s);
    address public libraryAddress;
    address private steakOwner;
    
    constructor() public
    {
        steakOwner = msg.sender;
    }
    
    function setLibraryAddress(address _libraryAddress) external
    {
        require(msg.sender == steakOwner,"Only owner can change libraryAddress");
        libraryAddress = _libraryAddress;
    }
    
    function createSteak(string memory _dataScientistModelName, uint256 _costETH,uint256 _dataScientistStakePromise) external
    {
        SteakClonable s = SteakClonable(createClone(libraryAddress));
        s.initialize(_dataScientistModelName,  _costETH, _dataScientistStakePromise, libraryAddress);
    }
}