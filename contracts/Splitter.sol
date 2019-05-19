pragma solidity ^0.5.0;

contract Splitter{
    //the address of this contract
    address public splitterAddress;

    //when contract is created set the internal address variable
    constructor() public {
        splitterAddress = address(this);
    }

    //get the balance of the splitter contract
    function getBalance() public view returns(uint balance){
        return splitterAddress.balance;
    }
}