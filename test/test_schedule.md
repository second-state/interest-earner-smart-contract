# Test schedules

## Test staking schedule 1
- 7 Days @ 10% simple interest per annum

**Current situation**

This contract will still be tested to completion, even though there have been slight code changes and future tests over and above this one.
At present waiting on withdraw tokens from reserve pool so that the tokens can be used in other tests
Tx is pending: 0xfa9f281f2e573127f6f78a1b6532608d452910c5f14ec86b5a6eff853311a0c6
Check back later to continue

## Contract addresses
- Test interest earner address on the Ropsten network: `0xa45985abdFA5Ca853104Fb9104Dd8C4D75Cc2Ea2`
- Test ERC20 contract address on the Ropsten network : `0xC9A46174D2dE2c5DA9DaD1226F58BdA9a0698Ba1`

## Users
All user statistics

### User A
- Address: 0x7E11A30C6e94645128Ad236291132c16bDeBF5f6
- Expected interest to date: 114094235159816243816
- Total Staked to date: 61000 (61000000000000000000000)
- Principle withdrawn: 0
- Interest withdrawn: 0
- Correct?: 

#### First stake
- User: 0x7E11A30C6e94645128Ad236291132c16bDeBF5f6
- Timestamp: 1646981630
- Date GMT: Friday, 11 March 2022 06:53:50
- Amount: 50,000 STATE
- Transaction: 0xb957e3a1ccfcabc67c6623a11cf1cc313e635a92aad0c76aa3daf3bba9645baa
- Expected Interest: 95.8904109589035456 STATE (95890410958903545600 Wei)

#### Second stake
- User: 0x7E11A30C6e94645128Ad236291132c16bDeBF5f6
- Timestamp: 1647064128
- Date GMT: Saturday, 12 March 2022 05:48:48
- Amount: 10, 000 STATE
- Transaction: 0x24eb5dfee290d176913b2a0172fd6901db8dcbc23cc17d196d6b4a0af2604021
- Expected Interest: 16.562087772703904728 (16562087772703904728)

#### Third stake
- User: 0x7E11A30C6e94645128Ad236291132c16bDeBF5f6
- Timestamp: 1647068692
- Date GMT: Mar-12-2022 07:04:52 AM +UTC
- Amount: 1000 STATE
- Transaction: 0x049955360409a8cdc50188e745aca6a7193947161a26bdf337de0d518736665b 
- Expected Interest: 1.641736428208793488 (1641736428208793488)

As this third stake is made at a similar time of day (this time with 6 whole days remaining) we can compare it to the first transaction which was made at 7 days remaining by using the following:

`(((1.641736428208793488 * 50) / 6) * 7) = 95.76795831217962`

This shows that the incremental staking (at a different time with a different amount) is accurate. When normalized they are both 95 STATE.

#### Un stake
- User: 0x7E11A30C6e94645128Ad236291132c16bDeBF5f6
- Timestamp: 
- Date GMT: 
- Amount un-staked: 
- Transaction:  
- Interest withdrawn: 

#### Correctness
Given the above data does this appear to be operating correctly?

- [ ] Yes
- [ ] No

---

# Code update after this point (`unstakeAllTokensAndWithdrawInterestEarned` function only)

## Test staking schedule 2
- 1 hour @ 50% simple interest per annum

**Current situation**
Contract eventually deployed on Ropsten
Time period set is pending at https://ropsten.etherscan.io/tx/0x37d6e06c6a394d9eb77f434c1ebb4acd5eb02c4301d71539298bf0733c26b9fa
Percentage set is pending at https://ropsten.etherscan.io/tx/0xc021b045e9145f19d6a71eedc2d161ed0332fb8870b93dd35bb2c0a3b5688421

## Contract addresses
- Test interest earner address on the Ropsten network: `0x2f13511dbd9090bc687440d924111c3f880b97e9`
- Test ERC20 contract address on the Ropsten network : `0xC9A46174D2dE2c5DA9DaD1226F58BdA9a0698Ba1`

## Users
All user statistics

### User A
- Address: 0x7E11A30C6e94645128Ad236291132c16bDeBF5f6
- Expected interest to date: 
- Total Staked to date:
- Principle withdrawn: 
- Interest withdrawn: 
- Correct?: 

#### First stake - on day 1
- User: 0x7E11A30C6e94645128Ad236291132c16bDeBF5f6
- Timestamp: 
- Date GMT: 
- Amount: 
- Transaction: 
- Expected Interest: 

#### Second stake - on day 1
- User: 0x7E11A30C6e94645128Ad236291132c16bDeBF5f6
- Timestamp: 
- Date GMT: 
- Amount: 
- Transaction: 
- Expected Interest: 

#### Third stake - on day 1
- User: 0x7E11A30C6e94645128Ad236291132c16bDeBF5f6
- Timestamp: 
- Date GMT: 
- Amount: 
- Transaction:  
- Expected Interest: 

#### Un stake
- User: 0x7E11A30C6e94645128Ad236291132c16bDeBF5f6
- Timestamp: 
- Date GMT: 
- Amount un-staked: 
- Transaction:  
- Interest withdrawn: 

#### Correctness
Given the above data does this appear to be operating correctly?

- [ ] Yes
- [ ] No

---

## Test staking schedule 3
- 3 day @ 10% simple interest per annum

**Current situation**
Midway in staking 10000, the approval is pending tx at https://ropsten.etherscan.io/tx/0xc5b87669c9472f5e3194d81cfa45076e978ca8ecfe89b92db586e1e4ea238744


## Contract addresses
- Test interest earner address on the Ropsten network: `0xCf5A95A9D502DF563446eD89080c274a036cEC43`
- Test ERC20 contract address on the Ropsten network : `0xC9A46174D2dE2c5DA9DaD1226F58BdA9a0698Ba1`

## Users
All user statistics

### User A
- Address: 0x7E11A30C6e94645128Ad236291132c16bDeBF5f6
- Expected interest to date: 
- Total Staked to date: 
- Principle withdrawn: 
- Interest withdrawn: 
- Correct?: 

#### First stake - on day 1

Confirm no staking because reserve pool is empty

x

Confirm that no staking because reserve pool has some, but not enough; estimate staking 10, 000 tokens for 3 days at 10% will earn 8.2 tokens interest
`((10000 * 0.1)/365) * 3 = 8.21917808219`

After [sending additional 10 tokens](https://ropsten.etherscan.io/tx/0xf3f03b80791da6c0c993f99e15ec3d133b3457796d10c20f31b694c7e61e10b1) (making 11 in the reserve pool total) from the owner to the contract the following can go ahead.

First the user approves the spend


- User: 0x7E11A30C6e94645128Ad236291132c16bDeBF5f6
- Timestamp: 
- Date GMT: 
- Amount: 
- Transaction: 
- Expected Interest: 

#### Second stake - on day 1
- User: 0x7E11A30C6e94645128Ad236291132c16bDeBF5f6
- Timestamp: 
- Date GMT: 
- Amount: 
- Transaction: 
- Expected Interest: 

#### Third stake - on day 1
- User: 0x7E11A30C6e94645128Ad236291132c16bDeBF5f6
- Timestamp: 
- Date GMT: 
- Amount: 
- Transaction:  
- Expected Interest: 

#### Un stake
- User: 0x7E11A30C6e94645128Ad236291132c16bDeBF5f6
- Timestamp: 
- Date GMT: 
- Amount un-staked: 
- Transaction:  
- Interest withdrawn: 

#### Correctness
Given the above data does this appear to be operating correctly?

- [ ] Yes
- [ ] No

---

## Test staking schedule 3 - with RE-staking (optional for future release)
- 1 Day @ 10% simple interest per annum

## Contract addresses
- Test interest earner address on the Ropsten network: 
- Test ERC20 contract address on the Ropsten network : 

## Users
All user statistics

### User A
- Address: 0x7E11A30C6e94645128Ad236291132c16bDeBF5f6
- Expected interest to date: 
- Total Staked to date:
- Principle withdrawn: 
- Interest withdrawn: 
- Correct?: 

#### First stake - on day 1
- User: 0x7E11A30C6e94645128Ad236291132c16bDeBF5f6
- Timestamp: 
- Date GMT: 
- Amount: 
- Transaction: 
- Expected Interest: 

#### Second stake - on day 1
- User: 0x7E11A30C6e94645128Ad236291132c16bDeBF5f6
- Timestamp: 
- Date GMT: 
- Amount: 
- Transaction: 
- Expected Interest: 

#### Third stake - on day 1
- User: 0x7E11A30C6e94645128Ad236291132c16bDeBF5f6
- Timestamp: 
- Date GMT: 
- Amount: 
- Transaction:  
- Expected Interest: 

#### First RE stake - on day 2 (after initial staking term has expired)
- User: 0x7E11A30C6e94645128Ad236291132c16bDeBF5f6
- Timestamp: 
- Date GMT: 
- Amount: 
- Transaction:  
- Expected Interest: 

#### Second RE stake - on day 3 (after first re-stake term has expired)
- User: 0x7E11A30C6e94645128Ad236291132c16bDeBF5f6
- Timestamp: 
- Date GMT: 
- Amount: 
- Transaction:  
- Expected Interest: 

#### Un stake - on day 4 (after second re-stake term has expired)
- User: 0x7E11A30C6e94645128Ad236291132c16bDeBF5f6
- Timestamp: 
- Date GMT: 
- Amount un-staked: 
- Transaction:  
- Interest withdrawn: 

#### Correctness
Given the above data does this appear to be operating correctly?

- [ ] Yes
- [ ] No

---

## Additional manual checks performed

- [x] only owner can call set percentage 
- [x] only owner can call set time period
- [x] the owner can not call the set percentage more than once
- [x] the owner can not call the set time period more than once
- [x] a user can not stake tokens if there is no STATE in the reserve pool
- [ ] a user can not stake tokens if there is not enough STATE in the reserve pool (relative to their investement)
- [ ] a user can not RE stake tokens if there is not enough STATE in the reserve pool (relative to their investement)
- [ ] the owner can remove spare STATE from the reserve pool only (actual exact amount of reserve pool which is not allocated to a user)
- [ ] a user can not un stake tokens whilst the term is still in play
- [ ] a user can not RE stake tokens whilst the term is still in play

