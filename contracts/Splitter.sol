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

    event LogsplitEther(address sender,uint amount,uint toBob, uint toCarol);
    event LogwithdrawEther(address sender,uint amount);
    event LogBalanceAfterTransaction(address reciever,uint amount);


    //set the address of the contract when it is instantiated
    constructor(address payable A, address payable B, address payable C) public {
        require(A!=address(0)||B!=address(0)||C!=address(0),"One of your addresses is invalid");
        require(A!=B||A!=C||B!=C,"A,B,C have to be different addresses");
        Alice = A;
        Bob = B;BobsBalance = 0;
        Carol = C;CarolsBalance = 0;
        emit LogBalanceAfterTransaction(Bob,BobsBalance);
        emit LogBalanceAfterTransaction(Carol,CarolsBalance);
    }

    //get the balance of the contract -  necessary for the front end
    function getContractAddress() public view returns(address thisAddress){
        thisAddress = address(this);
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
        assert((msg.value/2) <= msg.value);

        BobsBalance += (msg.value/2);
        CarolsBalance += (msg.value/2);

        emit LogsplitEther(msg.sender,msg.value,(msg.value/2), (msg.value/2));
        emit LogBalanceAfterTransaction(Bob,BobsBalance);
        emit LogBalanceAfterTransaction(Carol,CarolsBalance);
    }

    //withdraw ether for Bob & Carol
    function withdrawEtherBob()public {
        require(Bob == msg.sender,"You are not Bob");
        Bob.transfer(BobsBalance);
        emit LogwithdrawEther(msg.sender,BobsBalance);
        BobsBalance = 0;
        emit LogBalanceAfterTransaction(Bob,BobsBalance);
    }

    function withdrawEtherCarol()public {
        require(Carol == msg.sender,"You are not Carol");
        Carol.transfer(CarolsBalance);
        emit LogwithdrawEther(msg.sender,CarolsBalance);
        CarolsBalance = 0;
        emit LogBalanceAfterTransaction(Carol,CarolsBalance);
    }
}