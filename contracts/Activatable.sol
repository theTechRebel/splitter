pragma solidity ^0.5.0;

import "./Owned.sol";

contract Activatable is Owned{
    bool internal activated; //current state of the contract

    //upon instantiation set the contract to activated
    constructor() public{
        activated = true;
    }

    //modifier function - only execute some features of contract is activated
    modifier ifActivated(){
        require(activated,"Contract is not activated");
        _;
    }

    //modifier function - only execute some features of contract is deactivated
    modifier ifDeactivated(){
        require(!activated,"Contract is running, deactiavte first");
        _;
    }

    //stops the contract only if the owner calls it and only if the contract is activated
    function deactivateContract() public requireOwner ifActivated {
        activated = false;
    }

    //activates the contract only if the owner wills it
    function activateContract() public requireOwner ifDeactivated{
        activated = true;
    }

    //get the current status of the contract
    function isActivated() public view returns(bool actiavted){
        return activated;
    }
}