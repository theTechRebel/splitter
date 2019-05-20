pragma solidity ^0.5.0;

contract Owned{
    //identifies the owner of the contract / admin
    address private owner;
    bool private killed; //is the contract dead

    //log when owner is changed
    event LogOwnerChanged(address sender, address owner);
    //log contract activation and deactivation
    event LogContractDeath(address sender, bool active);

    modifier ifAlive(){
            require(killed,"Contract was killed");
            _;
        }

    function killContract() public ifAlive onlyOwner{
        killed = true;
        emit LogContractDeath(msg.sender,killed);
    }

    //set the owner of the contract
    constructor() public{
        owner = msg.sender;
        killed = false;
        emit LogContractDeath(msg.sender,killed);
    }

    //a modifier that only the admin can do something
    modifier  onlyOwner() {
        require(owner == msg.sender,"You are not the owner");
        _;
    }

    //only the current owner should be able to change owner
    function changeOwner(address newOwner) public onlyOwner{
        require(newOwner != address(0), "Pass in valid address");
        owner = newOwner;
        emit LogOwnerChanged(msg.sender,newOwner);
    }
}