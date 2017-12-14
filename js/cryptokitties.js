
////////////////////////////////////////
// My Imports
import _core from './kittyCore.js'
import _sale from './kittySale.js'
import _sire from './kittySire.js'

////////////////////////////////////////
// Initialize Variables/Instances
const firstBlock = 4605167
const core = eth.contract(_core.abi).at(_core.address)
const sale = eth.contract(_sale.abi).at(_sale.address)
const sire = eth.contract(_sire.abi).at(_sire.address)

export { firstBlock, core, sale, sire }
