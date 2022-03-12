# Test schedules

## Test staking schedule 1
- 7 Days @ 10% simple interest per annum

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
- Timestamp: 
- Date GMT: Mar-12-2022 07:04:52 AM +UTC
- Amount: 1000 STATE
- Transaction: 0x049955360409a8cdc50188e745aca6a7193947161a26bdf337de0d518736665b 
- Expected Interest: 1.641736428208793488 (1641736428208793488)

As this third stake is made at a similar time of day (this time with 6 whole days remaining) we can compare it to the first transaction which was made at 7 days remaining by using the following:

`(((1.641736428208793488 * 50) / 6) * 7) = 95.76795831217962`

This shows that the incremental staking (at a different time with a different amount) is accurate. When normalized they are both 95 STATE.

