require("file-loader?name=../index.html!../index.html");
require('../scss/app.scss');
const Web3 = require("web3");
const Promise = require("bluebird");
const truffle = require("truffle-contract");
const $ = require("jquery");
const SplitterJson = require("../../build/contracts/Splitter.json");

const Splitter = truffle(SplitterJson);

App = {
    web3Provider: null,
    contracts: {},
  
    init: async function() {
      return await App.initWeb3();
    },
  
    initWeb3: async function() {
      // Modern dapp browsers...
  if (window.ethereum) {
    App.web3Provider = window.ethereum;
    try {
      // Request account access
      await window.ethereum.enable();
    } catch (error) {
      // User denied account access...
      console.error("User denied account access")
    }
  }
  // Legacy dapp browsers...
  if (window.web3) {
    App.web3Provider = window.web3.currentProvider;
  }
  // If no injected web3 instance is detected, fall back to Ganache
  else {
    App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
  }
  web3 = new Web3(App.web3Provider);
      return App.initContract();
    },
  
    initContract: function() {
      Splitter.setProvider(App.web3Provider);
      console.log("app loaded");
      web3.eth.getAccounts().then(function(accounts){
        if(accounts.length == 0 ){
          alert("No contract available for user");
          throw new Error("No account with which to transact");
        }
        window.account = accounts[0];
        $("#currentAddress").html( window.account);
        console.log("Account:", window.account);
      });

      App.getContractBalance();
      return App.bindEvents();
    },
    bindEvents: async function() {
      $(document).on('click', '#split', App.handleSplit);
      $(document).on('click','#withdraw', App.handleWithdraw);
  },
  getContractBalance: async function(){
      var contract = await Splitter.deployed();
      console.log(contract);
      console.log(contract.address);
      var bal = await web3.eth.getBalance(contract.address);
      $("#balance").html(bal+" Wei");
    console.log(bal);
  },
  handleSplit: async function(){
    
    var acc1 = $("#acc1").val();
    var acc2 = $("#acc2").val();
    var ether = $("#ether").val();

    console.log(acc1);
    console.log(acc2);
    console.log(ether);

    var contract = await Splitter.deployed();
    var txn = await contract.splitEther(acc1,acc2,{from:window.account,value:ether});
    console.log(txn);
    App.getContractBalance();
  },
  handleWithdraw: async function(){
    var contract = await Splitter.deployed();
    console.log(window.account);
    var txn = await contract.withdraw({from:window.account});
    //var txn = await contract.withdraw.sendTransaction({from:address});
    console.log(txn);
    App.getContractBalance();
  }
  };
  
  $(window).on('load', function() {
    App.init();
   });