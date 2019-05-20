pragma solidity ^0.5.0;

import "./Activatable.sol";

contract Splitter is Activatable{
    //the address of this contract
    address payable public splitterAddress;

    //The parties involved in the contract
    address payable public Alice;
    address payable public Carol;
    address payable public Bob;

    //hold Bob and Carols balances
    uint public CarolsBalance;
    uint public BobsBalance;


    //set the address of the contract when it is instantiated
    constructor(address A, address payable B, address payable C) public {
        require(A!=B||A!=C||B!=C,"A,B,C have to be different addresses");
        splitterAddress = address(uint160(address(this)));
        Alice = A;
        Bob = B;
        Carol = C;
    }

    //get the balance of the contract -  necessary for the front end
    function getBalance() public view returns(uint balance){
        balance = splitterAddress.balance;
    }

    //set the addresses of A,B & C
    function setPartiesInvolved(address payable A, address payable B, address payable C) public requireOwner ifDeactivated{
        require(A!=B||A!=C||B!=C,"These have to be different addresses");
        require(A!=Alice||B!=Bob||C!=Carol,"The addresses are already existing");
        Alice = A;Bob = B;Carol = C;
    }

    //get the Balance of the 3 parties
    function getBobsBalance() public view returns(uint balance){
        balance = BobsBalance;
    }
    function getCarolBalance() public view returns(uint balance){
        balance = CarolsBalance;
    }
    function getAliceBalance() public view returns(uint balance){
        balance = Alice.balance;
    }

    //function to split ether
    function splitEther() public ifActivated  payable{
        require(Alice == msg.sender,"You are not allowed to split your Ether");
        require(msg.value>0,"You sent nothing to split");
        assert((msg.value/2) <= msg.value);

        BobsBalance += uint(msg.value/2);
        CarolsBalance += uint(msg.value/2);

        splitterAddress.transfer(msg.value);
    }

    //withdraw ether for Bob & Carol
    function withdrawEtherBob()public ifActivated {
        require(Bob == msg.sender,"You are not Bob");
        Bob.transfer(BobsBalance);
    }

    function withdrawEtherCarol()public ifActivated {
        require(Carol == msg.sender,"You are not Carol");
        Carol.transfer(CarolsBalance);
    }

    //withdraw all ether from contract
    function withdrawAllEther()public ifActivated{
        require(Alice == msg.sender,"You are not Alice");
        Alice.transfer(uint(BobsBalance+CarolsBalance));
    }
}