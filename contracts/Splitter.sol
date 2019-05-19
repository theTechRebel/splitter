pragma solidity ^0.5.0;

import "./Activatable.sol";

contract Splitter is Activatable{
    //the address of this contract
    address public splitterAddress;

    //The parties involved in the contract
    address public Alice;
    address payable public Carol;
    address payable public Bob;


    //set the address of the contract when it is instantiated
    constructor(address A, address payable B, address payable C) public {
        require(A!=B||A!=C||B!=C,"A,B,C have to be different addresses");
        splitterAddress = address(this);
        Alice = A;
        Bob = B;
        Carol = C;
    }

    //get the balance of the contract -  necessary for the front end
    function getBalance() public view returns(uint balance){
        return splitterAddress.balance;
    }

    //set the addresses of A,B & C
    function setPartiesInvolved(address A, address payable B, address payable C) public requireOwner ifDeactivated{
        require(A!=B||A!=C||B!=C,"These have to be different addresses");
        require(A!=Alice||B!=Bob||C!=Carol,"The addresses are already existing");
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