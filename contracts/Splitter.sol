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

contract Splitter is Activatable{
    //the address of this contract
    address public splitterAddress;

    //The parties involved in the contract
    address public Alice;
    address payable public Carol;
    address payable public Bob;


    //set the address of the contract when it is instantiated
    constructor() public {
        splitterAddress = address(this);
    }

    //get the balance of the contract -  necessary for the front end
    function getBalance() public view returns(uint balance){
        return splitterAddress.balance;
    }

    //set the addresses of A,B & C
    function setPartiesInvolved(address A, address payable B, address payable C) public requireOwner ifDeactivated{
        Alice = A;Bob = B;Carol = C;
    }

    //get the Balance of the 3 parties
    function getBobsBalance() public view returns(uint balance){
        return Bob.balance;
    }
    function getAliceBalance() public view returns(uint balance){
        return Alice.balance;
    }
    function getCarolBalance() public view returns(uint balance){
        return Carol.balance;
    }

    //function to split ether
    function splitEther() public ifActivated  payable{
        require(Alice == msg.sender,"You are not allowed to split your Ether");
        require(msg.value>0,"You sent nothing to split");
        assert((msg.value/2) <= msg.value);
        Bob.transfer(msg.value/2);
        Carol.transfer(msg.value/2);
    }
}