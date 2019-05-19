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