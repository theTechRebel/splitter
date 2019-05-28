# B9Lab Community Blockstars 2019 - Ethereum Developer Course
# Splitter Project

You will create a smart contract named Splitter whereby:
- There are 3 people: Alice, Bob and Carol.
- We can see the balance of the Splitter contract on the Web page.
- Whenever Alice sends ether to the contract for it to be split, half of it goes to Bob and the other half to Carol.
- We can see the balances of Alice, Bob and Carol on the Web page.
- Alice can use the Web page to split her ether.

## Getting Started

Clone this repository locally:

```bash or cmd
git clone https://github.com/theTechRebel/splitter.git
```

Install dependencies with npm :

```bash or cmd
npm install
```

Build the App with webpack-cli:

(for windows)
```bash or cmd
.\node_modules\.bin\webpack-cli --mode development
```
(for unix):
```bash or cmd
./node_modules/.bin/webpack-cli --mode development
```
Start Ganache and launch a quickstart testnet

Deploy the smart contract onto your Ganache blockchain:

```bash or cmd
truffle migrate
```
Fire up an http server for development
```bash or cmd
npx http-server ./build/app/ -a 0.0.0.0 -p 8000 -c-1
```
Open the app in your browser with a Meta Mask plugin installed (preferably)

http://127.0.0.1:8000/index.html

