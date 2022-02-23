// SPDX-License-Identifier: MIT
// WARNING this contract has not been independently tested or audited
// DO NOT use this contract with funds of real value until officially tested and audited by an independent expert or group

pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";

contract InterestEarner {
    // boolean to prevent reentrancy
    bool internal locked;

    // Library usage
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    // Input validation
    uint256 internal MAX_INT = 2**256 - 1;

    // Contract owner
    address public owner;

    // Timestamp related variables
    // The timestamp at the time the user initially staked their tokens
    mapping(address => uint256) public initialStakingTimestamp;
    bool public timePeriodSet;
    uint256 public timePeriod;

    // Yield related variables
    bool public percentageSet;
    uint256 public percentageBasisPoints;
    mapping(address => uint256) public expectedInterest;
    uint256 public totalExpectedInterest;


    // Token amount variables
    mapping(address => uint256) public balances;
    uint256 public totalStateStaked;

    // ERC20 contract address
    IERC20 public erc20Contract;

    // Events
    event TokensStaked(address from, uint256 amount);
    event TokensUnstaked(address to, uint256 amount);
    event InterestEarned(address to, uint256 amount);
    event InterestWithdrawn(address to, uint256 amount);

    /// @dev Deploys contract and links the ERC20 token which we are staking, also sets owner as msg.sender and sets timePeriodIsSet & percentageSet & locked bools to false.
    /// @param _erc20_contract_address.
    constructor(IERC20 _erc20_contract_address) {
        // Set contract owner
        owner = msg.sender;
        // Time period value not set yet
        timePeriodSet = false;
        // Perdentage value not set yet
        percentageSet = false;
        // Set the erc20 contract address which this timelock is deliberately paired to
        require(address(_erc20_contract_address) != address(0), "_erc20_contract_address address can not be zero");
        erc20Contract = _erc20_contract_address;
        // Initialize the reentrancy variable to not locked
        locked = false;
        // Initialize the total amount of STATE staked
        totalStateStaked = 0;
        // Initialize the time period
        timePeriod = 0;
        // Initialize the base points (bps)
        percentageBasisPoints = 0;
        // Initialize total expectedinterest
        totalExpectedInterest = 0;
    }

    // Modifier
    /**
     * @dev Prevents reentrancy
     */
    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    // Modifier
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Message sender must be the contract's owner.");
        _;
    }

    // Modifier
    /**
     * @dev Throws if time period already set.
     */
    modifier timePeriodNotSet() {
        require(timePeriodSet == false, "The time stamp has already been set.");
        _;
    }

    // Modifier
    /**
     * @dev Throws if time period is not set.
     */
    modifier timePeriodIsSet() {
        require(timePeriodSet == true, "Please set the time stamp first, then try again.");
        _;
    }


    // Modifier
    /**
     * @dev Throws if time percentageBasisPoints already set.
     */
    modifier percentageNotSet() {
        require(percentageSet == false, "The percentageBasisPoints has already been set.");
        _;
    }

    // Modifier
    /**
     * @dev Throws if percentageBasisPoints is not set.
     */
    modifier percentageIsSet() {
        require(percentageSet == true, "Please set the percentageBasisPoints variable first, then try again.");
        _;
    }
    /// @dev Sets the staking period for this specific contract instance (in seconds) i.e. 3600 = 1 hour
    /// @param _timePeriodInSeconds is the amount of seconds which the contract will add to the a user's initialStakingTimestamp mapping, each time a user initiates a staking action
    function setTimePeriod(uint256 _timePeriodInSeconds) public onlyOwner timePeriodNotSet  {
        timePeriodSet = true;
        timePeriod = _timePeriodInSeconds;
    }

    /// @dev Sets the percentageBasisPoints rate (in Wei) for this specific contract instance 
    /// 10000 wei is equivalent to 100%
    /// 1000 wei is equivalent to 10%
    /// 100 wei is equivalent to 1%
    /// 10 wei is equivalent to 0.1%
    /// 1 wei is equivalent to 0.01%
    /// Whereby a traditional floating point percentage like 8.54% would simply be 854 percentage basis points (or in terms of the ethereum uint256 variable, 854 wei)
    /// @param _percentageBasisPoints is the annual percentage yield as per the above instructions
    function setPercentage(uint256 _percentageBasisPoints) public onlyOwner percentageNotSet  {
        require(_percentageBasisPoints >= 1 && _percentageBasisPoints <= 10000, "Percentage must be a value >=1 and <= 10000");
        percentageSet = true;
        percentageBasisPoints = _percentageBasisPoints;
    }

    /// @dev Allows the contract to share the amount of ERC20 tokens which are staked by its users
    /// @return amount of tokens currently staked
    function getTotalStakedStake() public view returns (uint256) {
        return totalStateStaked;
        }

    /// @dev Allows the contract to share the current total expected interest which will be paid to all users
    /// @return amount of tokens currently owned to users
    function getTotalExpectedInterest() public view returns (uint256) {
        return totalExpectedInterest;
        }

    /// @dev Allows the contract to share its amount of ERC20 tokens i.e. the reserve pool which pays out each of the user's interest
    /// @param token, the official ERC20 token which this contract exclusively accepts.
    /// @return amount of tokens in reserve pool
    function getReservePoolAmount(IERC20 token) public view returns (uint256) {
        return token.balanceOf(address(this));
        }

    /// @dev Allows the contract owner to allocate official ERC20 tokens to each future recipient (only one at a time).
    /// @param token, the official ERC20 token which this contract exclusively accepts.
    /// @param amount to allocate to recipient.
    function stakeTokens(IERC20 token, uint256 amount) public timePeriodIsSet percentageIsSet noReentrant{
        // Ensure that we are communicating with official ERC20 and not some other random ERC20 contract
        require(token == erc20Contract, "You are only allowed to stake the official erc20 token address which was passed into this contract's constructor");
        // Ensure that the message sender actually has enough tokens in their wallet to proceed
        require(amount <= token.balanceOf(msg.sender), "Not enough ERC20 tokens in your wallet, please try lesser amount");
        // Ensure minimum "amount" requirements
        // Details:
        // There are 31536000 seconds in a year
        // We use percentage basis points which have a max value of 10, 000 (i.e. a range from 1 to 10, 000 which is equivalent to 0.01% to 100% interest)
        // Therefore, in terms of minimum allowable value, we need the staked amount to always be greater than 0.00000031536 ETH
        // Having this minimum amount will avoid us having any zero values in our calculations (anything multiplied by zero is zero; must avoid this at all costs)
        // This is fair enough given that this approach allows us to calculate interest down to 0.01% increments with minimal rounding adjustments
        require(amount >= 315360000000, "Amount to stake must be greater than 0.00000031536 ETH");
        // Similarly, in terms of maximum allowable value, we need the staked amount to be less than 2**256 - 1 / 10, 000 (to avoid overflow)
        require(amount < MAX_INT.div(10000) , "Maximum amount must be smaller, please try again");
        // If this is the first time an external account address is staking, then we need to set the initial staking timestamp to the currently block's timestamp
        if (initialStakingTimestamp[msg.sender] == 0){
            initialStakingTimestamp[msg.sender] = block.timestamp;
        }
        // Let's calculate the maximum amount which can be earned per annum (start with mul calculation first so we avoid values lower than one)
        uint256 interestEarnedPerAnnum_pre = amount.mul(percentageBasisPoints);
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
        require(totalExpectedInterest.add(interestEarnedForThisStake) <= token.balanceOf(address(this)).sub(totalStateStaked), "Not enough STATE tokens in the reserve pool, please contact owner of this contract");
        // Adding this user's expected interest to the expected interest variable
        totalExpectedInterest = totalExpectedInterest.add(interestEarnedForThisStake);
        // Increment the total State staked
        totalStateStaked = totalStateStaked.add(amount);
        // Transfer the tokens into the contract (stake/lock)
        token.safeTransferFrom(msg.sender, address(this), amount);
        // Update this user's locked amount (the amount the user is entitled to unstake/unlock)
        balances[msg.sender] = balances[msg.sender].add(amount);
        // Update this user's interest component i.e. the amount of interest which will be paid from the reserve pool during unstaking
        expectedInterest[msg.sender] = expectedInterest[msg.sender].add(interestEarnedForThisStake);
        // Emit the log for this transaction
        emit TokensStaked(msg.sender, amount);
        emit InterestEarned(msg.sender, interestEarnedForThisStake);
    }


    /// @dev Allows the contract owner to allocate official ERC20 tokens to each future recipient 
    /// @param token, the official ERC20 token which this contract exclusively accepts.
    /// @param recipients, an array of addresses of the many recipient.
    /// @param amounts to allocate to each of the many recipient.
    function bulkStakeTokens(IERC20 token, address[] calldata recipients, uint256[] calldata amounts) external onlyOwner timePeriodIsSet percentageIsSet noReentrant{
        require(recipients.length == amounts.length, "The recipients and amounts arrays must be the same size in length");
        // Ensure that we are communicating with official ERC20 and not some other random ERC20 contract
        require(token == erc20Contract, "You are only allowed to stake the official erc20 token address which was passed into this contract's constructor");
        for(uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Address can not be the zero address");
            // Ensure minimum "amount" requirements
            // Details:
            // There are 31536000 seconds in a year
            // We use percentage basis points which have a max value of 10, 000 (i.e. a range from 1 to 10, 000 which is equivalent to 0.01% to 100% interest)
            // Therefore, in terms of minimum allowable value, we need the staked amount to always be greater than 0.00000031536 ETH
            // Having this minimum amount will avoid us having any zero values in our calculations (anything multiplied by zero is zero; must avoid this at all costs)
            // This is fair enough given that this approach allows us to calculate interest down to 0.01% increments with minimal rounding adjustments
            require(amounts[i] >= 315360000000, "Amount to stake must be greater than 0.00000031536 ETH");
            // Similarly, in terms of maximum allowable value, we need the staked amount to be less than 2**256 - 1 / 10, 000 (to avoid overflow)
            require(amounts[i] < MAX_INT.div(10000) , "Maximum amount must be smaller, please try again");
            // If this is the first time an external account address is staking, then we need to set the initial staking timestamp to the currently block's timestamp
            if (initialStakingTimestamp[recipients[i]] == 0){
                initialStakingTimestamp[recipients[i]] = block.timestamp;
            }
            // Let's calculate the maximum amount which can be earned per annum (start with mul calculation first so we avoid values lower than one)
            uint256 interestEarnedPerAnnum_pre = amounts[i].mul(percentageBasisPoints);
            // We use basis points so that Ethereum's uint256 (which does not have decimals) can have percentages of 0.01% increments. The following line caters for the basis points offset
            uint256 interestEarnedPerAnnum_post = interestEarnedPerAnnum_pre.div(10000);
            // Let's calculate how many wei are earned per second
            uint256 weiPerSecond = interestEarnedPerAnnum_post.div(31536000);
            require(weiPerSecond > 0, "Interest on this amount is too low to calculate, please try a greater amount");
            // Let's calculate the release date
            uint256 releaseEpoch = initialStakingTimestamp[recipients[i]].add(timePeriod);
            // Let's fragment the interest earned per annum down to the remaining time left on this staking round
            uint256 secondsRemaining = releaseEpoch.sub(block.timestamp);
            // We must ensure that there is a quantifiable amount of time remaining (so we can calculate some interest; albeit proportional)
            require(secondsRemaining > 0, "There is not enough time left to stake for this current round");
            // There are 31536000 seconds per annum, so let's calculate the interest for this remaining time period
            uint256 interestEarnedForThisStake = weiPerSecond.mul(secondsRemaining);
            // Make sure that contract's reserve pool has enough to service this transaction. I.e. there is enough STATE in this contract to pay this user's interest (not including/counting any previous end user's staked STATE or interest which they will eventually take as a pay out)
            require(totalExpectedInterest.add(interestEarnedForThisStake) <= token.balanceOf(address(this)).sub(totalStateStaked), "Not enough STATE tokens in the reserve pool, please contact owner of this contract");
            // Adding this user's expected interest to the expected interest variable
            totalExpectedInterest = totalExpectedInterest.add(interestEarnedForThisStake);
            // Increment the total State staked
            totalStateStaked = totalStateStaked.add(amounts[i]);
            // Update this user's locked amount (the amount the user is entitled to unstake/unlock)
            balances[recipients[i]] = balances[recipients[i]].add(amounts[i]);
            // Update this user's interest component i.e. the amount of interest which will be paid from the reserve pool during unstaking
            expectedInterest[recipients[i]] = expectedInterest[recipients[i]].add(interestEarnedForThisStake);
            // Emit the log for this transaction
            emit TokensStaked(recipients[i], amounts[i]);
            emit InterestEarned(recipients[i], interestEarnedForThisStake);
        }
    }

    /// @dev Allows user to unstake tokens and withdraw their interest after the correct time period has elapsed. All funds are released and the user's initial staking timestamp is reset to allow for the user to start another round of interest earning. A single user can not have overlapping rounds of staking.
    //  All tokens are unstaked and all interest earned during the elapsed time period is paid out 
    /// @param token - address of the official ERC20 token which is being unlocked here.
    function unstakeAllTokensAndWithdrawInterestEarned(IERC20 token) public timePeriodIsSet percentageIsSet noReentrant {
        // Ensure that there is a current round of interest at play
        require(initialStakingTimestamp[msg.sender] != 0, "No tokens staked at present");
        // Ensure that the current time period has elapsed and that funds are ready to be unstaked
        require(block.timestamp > (initialStakingTimestamp[msg.sender].add(timePeriod)), "Locking time period is still active, please try again later");
        // Ensure the official ERC20 contract is being referenced
        require(token == erc20Contract, "Token parameter must be the same as the erc20 contract address which was passed into the constructor");
        // Both expectedInterest and balances must be sent back to the user's wallet as part of this function
        // Create a value which represents the amount of tokens about to be unstaked
        uint256 amountToUnstake = balances[msg.sender];
        // Decrease the total STATE staked
        totalStateStaked = totalStateStaked.sub(amountToUnstake);
        // Create a value which represents the amount of interest about to be paid
        uint256 interestToPayOut = expectedInterest[msg.sender];
        // Make sure that contract's reserve pool has enough to service this transaction
        require(interestToPayOut <= token.balanceOf(address(this)), "Not enough STATE tokens in the reserve pool to pay out the interest earned, please contact owner of this contract");
        // Reduce the balance of the msg.sender to reflect how much they are unstaking during this transaction
        balances[msg.sender] = balances[msg.sender].sub(amountToUnstake);
        // Reset the initialStakingTimestamp[msg.sender] in preparation for future rounds of interest earning from the specific user
        initialStakingTimestamp[msg.sender] = 0;
        // Transfer staked tokens back to user's wallet
        token.safeTransfer(msg.sender, amountToUnstake);
        // Emit the event log
        emit TokensUnstaked(msg.sender, amountToUnstake);
        // Finally, perform interest withdrawl tasks if required
        if(interestToPayOut > 0){
            // Make sure that this transaction will revert if there is a discrepancy in the expected interest values which are held within this contract
            require(totalExpectedInterest >= interestToPayOut);
            // Reduce the value which represents interest owed to the msg.sender
            expectedInterest[msg.sender] = expectedInterest[msg.sender].sub(interestToPayOut);
            // Reduce the total amount of interest owed by this contract (to all of its users) using the appropriate amount
            totalExpectedInterest = totalExpectedInterest.sub(interestToPayOut);
            // Transfer interest earned during the time period, into the user's wallet
            token.safeTransfer(msg.sender, interestToPayOut);
            // Emit the event log
            emit InterestWithdrawn(msg.sender, interestToPayOut);
        }
    }

    /// @dev Transfer accidentally locked ERC20 tokens.
    /// @param token - ERC20 token address.
    /// @param amount of ERC20 tokens to remove.
    function transferAccidentallyLockedTokens(IERC20 token, uint256 amount) public onlyOwner noReentrant {
        require(address(token) != address(0), "Token address can not be zero");
        // This function can not access the official timelocked tokens; just other random ERC20 tokens that may have been accidently sent here
        require(token != erc20Contract, "Token address can not be ERC20 address which was passed into the constructor");
        // Transfer the amount of the specified ERC20 tokens, to the owner of this contract
        token.safeTransfer(owner, amount);
    }

    /// @dev Transfer tokens out of the reserve pool (back to owner)
    /// @param token - ERC20 token address.
    /// @param amount of ERC20 tokens to remove.
    function transferTokensOutOfReservePool(IERC20 token, uint256 amount) public onlyOwner noReentrant {
        require(address(token) != address(0), "Token address can not be zero");
        // This function can only access the official timelocked tokens
        require(token == erc20Contract, "Token address must be ERC20 address which was passed into the constructor");
        // Ensure that user funds which are due for user payout can not be removed. Only allowed to remove spare STATE (over-supply which is just sitting in the reserve pool for future staking interest calculations)
        require(amount < (totalExpectedInterest.add(totalStateStaked)), "Can only remove tokens which are spare i.e. not put aside for end user pay out");
        // Transfer the amount of the specified ERC20 tokens, to the owner of this contract
        token.safeTransfer(owner, amount);
    }
}