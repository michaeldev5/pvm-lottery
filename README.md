# Polkadot Millionaire Lottery

## Description
Our project aims to create a decentralized lottery inspired by the subreddit r/millionairemakers. 
Participants need to deposit a fixed amount of tokens to enter the lottery, where each of these deposits are recorded on-chain.
Every month the smart cotract will select one winner using a simple randomness algorithm based on block data.
The winner receives all the tokens deposited for that period minus a predefined fixed platform fee.

## Research and Conclusions

We analyzed two existing solutions that use blockchain, First one is PoolTogether, a no-loss lottery application built on Ethereum, which uses decentralized randomness by using Chainlink Verifiable Randomness Function.
It uses a no-loss principle allowing participants to withdraw their assets anytime they want.

Another analyzed solution is Cryptolotto which works autonomously and with no entity controlling the key functions.
The main idea of Cryptolotto is straightforward: people from all over the world contribute equal amounts of ETH to one wallet during the set period of time.

