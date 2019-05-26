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
        //step 1: split ether - deposit
        const ether = 43;
        await instance.splitEther(reciever1,reciever2,{from:unauthorised,value:ether});

        //step 2: withdraw ether
        const oldBalance = web3.utils.toBN(await web3.eth.getBalance(reciever1)); //current balance before withdrawal
        const withdrawnAmount = web3.utils.toBN(await instance.recieversBalances.call(reciever1)); //amount in contract before withdrawal
        const txObj = await instance.withdraw({from:reciever1}); //withdraw

        //step 3: calculate transaction cost
        const transaction =  await web3.eth.getTransaction(txObj.tx);
        // transaction cost = gasUsed x gasPrice
        const txCost = web3.utils.toBN(txObj.receipt.gasUsed).mul(web3.utils.toBN(transaction.gasPrice));
        
        //step 4: calculate new balance
          //new balance = old balance - tx fee + withdrawn amount.
        const newBalance = oldBalance.sub(txCost).add(withdrawnAmount);
          //get new balance in wallet for comparison
        const walletBalance = await web3.eth.getBalance(reciever1);

        // test new balance must be equal to wallet balance
        assert.strictEqual(newBalance.toString(),walletBalance.toString(),"recievers new balance should equal balance in wallet");
    });
});
