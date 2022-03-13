# Re-stake logic with psuedo code and data example

## Source code

```javascript
    // SPDX-License-Identifier: MIT
    // WARNING this contract has not been independently tested or audited
    // DO NOT use this contract with funds of real value until officially tested and audited by an independent expert or group

    /// @dev Allows user to unstake tokens and withdraw their interest after the correct time period has elapsed and then reinvest automatically.
    /// @param token - address of the official ERC20 token which is being unlocked here.
    /// Reinvests all principle and all interest earned during the most recent term
    function reinvestAlreadyStakedTokensAndInterestEarned(IERC20 token) public timePeriodIsSet percentageIsSet noReentrant {
        // Ensure that there is a current round of interest at play
        require(initialStakingTimestamp[msg.sender] != 0, "No tokens staked at present");
        // Ensure that the current time period has elapsed and that funds are ready to be unstaked
        require(block.timestamp > (initialStakingTimestamp[msg.sender].add(timePeriod)), "Locking time period is still active, please try again later");
        // Ensure the official ERC20 contract is being referenced
        require(token == erc20Contract, "Token parameter must be the same as the erc20 contract address which was passed into the constructor");
        // Ensure there is enough reserve pool for this to proceed
        require(expectedInterest[msg.sender].add(balances[msg.sender]) <= token.balanceOf(address(this)), "Not enough STATE tokens in the reserve pool to pay out the interest earned, please contact owner of this contract");
        uint256 newAmountToInvest = expectedInterest[msg.sender].add(balances[msg.sender]);
        require(newAmountToInvest > 315360000000, "Amount to stake must be greater than 0.00000031536 ETH");
        require(newAmountToInvest < MAX_INT.div(10000), "Maximum amount must be smaller, please try again");
        // Transfer expected previous interest to staked state
        emit TokensUnstaked(msg.sender, balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].add(expectedInterest[msg.sender]);
        // Adjust totals
        // Increment the total State staked
        totalStateStaked = totalStateStaked.add(expectedInterest[msg.sender]);
        // Decrease total expected interest for this users past stake
        totalExpectedInterest = totalExpectedInterest.sub(expectedInterest[msg.sender]);
        emit InterestWithdrawn(msg.sender, expectedInterest[msg.sender]);
        // Reset msg senders expected interest
        expectedInterest[msg.sender] = 0;
        // Start a new time period
        initialStakingTimestamp[msg.sender] = block.timestamp;
        // Let's calculate the maximum amount which can be earned per annum (start with mul calculation first so we avoid values lower than one)
        uint256 interestEarnedPerAnnum_pre = newAmountToInvest.mul(percentageBasisPoints);
        // We use basis points so that Ethereum's uint256 (which does not have decimals) can have percentages of 0.01% increments. The following line caters for the basis points offset
        uint256 interestEarnedPerAnnum_post = interestEarnedPerAnnum_pre.div(10000);
        // Let's calculate how many wei are earned per second
        uint256 weiPerSecond = interestEarnedPerAnnum_post.div(31536000);
        require(weiPerSecond > 0, "Interest on this amount is too low to calculate, please try a greater amount");
        // Let's calculate the release date
        uint256 releaseEpoch = initialStakingTimestamp[msg.sender].add(timePeriod);
        // Let's fragment the interest earned per annum down to the remaining time left on this staking round
        uint256 secondsRemaining = releaseEpoch.sub(block.timestamp);
        // We must ensure that there is a quantifiable amount of time remaining (so we can calculate some interest; albeit proportional)
        require(secondsRemaining > 0, "There is not enough time left to stake for this current round");
        // There are 31536000 seconds per annum, so let's calculate the interest for this remaining time period
        uint256 interestEarnedForThisStake = weiPerSecond.mul(secondsRemaining);
        // Make sure that contract's reserve pool has enough to service this transaction. I.e. there is enough STATE in this contract to pay this user's interest (not including/counting any previous end user's staked STATE or interest which they will eventually take as a pay out)
        require(token.balanceOf(address(this)) >= totalStateStaked.add(totalExpectedInterest).add(interestEarnedForThisStake), "Not enough STATE tokens in the reserve pool, to facilitate this restake, please contact owner of this contract");
        // Adding this user's new expected interest
        totalExpectedInterest = totalExpectedInterest.add(interestEarnedForThisStake);
        // Increment the new expected interest for this user (up from being reset to zero)
        expectedInterest[msg.sender] = expectedInterest[msg.sender].add(interestEarnedForThisStake);
        emit TokensStaked(msg.sender, newAmountToInvest);
        emit InterestEarned(msg.sender, interestEarnedForThisStake);
    }
```

## Logic with data example

Time period is one day
Simple annual interest is 10%

**DATA example**
| Variable                            | Data         |
|-------------------------------------|--------------|
| block.timestamp                     | 1647143500   |
| initialStakingTimestamp[msg.sender] | 1647057046   |
| timePeriod                          | 86400        |
| expectedInterest[msg.sender]        |              |
| balances[msg.sender]                |              |
| newAmountToInvest                   |              |
| totalExpectedInterest               | 400000       |
| totalStateStaked                    | 400000000000 |
| weiPerSecond                        |              |
| releaseEpoch                        |              |
| secondsRemaining                    |              |
| interestEarnedForThisStake          |              |
| token.balanceOf(address(this))      | 800000000000 |
| percentageBasisPoints               | 1000         |


- the `initialStakingTimestamp[msg.sender]` must not be zero i.e. there must be tokens staked ✅
- the `block.timestamp` must be greater than the initialStakingTimestamp[msg.sender] and the timePeriod of the term in play (term must be over already) i.e. `1647143500 > 1647143446` must be true ✅
- the token address passed in to the function must be the same as the official ERC20 which is being staked here ✅
- the expectedInterest[msg.sender] alread owed to this user plus the balance currently staked by this user must be less than or equal to the amount available in the reserve pool i.e. `(400000000000 + 400000) < 800000000000` ✅
- the new amount to invest is the sum of the principle and interest owned to this `msg.sender` i.e. `400000400000` ✅
- the new amount must qualify in terms of min and max allowable values i.e. `400000400000 > 315360000000` and `400000400000 < 2**256 - 1` ✅
- tokens are released in terms of emitting an event log only ✅

**DATA example update**

| Variable                            | Data         |
|-------------------------------------|--------------|
| block.timestamp                     | 1647143500   |
| initialStakingTimestamp[msg.sender] | 1647057046   |
| timePeriod                          | 86400        |
| expectedInterest[msg.sender]        | 400000       |
| balances[msg.sender]                | 400000000000 |
| newAmountToInvest                   | 400000400000 |
| totalExpectedInterest               | 400000       |
| totalStateStaked                    | 400000000000 |
| weiPerSecond                        |              |
| releaseEpoch                        |              |
| secondsRemaining                    |              |
| interestEarnedForThisStake          |              |
| token.balanceOf(address(this))      | 800000000000 |
| percentageBasisPoints               | 1000         |


- tokens already in the `msg.sender`'s balance can stay there, the `expectedInterest[msg.sender]` is appended to the aforementioned balance ✅
- `totalStateStaked` is then incremented with interest earned (which is now being reinvested as STATE) ✅
- `totalExpectedInterest` is then decremented with same amount as in previous step ✅
- an event is emitted to show interest has been withdrawn ✅
- now the `expectedInterest[msg.sender]` for `msg.sender` is set back to zero value ✅
- now there is a new term kicking off so `initialStakingTimestamp[msg.sender]` is now set to `block.timestamp` ✅
- a interestEarnedPerAnnum_pre calculation is performed `400000400000 * 1000 = 400000400000000` ✅
- a interestEarnedPerAnnum_post calculation is performed `400000400000000 / 10000 = 40000040000` ✅
- the amount of wei per second is now calculated `40000040000 / 31536000 = 1268` ✅
- requirement that wei per second is greater than zero ✅
- a `releaseEpoch` is calculated i.e. `initialStakingTimestamp[msg.sender]` plus `timePeriod` which equals `1647229900` which is one day in the future ✅
- the `secondsRemaining` is calculated next i.e. `releaseEpoch` - `block.timestamp` which at this present time is `86400` ✅ (we are at the full term point)
- requirement that the `secondsRemaining` is a number greater than zero ✅

| Variable                            | Data         |
|-------------------------------------|--------------|
| block.timestamp                     | 1647143500   |
| initialStakingTimestamp[msg.sender] | 1647143500   |
| timePeriod                          | 86400        |
| expectedInterest[msg.sender]        | 0            |
| balances[msg.sender]                | 400000400000 |
| newAmountToInvest                   | 400000400000 |
| totalExpectedInterest               | 0            |
| totalStateStaked                    | 400000400000 |
| weiPerSecond                        | 1268         |
| releaseEpoch                        | 1647229900   |
| secondsRemaining                    | 86400        |
| interestEarnedForThisStake          |              |
| token.balanceOf(address(this))      | 800000000000 |
| percentageBasisPoints               | 1000         |


- now the interest earned for this re-stake is calculated `interestEarnedForThisStake = weiPerSecond.mul(secondsRemaining)` i.e. `1268 * 86400 = 109555200` ✅
- using the new data below, we satisfy the requirement that `token.balanceOf(address(this)) >= totalStateStaked.add(totalExpectedInterest).add(interestEarnedForThisStake)` i.e. `800000000000 >= 400000400000 + 0 + 109555200` which is correct ✅

**DATA example update**

| Variable                            | Data         |
|-------------------------------------|--------------|
| block.timestamp                     | 1647143500   |
| initialStakingTimestamp[msg.sender] | 1647143500   |
| timePeriod                          | 86400        |
| expectedInterest[msg.sender]        | 0            |
| balances[msg.sender]                | 400000400000 |
| newAmountToInvest                   | 400000400000 |
| totalExpectedInterest               | 0            |
| totalStateStaked                    | 400000400000 |
| weiPerSecond                        | 1268         |
| releaseEpoch                        | 1647229900   |
| secondsRemaining                    | 86400        |
| interestEarnedForThisStake          | 109555200    |
| token.balanceOf(address(this))      | 800000000000 |
| percentageBasisPoints               | 1000         |

- now the `totalExpectedInterest` is increased to show this new interest being earned i.e.`totalExpectedInterest + interestEarnedForThisStake` ✅
- also now allocate the `expectedInterest[msg.sender]` i.e. `expectedInterest[msg.sender] + interestEarnedForThisStake` ✅
- an event is emitted to log `TokensStaked(msg.sender, newAmountToInvest)` ✅
- an event is emitted to log `InterestEarned(msg.sender, interestEarnedForThisStake)` ✅

**DATA example final**

| Variable                            | Data         |
|-------------------------------------|--------------|
| block.timestamp                     | 1647143500   |
| initialStakingTimestamp[msg.sender] | 1647143500   |
| timePeriod                          | 86400        |
| expectedInterest[msg.sender]        | 109555200    |
| balances[msg.sender]                | 400000400000 |
| newAmountToInvest                   | 400000400000 |
| totalExpectedInterest               | 109555200    |
| totalStateStaked                    | 400000400000 |
| weiPerSecond                        | 1268         |
| releaseEpoch                        | 1647229900   |
| secondsRemaining                    | 86400        |
| interestEarnedForThisStake          | 109555200    |
| token.balanceOf(address(this))      | 800000000000 |
| percentageBasisPoints               | 1000         |



