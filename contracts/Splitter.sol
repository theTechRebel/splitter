pragma solidity ^0.5.0;

contract Owned{
    //identifies the owner of the contract / admin
    address internal owner;

    //set the owner of the contract
    constructor() public{
        owner = msg.sender;
    }

    //a modifier that only the admin can do something
    modifier  requireOwner() {
        require(owner == msg.sender,"You are not the owner");
        _;
    }

    //only the current owner should be able to change owner
    function changeOwner(address newOwner) public requireOwner{
        owner = newOwner;
    }
}

contract Activatable is Owned{
    bool internal activated; //current state of the contract

    //upon instantiation set the contract to activated
    constructor() public{
        activated = true;
    }

    //modifier function - only execute some features of contract is activated
    modifier ifRunning(){
        require(activated,"Contract is not activated");
        _;
    }

    //stops the contract only if the owner calls it and only if the contract is activated
    function deactivateContract() public requireOwner ifRunning {
        activated = false;
    }

    //activates the contract only if the owner wills it
    function activateContract() public requireOwner{
        require(!activated,"Contract is already activated");
        activated = true;
    }

    //get the current status of the contract
    function isActivated() public view returns(bool actiavted){
        return activated;
    }
}

contract Splitter is Activatable{
    //the address of this contract
    address public splitterAddress;

    //The parties involved in the contract
    address public Alice;
    address public Carol;
    address public Bob;


    //set the address of the contract when it is instantiated
    constructor() public {
        splitterAddress = address(this);
    }

    //get the balance of the contract -  necessary for the front end
    function getBalance() public view returns(uint balance){
        return splitterAddress.balance;
    }


}