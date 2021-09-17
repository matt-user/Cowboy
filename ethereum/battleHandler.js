// Javascript instance of our battle handler contract
import web3 from './web3';
import compiledBattleHandler from './build/BattleHandler.json';

const instance = new web3.eth.Contract(compiledBattleHandler.abi, "0x2505abF02FD3e1CeA36930cbc6846cdB7cb74E82");
export default instance;