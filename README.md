# Interest Earner Smart Contract

A smart contract which allows users to stake and un-stake a specified ERC20 token and earn interest as a result. Staked tokens are locked for a specific length of time, at a specific simple annual interest rate. After a user has staked tokens and the term has elapsed, the user is then able to remove their tokens and the interest which they earned.

![Untitled Diagram (1)](https://user-images.githubusercontent.com/9831342/151649198-5de7bfe2-095a-4d14-9fd4-dd53d78e94a3.jpg)

## How to deploy

### Owner

- [ ] Create a brand new account (a new private/public key pair); and do not share the private key with anyone. 
- [ ] Ensure that the aforementioned account is selected in your wallet software i.e. MetaMask or similar.
- [ ] Ensure that your wallet software is connected to the correct network, in this case, the Ethereum mainnet.

### Compile

- [ ] Compile the [InterestEarner.sol](https://github.com/second-state/interest-earner-smart-contract/blob/main/InterestEarner.sol) contract using Solidity `0.8.11` via the [Remix IDE](https://remix.ethereum.org/). Using version `0.8.11` is important because it provides overflow checks and is compatible with the version of SafeMath which the contract uses.

![Screen Shot 2022-03-14 at 10 19 22 am](https://user-images.githubusercontent.com/9831342/158085888-03dc1213-0b55-440b-a2ad-199b3fef54cd.png)

### Deploy

- [ ] Ensure that Remix environment is set to "Injected Web3" so that the execution environment is provided by your MetaMask (or similar) wallet software (which must currently be on the Ethereum mainnet with your new owner's account selected).

![Screen Shot 2022-03-14 at 10 20 27 am](https://user-images.githubusercontent.com/9831342/158086216-c45f31ff-762a-4e4c-9cd4-6ddc3c91d1e8.png)

- [ ] Deploy the contract by passing in the official ERC20 token's contract address (i.e. the address of the ERC20 contract instance which users will be staking here in this contract instance).

- [ ] Store the contract address of this newly deployed contract instance for future reference (owner will need to send STATE to this address soon).

### Set the term (time period in seconds per interest earning round)

- [ ] Call the `setTimePeriod` function (as the contract owner) by passing in a value (in seconds) for which you want the term to be. For example a term of 1 month (30.44 days) is equivalent to 2629743 seconds. This time period (term) can only be set once and will remain the term for the life of the contract.

### Set the simple annual interest rate (as percentage basis points)

- [ ] Call the `setPercentage` function. Passing in a value (in wei) which conforms to the following base point system (bps):

	- 10000 wei is equivalent to 100%

	- 1000 wei is equivalent to 10%

	- 100 wei is equivalent to 1%

	- 10 wei is equivalent to 0.1%

	- 1 wei is equivalent to 0.01%
	
Background: For example, a traditional floating point percentage like 8.54% is equivalent to 854 percentage basis points (or in terms of the ethereum uint256 variable, 854 wei). This percentage can only be set once and will remain the interest earning percentage for the life of the contract.

### Post deployment checklist

**ERC20 Token Contract Instance**
- [ ] Call the `erc20Contract()` getter function of the interest earner smart contract instance which you just deployed and ensure that the value returned is indeed the address of your ERC20 token (i.e. the ERC20 contract address which you expect users to stake and unstake).

**Time Period**
- [ ] Call the `timePeriodSet()` getter function and ensure that the value returned is `true`.
- [ ] Call the `timePeriod()` getter function and ensure that the value returned is the term (in seconds) which you desired.

**Percentage Basis Points**
- [ ] Call the `percentageSet()` getter function and ensure that the value returned is `true`
- [ ] Call the `percentageBasisPoints()` getter function and ensure that the value returned is the percentage basis points which you desired. See the following table to convert from percentage basis points to percent.

```
10000 wei is equivalent to 100%
1000 wei is equivalent to 10%
100 wei is equivalent to 1%
10 wei is equivalent to 0.1%
1 wei is equivalent to 0.01%
```

**Ownership**
- [ ] Call the `owner()` getter function and ensure that the value returned is your newly created account address (the interest earner smart contract's owner - you).

**Initial values**
- [ ] Call the `totalExpectedInterest()` getter function and ensure that the value returned is `0`
- [ ] Call the `totalStateStaked()` getter function and ensure that the value returned is `0`
- [ ] Call the `totalExpectedInterest()` getter function and ensure that the value returned is `0`

### Fund the interest earner contract

When you are satisfied with all of the above steps, as the owner, please go ahead and fund the interest earner contract.

- [ ] Transfer the appropriate amount of funds from a source of STATE to your new recently created owner's account address.
- [ ] As the owner, transfer an appropriate amount of STATE from your owner's account address straight to this recently deployed interest earner's smart contract address (the address of the interest earner contract instance which you just deployed).


## Congratulations

The contract is now ready for use!

