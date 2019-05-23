pragma solidity ^0.5.0;

import "./Activatable.sol";

contract Splitter is Activatable{

    //hold a map of addresses whose ether has been split
    mapping (address => uint) public recieversBalances;

    constructor(bool _activated) Activatable(_activated) public{}

    event LogBalanceWithdrawn(address sender,uint amount);
    event LogBalanceCredited (address sender,address affectedAccount,uint amount);

    //split ether between any 2 parties | requires contract to be Active & Alive
    function splitEther(address reciever1, address reciever2)public ifAlive ifActivated  payable{
        require(reciever1 != address(0) && reciever2 != address(0),"Provide valid addresses"); //require valid addresses
        require(reciever1 != reciever2,"Provide different addresses"); //require addresses to be different
        require(msg.value>0,"You must send ether to split"); //require an amount to be sent

        recieversBalances[msg.sender] = recieversBalances[msg.sender]+(msg.value%2);
        recieversBalances[reciever1] = recieversBalances[reciever1]+(msg.value/2);
        recieversBalances[reciever2] = recieversBalances[reciever2]+(msg.value/2);

        emit LogBalanceCredited(msg.sender,msg.sender,recieversBalances[msg.sender]);
        emit LogBalanceCredited(msg.sender,reciever1,recieversBalances[reciever1]);
        emit LogBalanceCredited(msg.sender,reciever2,recieversBalances[reciever2]);
    }

    //anyone sent ether can withdraw
    function withdraw() public{
        uint _addressBalance = recieversBalances[msg.sender];
        require(_addressBalance>0,"address must have ether in contract"); //address must have a balance in the contract
         emit LogBalanceWithdrawn(msg.sender,_addressBalance);
        recieversBalances[msg.sender] = 0;
        msg.sender.transfer(_addressBalance);
    }
}