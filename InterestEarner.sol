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
    event tokensStaked(address from, uint256 amount);
    event TokensUnstaked(address to, uint256 amount);
    event InterestEarned(address to, uint256 amount);

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
        require(token == erc20Contract, "You are only allowed to stake the official erc20 token address which was passed into this contract's constructor");
        // Set the initial staking timestamp (if not already set)
        if (initialStakingTimestamp[msg.sender] == 0){
            initialStakingTimestamp[msg.sender] = block.timestamp;
        }
        // Let's calculate the maximum amount which can be earned per annum
        uint256 interestEarnedPerAnnum = amount.mul(percentageBasisPoints.div(10000));
        // Let's calculate the release date
        uint256 releaseEpoch = initialStakingTimestamp[msg.sender].add(timePeriod);
        // Let's fragment the interest earned per annum down to the remaining time left on this staking round
        uint256 secondsRemaining = releaseEpoch.sub(block.timestamp);
        // Let's calculate how many wei are earned per second
        uint256 weiPerSecond = interestEarnedPerAnnum.div(31536000);
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
        emit tokensStaked(msg.sender, amount);
        emit InterestEarned(msg.sender, interestEarnedForThisStake);
    }

    /// @dev Allows user to unstake tokens after the correct time period has elapsed
    /// @param token - address of the official ERC20 token which is being unlocked here.
    /// @param amount - the amount to unlock (in wei)
    function unstakeTokens(IERC20 token, uint256 amount) public timePeriodIsSet percentageIsSet noReentrant {
        // Both expectedInterest and balances must be sent back to the user's wallet as part of this function
        require(balances[msg.sender] >= amount, "Insufficient token balance, try lesser amount");
        require(token == erc20Contract, "Token parameter must be the same as the erc20 contract address which was passed into the constructor");
        if (block.timestamp >= timePeriod) {
            alreadyWithdrawn[msg.sender] = alreadyWithdrawn[msg.sender].add(amount);
            balances[msg.sender] = balances[msg.sender].sub(amount);
            token.safeTransfer(msg.sender, amount);
            emit TokensUnstaked(msg.sender, amount);
        } else {
            revert("Tokens are only available after correct time period has elapsed");
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
}