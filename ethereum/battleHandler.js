// Javascript instance of our battle handler contract
import web3 from './web3';
import compiledBattleHandler from './build/BattleHandler.json';

const instace = new web3.eth.Contract(compiledBattleHandler.abi, "0xe429A7c7bBabC4606b5d4d80eC643A3532F92bDA");
export default instance;