The following is a list of statements about the intended logic of the interest earner smart contract:

- This term is set (once only) by the contract owner at the outset. 
- The term remains constant for all users who stake their tokens into this specific contract. 
- The term can not be changed for this contract instance, once set.
- The interest earned is based on the specific simple annual interest rate of this contract instance.
- As is the case with the term, the simple interest per annum is set (once only) by the contract owner at the outset. 
- The simple annual interest rate remains constant for all users who stake their tokens into this specific contract. 
- The simple interest per annum can not be changed for this contract instance, once set.
- Only the owner can call set percentage 
- Only the owner can call set time period
- The owner can not call the set percentage more than once
- The owner can not call the set time period more than once
- A user can not stake tokens if there is no STATE in the reserve pool
- A user can not stake tokens if there is not enough STATE in the reserve pool (relative to their investement)
- A user can not RE stake tokens if there is not enough STATE in the reserve pool (relative to their investement)
- The owner can remove spare STATE from the reserve pool only (actual exact amount of reserve pool which is not allocated to a user)
- A user can not un stake tokens whilst the term is still in play
- A user can not RE stake tokens whilst the term is still in play
