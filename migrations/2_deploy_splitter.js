var Splitter = artifacts.require("Splitter");

module.exports = function(deployer){
    deployer.deploy(Splitter,false);
}