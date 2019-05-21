pragma solidity ^0.5.0;

import "./Activatable.sol";

contract Splitter is Activatable{

    //The parties involved in the contract
    address payable public Alice;
    address payable public Carol;
    address payable public Bob;

    //hold Bob and Carols balances
    uint public CarolsBalance;
    uint public BobsBalance;

    event LogwithdrawEther(address sender,uint amount);
    event LogBalanceAfterTransaction(address reciever,uint amount);
    event LogBalanceBeforeTransaction(address sender,uint amount);


    //check for validity & of addresses, and that addresses are different before setting addresses for parties in memory
    constructor(address payable A, address payable B, address payable C) public {
        require(A!=address(0)&&B!=address(0)&&C!=address(0),"One of your addresses is invalid");
        require(A!=B&&A!=C&&B!=C,"A,B,C have to be different addresses");
        Alice = A;
        Bob = B;
        Carol = C;
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
    function splitEther() public ifAlive ifActivated  payable{
        require(Alice == msg.sender,"You are not allowed to split your Ether");
        require(msg.value>0,"You sent nothing to split");
        require(2%msg.value == 0,"Provide even ether to split");
        assert((msg.value/2) <= msg.value);

        emit LogBalanceBeforeTransaction(Bob, BobsBalance);
        emit LogBalanceBeforeTransaction(Carol, CarolsBalance);

        BobsBalance += (msg.value/2);
        CarolsBalance += (msg.value/2);

        emit LogBalanceAfterTransaction(Bob,BobsBalance);
        emit LogBalanceAfterTransaction(Carol,CarolsBalance);
    }

    //withdraw ether for Bob
    function withdrawEtherBob()public {
        //if this is Bob
        require(Bob == msg.sender,"You are not Bob");
        //check if Bobs balance has ether
        require(BobsBalance>0,"You have no ether to withdraw");
        emit LogBalanceBeforeTransaction(msg.sender, BobsBalance);
        uint _bobsBalance = BobsBalance;
        BobsBalance = 0;
        Bob.transfer(_bobsBalance);
        emit LogwithdrawEther(Bob,BobsBalance);
    }

    //withdraw ether for Carol
    function withdrawEtherCarol()public {
        //if this is Carol
        require(Carol == msg.sender,"You are not Carol");
        //check if Carol's balance has ether
        require(CarolsBalance>0,"You have no ether to withdraw");
        emit LogBalanceBeforeTransaction(msg.sender, CarolsBalance);
        uint _carolsBalance = CarolsBalance;
        CarolsBalance = 0;
        Carol.transfer(_carolsBalance);
        emit LogwithdrawEther(Carol,CarolsBalance);
    }
}