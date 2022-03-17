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
- Timestamp: 1647491521
- Date GMT: Mar-17-2022 04:32:01 AM +UTC
- Amount: 10000
- Transaction: [0x91870da46511f0539894a3570304b3f35a47a8fcbd5bb3886ce1f40037218eff](https://ropsten.etherscan.io/tx/0x91870da46511f0539894a3570304b3f35a47a8fcbd5bb3886ce1f40037218eff)
- Expected Interest: 0.5707762557077592 (570776255707759200)

Testing that a user can not stake more than they have available in their wallet

Remix 1

![Screen Shot 2022-03-17 at 2 43 37 pm](https://user-images.githubusercontent.com/9831342/158739355-6aee25d3-fb78-480a-b4b7-c1bd7bc75099.png)

Remix 2

![Screen Shot 2022-03-17 at 2 43 26 pm](https://user-images.githubusercontent.com/9831342/158739376-71e8328c-efb5-48b1-a8c0-901c8fe91e2e.png)

UI 1

![Screen Shot 2022-03-17 at 2 50 11 pm](https://user-images.githubusercontent.com/9831342/158739439-b82db0db-47a8-4192-b191-da65b450df1c.png)

#### Second stake - on hour 1
- User: 0x7E11A30C6e94645128Ad236291132c16bDeBF5f6
- Timestamp: 1647492730
- Date GMT: Mar-17-2022 04:52:10 AM +UTC
- Amount: 10000
- Transaction: [0x5ff281ea4a16df7664feeb2bff9bd92c52828720084b62f5d56eba22bc649a7e](https://ropsten.etherscan.io/tx/0x5ff281ea4a16df7664feeb2bff9bd92c52828720084b62f5d56eba22bc649a7e)
- Expected Interest: 0.379090563165903402 (379090563165903402)

#### Un stake

**Term is ready for unstaking at  Thursday, 17 March 2022 15:32:01 GMT+10**

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
- Expected interest to date: 13.007023718924194992 (13007023718924194992)
- Total Staked to date: 29000
- Principle withdrawn: 0
- Interest withdrawn: 0
- Correct?: 

#### First stake - on day 1

Starting out with newly deployed contract; reserve pool is emplty.

![Screen Shot 2022-03-15 at 10 24 36 am](https://user-images.githubusercontent.com/9831342/158287343-62ecb820-a140-4119-b42d-99be62152968.png)

Confirm no staking because reserve pool is empty

![Screen Shot 2022-03-15 at 10 48 56 am](https://user-images.githubusercontent.com/9831342/158287318-59ee1e37-4c9f-43fb-8872-ff40eb344244.png)

Place only 1 to test that stakin is still not allowed with low reserve pool

![Screen Shot 2022-03-15 at 10 42 16 am](https://user-images.githubusercontent.com/9831342/158287383-f6ec8590-cc69-4c28-872b-f77d9857fae8.png)

Confirm that no staking because reserve pool has some, but not enough; estimate staking 10, 000 tokens for 3 days at 10% will earn 8.2 tokens interest
`((10000 * 0.1)/365) * 3 = 8.21917808219`

After [sending additional 10 tokens](https://ropsten.etherscan.io/tx/0xf3f03b80791da6c0c993f99e15ec3d133b3457796d10c20f31b694c7e61e10b1) (making 11 in the reserve pool total) from the owner to the contract the following can go ahead.

![Screen Shot 2022-03-15 at 10 51 27 am](https://user-images.githubusercontent.com/9831342/158287466-7a7226f6-3c09-4c72-b4c6-84e0b077248a.png)

First the user approves the spend

![Screen Shot 2022-03-15 at 10 52 08 am](https://user-images.githubusercontent.com/9831342/158287484-17a382ef-7094-48a7-b5a8-b75157f6d86d.png)

Once transaction is successful, we can see the admin screen with the details

![Screen Shot 2022-03-15 at 11 54 08 am](https://user-images.githubusercontent.com/9831342/158290492-b94ce827-baae-4aad-a5cb-fe117d559e49.png)

The user's home screen also shows details/balances for the user in detail, as shown below

![Screen Shot 2022-03-15 at 11 55 12 am](https://user-images.githubusercontent.com/9831342/158290566-9ee91d5d-54cd-443a-92b9-985deed6e030.png)

- User: 0x7E11A30C6e94645128Ad236291132c16bDeBF5f6
- Timestamp: 1647307824
- Date GMT: Mar-15-2022 01:30:24 AM +UTC
- Amount: 10, 000 STATE
- Transaction: [0x3f4eb5566e4d3a45af8aea91354476672425adca32e906d096ed04622c3637f3](https://ropsten.etherscan.io/tx/0x3f4eb5566e4d3a45af8aea91354476672425adca32e906d096ed04622c3637f3)
- Expected Interest: 8.2191780821916288

At this point the owner can remove any spare/unallocated tokens from the reserve pool.

The amount owed to users is as follows

Total STATE staked + total interest owed

`10000000000000000000000 + 8219178082191628800 = 10008219178082191628800`

The reserve pool is simply the `balanceOf` the interest earner's contract address in the ERC20 token i.e.

![Screen Shot 2022-03-15 at 12 32 31 pm](https://user-images.githubusercontent.com/9831342/158294319-6203c957-9ab3-4d7e-8f78-81a5eb340dc9.png)

`10011000000000000000000`

The reserve pool amount - the total amount owned to users is what the owner is allows to withdraw.

`10011000000000000000000 - 10008219178082191628800 = 2780821917808371200` i.e. `2.7808219178083712` in Eth denomination.

First we attempt to withdraw that amount plus 1 Wei to test.

![Screen Shot 2022-03-15 at 12 36 35 pm](https://user-images.githubusercontent.com/9831342/158294686-a8c97e2f-f76e-4aeb-862d-cf0dae736179.png)

We get the correct result.

![Screen Shot 2022-03-15 at 12 35 56 pm](https://user-images.githubusercontent.com/9831342/158294708-8b100954-db5a-401f-b5fe-96034b532b7b.png)

If instead the exact correct amount of spare tokens is attempted, this will correctly succeed.

![Screen Shot 2022-03-15 at 12 37 56 pm](https://user-images.githubusercontent.com/9831342/158294877-6305bba1-6dfc-412d-8b3c-4819c6d5908e.png)

The admin user interface now highlights (in red) that the reserve pool is low and needs topping up

![Screen Shot 2022-03-15 at 12 42 40 pm](https://user-images.githubusercontent.com/9831342/158295373-831460a7-c303-4dcc-b86e-8a70d362642b.png)

Let the owner now transfer tokens to the contract to make the reserve pool large enough to fund interest earning for new stake operations. Owner sent 100 STATE via [tx: 0x17f0a92135cea84077d99175e85c21371cfc6121b46755146373a5789d527e3c](https://ropsten.etherscan.io/tx/0x17f0a92135cea84077d99175e85c21371cfc6121b46755146373a5789d527e3c)


#### Second stake 
- User: 0x7E11A30C6e94645128Ad236291132c16bDeBF5f6
- Timestamp: 1647487391
- Date GMT: Mar-17-2022 03:23:11 AM +UTC
- Amount: 10000
- Transaction: [0x19afd019afef0b6d17f1f4cd4a5626109212b8cb0e0ef540c9e8ff38f0fda273](https://ropsten.etherscan.io/tx/0x19afd019afef0b6d17f1f4cd4a5626109212b8cb0e0ef540c9e8ff38f0fda273)
- Expected Interest: 2.525145865043078612 (2525145865043078612)

#### Third stake
- User: 0x7E11A30C6e94645128Ad236291132c16bDeBF5f6
- Timestamp: 1647487739
- Date GMT: Mar-17-2022 03:28:59 AM +UTC
- Amount: 9000
- Transaction: [0xcea3b8d4f1a8f21feeb24f6563ca54113406b7105346f4b779eaf5c120eed4c8](https://ropsten.etherscan.io/tx/0xcea3b8d4f1a8f21feeb24f6563ca54113406b7105346f4b779eaf5c120eed4c8)
- Expected Interest: 2.26269977168948758 (2262699771689487580)

This attempt to unstake is correctly denied because the round is still active.

![Screen Shot 2022-03-17 at 1 51 38 pm](https://user-images.githubusercontent.com/9831342/158734107-1a5d55b6-f426-404c-918e-a028d3faa6a2.png)

We will unstake on or after the correct unstaking time of Friday, 18 March 2022 11:30:24 GMT+10:00

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

### Staking and Un-staking
- [x] only owner can call set percentage 
- [x] only owner can call set time period
- [x] the owner can not call the set percentage more than once
- [x] the owner can not call the set time period more than once
- [x] a user can not stake tokens if there is no STATE in the reserve pool
- [x] a user can not stake tokens if there is not enough STATE in the reserve pool (relative to their investement)
- [x] the owner can remove spare STATE from the reserve pool only (actual exact amount of reserve pool which is not allocated to a user)
- [x] a user can not un stake tokens whilst the term is still in play
- [x] a user can not stake tokens if they do not have that amount of tokens freely available in their wallet

### Restaking
- [ ] a user can not RE stake tokens if there is not enough STATE in the reserve pool (relative to their investement)
- [ ] a user can not RE stake tokens whilst the term is still in play
