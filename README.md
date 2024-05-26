# EthBerlin 4 Hackathon

## Howl's Moving Contract: Kabuso Cash

### The name?

The Team named itself "Howl's Moving Contract", because as the moving Castle in the Studio Ghibli film, our contract stays in motion, making it harder to be tracked.

Also, Kabuso (the Doge Dog) died. He was a good dog and we are sad that he died.

### The problem Kabuso solves

With the persecution and eventual sentencing of Alexey Pertsev for his involvement with Tornado-Cash, the codebase basically became radioactive. It's initial vision for preserving privacy and anonymity in an inherently public ecosystem still stands though, even though recent events pose a dangerous precedent.
So in the spirit of EthBerlin, and especially this years topic, we snuggled up to the radioactivity and made it worse :)

1. We took the Tornado-Core repo and updated the contracts (from 0.7.0 to 0.8.26).
2. Then we put them into Foundry, because using Truffle + Ganache for testing purposes just won't cut it in 2024.

After doing the initial groundwork, we were able to run an up-to-date version of Tornado Cash locally.

3. So then we modified the contracts.

The idea is that the contract is able to re-deploy every 20160 blocks (~ every two weeks), so that it becomes available under a new address. This should make it harder for authorities to block or penalize interaction with the new contract address for the userbase.

In order to achieve this, we had to make the following changes:

- implement a counter that checks if 20160 blocks have passed
- implement storage for redeploymentGasFees
- after the passing of 20160 blocks + the accumulation of enough redeploymentGasFees, the redeploy-function becomes executable.
- when a user executes this function, a new contract will be created from a factory method
- the funds from the old pools, as well as the list of previous commitments are send to the new contract ( => old deposits promises are still withdrawable in the new deployment)
- deposit and withdraw function in the old contract get disabled ( => no funds can get locked in)
- the initiating user gets rewarded with the remainder of the redeploymentGasFees as an incentive for users to trigger this function when it becomes available

Since the contract address is continuously moving forward, it will be harder for authorities to track / ban / blacklist interaction with the mixer.

### Challenges we ran into

- the zK stuff, especially:
- installing huffc compiler (every team member now hates the huff language with a passion)
- containing our exponentially growing fondness of foundry. It is amazing.
- since we build all hackathon, we didn't have enough time to listen to the good techno music outsite.

### Technology used

- Tornado-Core repository
- Solidity
- zk-Stuff (circom)
- Javascript
- Foundry
