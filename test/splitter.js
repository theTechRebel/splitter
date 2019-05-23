const Splitter = artifacts.require("Splitter");

contract('Splitter',accounts=>{
    //3 parties involved
    const[owner,reciever1,reciever2,newOwner,unauthorised] = accounts;
    // contract
    let instance;

  // test helper
  // get event result
  const getEventResult = (txObj, eventName) => {
    const event = txObj.logs.find(log => log.event === eventName);
    if (event) {
      return event.args;
    } else {
      return undefined;
    }
  };

    //before each subsequent test deploy a new instance of the contract
    beforeEach(async() =>{
		instance = await Splitter.new(true, { from: owner });
    });

    it("should allow owner to change owner address",async()=>{
      const txObj = await instance.changeOwner(newOwner,{from:owner});
      //check status
      assert.isTrue(txObj.receipt.status,"receipt status must be true");
      //check event
      const event = getEventResult(txObj,"LogOwnerChanged");
      assert.equal(event.sender,owner,"Old owner must be changed");
      assert.equal(event.owner,newOwner,"New owner must be set");
    });

    it("should allow activation and deactivation of contract",async()=>{
      var txObj = await instance.deactivateContract({from:owner});
      //check status
      assert.isTrue(txObj.receipt.status,"receipt status must be true");
      //check event
      var event = getEventResult(txObj,"LogActivateDeactivate");
      assert.equal(event.sender,owner,"function must have been execute by owner");
      assert.equal(event.active,false,"contract must be deactivated");

      txObj = await instance.activateContract({from:owner});
      //check status
      assert.isTrue(txObj.receipt.status,"receipt status must be true");
      //check event
      event = getEventResult(txObj,"LogActivateDeactivate");
      assert.equal(event.sender,owner,"function must have been execute by owner");
      assert.equal(event.active,true,"failed to actiavted");
    });

    it("should allow killing of contract by owner", async()=>{
      var txObj = await instance.deactivateContract({from:owner});
       assert.isTrue(txObj.receipt.status,"receipt status must be true");
       txObj = await instance.killContract({from:owner});
       assert.isTrue(txObj.receipt.status,"receipt status must be true");
       //check event
      const event = getEventResult(txObj,"LogContractDeath");
      assert.equal(event.sender,owner,"function must have been executed by owner");
      assert.equal(event.active,true,"failed to kill contract");
    })
    
    //check balances before split
    it("should have balances before split as zero", async()=>{
        const balBefore1 = await instance.recieversBalances.call(reciever1);
        const balBefore2 = await instance.recieversBalances.call(reciever2);

        assert.equal(balBefore1.toString(), 0, "Failed to deploy with "+reciever1+" address equalling zero");
        assert.equal(balBefore2.toString(), 0, "Failed to deploy with "+reciever2+" address equalling zero");
    });

    it("should split ether between 2 addresses", async()=>{
      const ether = 43;
        const txObj = await instance.splitEther(reciever1,reciever2,{from:unauthorised,value:ether});
        assert.isTrue(txObj.receipt.status,"receipt status must be true");
        const acc1 = await instance.recieversBalances.call(reciever1);
        const acc2 = await instance.recieversBalances.call(reciever2);
        const acc3 = await instance.recieversBalances.call(unauthorised);
        assert.equal(acc1.toString(),Math.floor((ether/2)),"failed to split ether equaly");
        assert.equal(acc2.toString(),Math.floor((ether/2)),"failed to split ether equaly");
        assert.equal(acc3.toString(),ether%2,"failed to split ether equaly");
    });

    it("should withdraw ether verifying gas price, transaction cost and amount", async()=>{
      const ether = 43;
        var txObj = await instance.splitEther(reciever1,reciever2,{from:unauthorised,value:ether});
        assert.isTrue(txObj.receipt.status,"receipt status must be true");
        var acc1 = await instance.recieversBalances.call(reciever1);
        assert.equal(acc1.toString(),Math.floor((ether/2)),"failed to split ether equaly");

        const receiver_old_bal = web3.utils.toBN(await web3.eth.getBalance(reciever1));
        txObj = await instance.withdraw({from:reciever1});
        assert.isTrue(txObj.receipt.status,"receipt status must be true");
        //check event
        const event = getEventResult(txObj,"LogBalanceWithdrawn");
        assert.equal(event.sender,reciever1,"address must be the withdrawer");
        assert.equal(event.amount,acc1.toString(),"withdrawn ether must be ether in wallet");

        // get transaction gas price
        const tx = await web3.eth.getTransaction(txObj.tx);
        const gasPrice = web3.utils.toBN(tx.gasPrice);
        // transaction cost
        const txCost = web3.utils.toBN(txObj.receipt.gasUsed).mul(gasPrice);
        const receiver_new_bal = web3.utils.toBN(await web3.eth.getBalance(reciever1));

        // calculate received amount 
        const recieved = receiver_new_bal.add(txCost).sub(receiver_old_bal);

        // test amount received must be correct
        assert.strictEqual(acc1.toString(),recieved.toString(),"reciever shoudl recieve " + acc1
        );
    });
});
