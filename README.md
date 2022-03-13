# Interest Earner Smart Contract

A smart contract which allows users to stake and un-stake a specified ERC20 token and earn interest as a result.

Staked tokens are locked for a specific length of time (the term). This term is set (once only) by the contract owner at the outset. The term remains constant for all users who stake their tokens into this specific contract. The term can not be changed for this contract instance, once set.

After a user has staked tokens and the term has elapsed, the user is then able to remove their tokens and the interest which they earned.

The interest earned is based on the specific simple annual interest rate of this contract instance. As is the case with the term, the simple interest per annum is set (once only) by the contract owner at the outset. The simple annual interest rate remains constant for all users who stake their tokens into this specific contract. The simple interest per annum can not be changed for this contract instance, once set.

![Untitled Diagram (1)](https://user-images.githubusercontent.com/9831342/151649198-5de7bfe2-095a-4d14-9fd4-dd53d78e94a3.jpg)

## How to deploy

### Compile

- Compile the [InterestEarner.sol](https://github.com/second-state/interest-earner-smart-contract/blob/main/InterestEarner.sol) contract.

### Deploy

- Deploy the contract by passing in the official ERC20 token's contract address (i.e. the address of the ERC20 contract instance which users will be staking here in this contract instance) as the one-and-only constructor parameter.

### Set the term (time period in seconds per interest earning round)

- Call the `setTimePeriod` function (as the contract owner) by passing in a value (in seconds) for which you want the term to be. For example a term of 1 month (30.44 days) is equivalent to 2629743 seconds.

Background: Another example, if this `setTimePeriod` value is set to 3600 seconds, then every user who stakes tokens will undergo a one hour interest earning round from the time of their first staked token. Once a user has unstaked (and collected their interest), they are free to kick off another round by staking tokens again; the next round will kick off "as at" the timestamp when the user calls the contract to stake their tokens again.

### Set the simple annual interest rate (as percentage basis points)

- Call the `setPercentage` function. Passing in a value (in wei) which conforms to the following base point system (bps)

	- 10000 wei is equivalent to 100%

	- 1000 wei is equivalent to 10%

	- 100 wei is equivalent to 1%

	- 10 wei is equivalent to 0.1%

	- 1 wei is equivalent to 0.01%
	
Background: For example, a traditional floating point percentage like 8.54% is equivalent to 854 percentage basis points (or in terms of the ethereum uint256 variable, 854 wei). This percentage can only be set once and will remain the interest earning percentage for the life of the contract.

### Post deployment checklist

**ERC20 Token Contract Instance**
- [ ] Call the `erc20Contract()` getter function of the interest earner smart contract which you just deployed and ensure that the value returned is indeed the address of your ERC20 token (i.e. the ERC20 contract address which you expect users to stake and unstake) 

**Time Period**
- [ ] Call the `timePeriodSet()` getter function and ensure that the value returned is `true`
- [ ] Call the `timePeriod()` getter function and ensure that the value returned is the term in seconds

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
- [ ] Call the `owner()` getter function and ensure that the value returned is the external account address which you desire (the interest earner smart contract's owner - you)

**Initial values**
- [ ] Call the `totalExpectedInterest()` getter function and ensure that the value returned is `0`
- [ ] Call the `totalStateStaked()` getter function and ensure that the value returned is `0`
- [ ] Call the `totalExpectedInterest()` getter function and ensure that the value returned is `0`

---


## Test the contract manually in Remix (as apposed to using the DApps User Interface (UI))

### Choose a network

Please see the section called [setting up Ropsten testnet](#setting-up-ropsten-testnet) below if you need help setting up a testnet environment.

### Deploy an ERC20 token for testing

Deploy an ERC20 token to be used in conjuntion with this smart contract and UI.

In this test case we have used [the ParaState ERC20 source code](https://etherscan.io/address/0xdc6104b7993e997ca5f08acab7d3ae86e13d20a6#code) and deployed this documentation's Test ERC20 token over on [Ropsten test network](https://ropsten.etherscan.io/address/0xC9A46174D2dE2c5DA9DaD1226F58BdA9a0698Ba1).

The test ERC20 contract address on the Ropsten network is `0xC9A46174D2dE2c5DA9DaD1226F58BdA9a0698Ba1`

### Deploy the interest earner smart contract for testing

In this test case, in relation to our interest earner, we again deploy on [Ropsten test network](https://ropsten.etherscan.io/address/0xa45985abdFA5Ca853104Fb9104Dd8C4D75Cc2Ea2)

The test interest earner address on the Ropsten network is `0xa45985abdFA5Ca853104Fb9104Dd8C4D75Cc2Ea2`


### Configure the interest earner for normal operation

First we set the term by calling the `setTimePeriod` function (as the owner). In this example we are making the term **7 Days** which is equal to `604800` seconds.

<img width="274" alt="Screen Shot 2022-03-11 at 3 50 10 pm" src="https://user-images.githubusercontent.com/9831342/157819331-64994c14-5b18-4804-a5f1-c6d71a18b932.png">

<img width="288" alt="Screen Shot 2022-03-11 at 3 46 07 pm" src="https://user-images.githubusercontent.com/9831342/157819403-3c805b91-6fd7-48e4-ad1b-5fa7af50c5c3.png">

Next we set the percentage basis points (as the owner). In this example we are making the simple annual interest rate `10%` per annum which is equal to `1000` Wei.

<img width="277" alt="Screen Shot 2022-03-11 at 3 53 57 pm" src="https://user-images.githubusercontent.com/9831342/157819351-b04f72c2-3130-48d5-aee3-4f05b2fbeeb3.png">

<img width="276" alt="Screen Shot 2022-03-11 at 3 58 22 pm" src="https://user-images.githubusercontent.com/9831342/157819432-27d18841-b025-4738-bb38-0de1b8c66402.png">

### Simulate a user staking (for 7 days at 10 percent)

First, **as the owner**, we have to send some STATE to the reserve pool so that the contract is able to pay any upcoming staking users. The contract will not let a user stake if the reserve pool can not pay out the principle and interest of the entire staking/un-staking rund trip for the term.

We transfer `100` STATE from the owner's address to the contract's address. **Note: nobody except for the interest earner contract instance owner should EVER send STATE directly to the contract address EVER.**

We transferred `100` STATE because the predicted interest will be `95.89041` i.e. 
`50, 000` * `0.10` = `5, 000` (5, 000 is 10 percent of 50, 000)
(`5, 000` / `365` days) * `7` days = `95.89041` (`95.89041` is the interest which the user will earn at 10% during the 7 day period).

Next, **as the user (not the owner)**, we perform the `approve` function (on the ERC20 contract instance) by passing in the Interest Earner Smart Contract's deployment address. Also add an amount of tokens which you would like to approve the Interest Earner Smart Contract to spend on the user's behalf. In this case `50, 000`.

**This approval step is actually performed by the DApp's User Interface (UI), we are just testing manually here on purpose.**

<img width="278" alt="Screen Shot 2022-03-11 at 4 16 14 pm" src="https://user-images.githubusercontent.com/9831342/157819518-f8585e84-c988-43cc-b1ca-70f7e5726c88.png">


Next, **as the user (not the owner)**, we check that the user has actually approved the contract by calling the `allowance` function of the ERC20 contract (passing in  the owner and spender address).

<img width="280" alt="Screen Shot 2022-03-11 at 4 16 24 pm" src="https://user-images.githubusercontent.com/9831342/157819541-bb187883-f43d-455a-8aa8-cfc844d8bd8b.png">

Next, **as the user (not the owner)**, we stake the `50, 000` tokens by calling the `stakeTokens` function, by passing in the ERC20 contract address and amount in wei (`50000`).

<img width="276" alt="Screen Shot 2022-03-11 at 5 11 41 pm" src="https://user-images.githubusercontent.com/9831342/157819693-fb9f5196-c8e3-4c79-b874-89765fd90675.png">

### Check details associated with this user's staking

We can see that the `initialStakingTimestamp` has been set. `1646981630` is equal to Friday, 11 March 2022 16:53:50 GMT+10:00 which is correct. You can cross reference this time against the [block timestamp](https://ropsten.etherscan.io/tx/0xb957e3a1ccfcabc67c6623a11cf1cc313e635a92aad0c76aa3daf3bba9645baa) as at when the `stakeTokens` function was called.

<img width="280" alt="Screen Shot 2022-03-11 at 4 56 15 pm" src="https://user-images.githubusercontent.com/9831342/157819756-22d12816-beff-41fa-b8e9-12b33500d4ce.png">

We can see that the `getTotalStakedState` getter shows the `50, 000` staked tokens from the user.

<img width="277" alt="Screen Shot 2022-03-11 at 4 55 58 pm" src="https://user-images.githubusercontent.com/9831342/157819782-a20dd09b-9126-4246-8e68-8e2a7ced7961.png">

We can see that the `getTotalExpectedInterest` getter show the correct `95.89041` interest owing.

<img width="282" alt="Screen Shot 2022-03-11 at 4 55 49 pm" src="https://user-images.githubusercontent.com/9831342/157819827-3cd82ca8-ddd8-4227-a4b7-a2de5baf521b.png">

We can see that the `expectedInterest` for just that user (by passing in the user's address) is also showing that correct `95.89041` interest owing.

<img width="279" alt="Screen Shot 2022-03-11 at 4 55 30 pm" src="https://user-images.githubusercontent.com/9831342/157819864-8a5f53e2-0a35-4ce7-b4aa-0ab5ab6f15aa.png">

We can see that the `balances` for just that user is `50000000000000000000000` Wei (which is the correct `50, 000` tokens).

<img width="281" alt="Screen Shot 2022-03-11 at 4 55 13 pm" src="https://user-images.githubusercontent.com/9831342/157819903-beff7b8a-1914-45d5-95b5-90993353a886.png">

### Simulate that same user staking again 

Simulate that same user staking again (still at 10%), only this time, with approx 6 days remaining in the term.

If we look at the state of the Ropsten testnet at block [12075020](https://ropsten.etherscan.io/block/12075020) via the interest earner's user interface, we can see the state of the reserve pool (and make a decision on if it needs to be topped up by the contract owner).

<img width="412" alt="Screen Shot 2022-03-12 at 2 40 14 pm" src="https://user-images.githubusercontent.com/9831342/158003948-8f38c89f-caee-4837-850a-472c1771f97d.png">

We can see here that:
- reserve pool = 50, 100
- total staked = 50, 000
- total expected interest = 95.8904109589035456

If we add total staked and total expected interest (`50, 000 + 95.8904109589035456`) we get `50095.8904109589035456`. 

If we subtract that amount from the reserve pool (`50100 - (50, 000 + 95.8904109589035456)`) we get `4.1095890410964544` (4109589041096454400 in Wei)

This means that there is only `4.1` spare/unallocated STATE tokens available for new incoming staking users to earn interest.

If the user was to attempt to stake an additional `1, 000 tokens` the following would happen.

`10, 000` * `0.10` = `1, 000` (1, 000 is 10 percent of 10, 000)
(`1, 000` / `365` days) * `6` approximate remaining days = `16.4` (`16.4` is the interest which the user will earn at 10% during the approximate 6 day period remaining).

We can see that there are only `4.1` in the reserve pool so this transaction would revert and the user would not be able to stake.

<img width="763" alt="Screen Shot 2022-03-12 at 2 49 07 pm" src="https://user-images.githubusercontent.com/9831342/158004161-48b8588d-35a9-4bbd-80ec-a9e6250477f9.png">

---

### Testing removing extra STATE from the reserve pool

This is a great opportunity to test the functionality of the `transferTokensOutOfReservePool`. 

Background: As part of normal operation **the owner** of this contract sends STATE to this contract to facilitate earnings, the owner is also able to remove any STATE tokens which are not already allocated to a user (in terms of both principle and interest). Using the calculations above, we can see that we have 4109589041096454400 Wei which is spare/unallocated.

If we try to remove even one more Wei than that amount, the contract will revert (this means that user funds are maintained by the contract and can't be removed by anyone but them). Let's try removing `4109589041096454400 + 1` i.e. `4109589041096454401` to prove this.

<img width="278" alt="Screen Shot 2022-03-12 at 3 01 55 pm" src="https://user-images.githubusercontent.com/9831342/158004740-ce20ec74-d072-4bc8-aba1-7844f1cd6e35.png">

The above request produces the following revert error.

<img width="496" alt="Screen Shot 2022-03-12 at 3 02 02 pm" src="https://user-images.githubusercontent.com/9831342/158004747-f2305bfb-3fbc-437f-91fc-9b8a4bf491a1.png">

Now let's just try and remove one Wei less than what is spare/unallocated i.e. `4109589041096454400` - `1` = `4109589041096454399` (equivalent to `4.109589041096454399` STATE)

<img width="273" alt="Screen Shot 2022-03-12 at 3 28 36 pm" src="https://user-images.githubusercontent.com/9831342/158005194-33b41e84-28cd-4cde-8010-ef64a561c768.png">

That worked, and now we can see in the admin portal that the reserve pool number is colored red to signify that the tolerance of 1 token has been met. This is a warning so that the contract owner knows that the reserve pool is running very low.

<img width="407" alt="Screen Shot 2022-03-12 at 3 27 25 pm" src="https://user-images.githubusercontent.com/9831342/158005497-f1a94f17-45c3-426e-98c0-ce48d5a4e3f7.png">

---

Back to the second staking from the previous section.

Note, for this documentation **as the owner**, we have already sent some STATE to the reserve pool so that the contract is able to pay this upcoming staking user.

We stake the additional 10, 000 STATE (at 10%) with approx 6 days to go, via the UI, as shown below.

<img width="395" alt="Screen Shot 2022-03-12 at 3 51 32 pm" src="https://user-images.githubusercontent.com/9831342/158005860-1084491d-86d3-461f-8dc6-9ca7a54d5d84.png">

We return to the home screen of the UI and see the following updated statistics.

<img width="408" alt="Screen Shot 2022-03-12 at 3 49 22 pm" src="https://user-images.githubusercontent.com/9831342/158005818-7c430606-323a-4134-9158-7e12979af4e8.png">

---

## Setting up Ropsten Testnet

### Network tokens

Obtain some Ropsten Testnet ETH (rETH) from a Ropsten Testnet Faucet like the one below

< https://ropsten.oregonctf.org/ >

### Wallet software

Connect your MetaMask wallet to the Ropsten Testnet; if you can't see Ropsten in the list then click the `Show/hide test networks` button slider at the top.

<img width="386" alt="Screen Shot 2022-03-11 at 3 19 11 pm" src="https://user-images.githubusercontent.com/9831342/157807070-587fa302-aa4e-4a18-bb47-f311ccec0ba2.png">

### Smart Contract IDE

Open [Remix](https://remix.ethereum.org/) and select the "Injected Web3" option from the Environment menu on the bottom tab (Ethereum logo)

<img width="456" alt="Screen Shot 2022-03-11 at 2 06 42 pm" src="https://user-images.githubusercontent.com/9831342/157806972-c5e01624-d558-4d26-a590-8f959aa701ff.png">

You can now go ahead and compile, deploy, configure and interact directly with the contract.

