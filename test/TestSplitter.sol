pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Splitter.sol";

contract TestSplitter{
    //Test the address of the deployed Splitter contract
    Splitter splitter = Splitter(DeployedAddresses.Splitter());

    //test whether the address in the contract is the address of the contract
    function testSplitterAddress() public{
        address retrunedAddress = address(splitter);
        Assert.equal(address(retrunedAddress),address(splitter.splitterAddress),"Returned address should match address of the contract");
    }

    //test whether the balance returned by Splitter is correct
    function testSplitterBalance() public{
        uint balanceReturned = splitter.getBalance();
        uint balanceAtAddress = address(splitter).balance;
        Assert.equal(balanceReturned,balanceAtAddress,"Returned balance should match balance at address of the contract");
    }
}