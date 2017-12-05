
////////////////////////////////////////
// My Imports
loadScript('./kittyCore.js')
loadScript('./kittySale.js')
loadScript('./kittySire.js')

////////////////////////////////////////
// Magic Numbers
var fromBlock = 4605167

////////////////////////////////////////
// Initialize Variables/Instances
var ckCore = eth.contract(coreABI).at(coreAddress)
var ckSale = eth.contract(saleABI).at(saleAddress)
var ckSire = eth.contract(sireABI).at(sireAddress)

