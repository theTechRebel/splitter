pragma solidity ^0.5.0;

import "./Owned.sol";

contract Activatable is Owned{
    bool private activated; //current state of the contract

    //log contract activation and deactivation
    event LogActivateDeactivate(address sender, bool active);

    //upon instantiation set the active state of the contract
    constructor(bool activate) public{
        activated = activate;
        emit LogActivateDeactivate(msg.sender,activate);
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
    function deactivateContract() public ifAlive onlyOwner ifActivated {
        activated = false;
        emit LogActivateDeactivate(msg.sender,activated);
    }

    //activates the contract only if the owner wills it
    function activateContract() public ifAlive onlyOwner ifDeactivated{
        activated = true;
        emit LogActivateDeactivate(msg.sender,activated);
    }

    //get the current status of the contract
    function isActivated() public view returns(bool actiavted){
        return activated;
    }
}