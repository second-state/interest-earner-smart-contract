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
    mapping(address => uint256) public alreadyWithdrawn;
    mapping(address => uint256) public balances;

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


    /// @dev Allows the contract to share its amount of ERC20 tokens i.e. the reserve pool which pays out each of the user's interest
    /// @param token, the official ERC20 token which this contract exclusively accepts.
    /// @return amount of tokens in reserve pool
    function getReservePoolAmount(IERC20 token) public view returns (uint256) {
        return token.balanceOf(address(this));
        }

    /// @dev Allows the contract owner to allocate official ERC20 tokens to each future recipient (only one at a time).
    /// @param token, the official ERC20 token which this contract exclusively accepts.
    /// @param amount to allocate to recipient.
    function stakeTokens(IERC20 token, uint256 amount) public timePeriodIsSet percentageIsSet {
        
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
        // Make sure that contract's reserve pool has enough to service this transaction
        require(totalExpectedInterest.add(interestEarnedForThisStake) <= token.balanceOf(address(this)), "Not enough STATE tokens in the reserve pool, please contact owner of this contract");
        // Adding this user's expected interest to the expected interest variable
        totalExpectedInterest.add(interestEarnedForThisStake);
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

    /// @dev Allows user to unstake tokens after the correct time period has elapsed
    /// @param token - address of the official ERC20 token which is being unlocked here.
    /// @param amount - the amount to unlock (in wei)
    function unstakeTokens(IERC20 token, uint256 amount) public timePeriodIsSet percentageIsSet noReentrant {
        require(block.timestamp > (initialStakingTimestamp[msg.sender].add(timePeriod)), "Locking time period is still active, please try again later");
        require(token == erc20Contract, "Token parameter must be the same as the erc20 contract address which was passed into the constructor");
        // Both expectedInterest and balances must be sent back to the user's wallet as part of this function
        require(balances[msg.sender] >= amount, "Insufficient token balance, try lesser amount");
        // Create value which represents the amount of interest about to be paid
        uint256 interestToPayOut = expectedInterest[msg.sender];
        // Adjust the already withdrawn mapping to reflect the amount which the msg.sender is unstaking
        alreadyWithdrawn[msg.sender] = alreadyWithdrawn[msg.sender].add(amount);
        // Adjust the already withdrawn mapping to reflect the amount of earned interest which the msg.sender is now receiving
        alreadyWithdrawn[msg.sender] = alreadyWithdrawn[msg.sender].add(expectedInterest[msg.sender]);
        // Reduce the balance of the msg.sender to reflect how much they are unstaking during this transaction
        balances[msg.sender] = balances[msg.sender].sub(amount);
        // Reduce the value which represents interest owed to the msg.sender all the way to zero, because we are paying out all of the interest in this transaction
        expectedInterest[msg.sender] = 0;
        // Make sure that this transaction will revert if there is a discrepancy in the expected interest values which are held within this contract
        require(totalExpectedInterest >= interestToPayOut);
        // Reduce the total amount of interest owed by this contract (to all of its users) using the appropriate amount
        totalExpectedInterest.sub(interestToPayOut);
        // Transfer staked tokens back to user's wallet
        token.safeTransfer(msg.sender, amount);
        // Transfer interest earned during the time period, into the user's wallet
        token.safeTransfer(msg.sender, interestToPayOut);
        // Emit the event logs
        emit TokensUnstaked(msg.sender, amount);
        emit InterestWithdrawn(msg.sender, interestToPayOut);
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
}