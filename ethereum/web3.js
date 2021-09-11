// Uses browser info to detect which provider we pass to our instance of web3
import Web3 from 'web3';

let web3;

if (typeof window !== "undefined" && typeof window.ethereum !== "undefined") {
    // we are in the browser and metamask is running
    window.ethereum.request({ method: 'eth_requestAccounts' });
    web3 = new Web3(window.ethereum);
} else {
    // We are on the server OR the user is not running metamask
    // We are on the server *OR* the user is not running metamask
    const provider = new Web3.providers.HttpProvider(
        "https://rinkeby.infura.io/v3/7c548c36bf1b4e89b8fa20df7503cf5e"
    );
    web3 = new Web3(provider);
}

export default web3;