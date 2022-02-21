### Input

This script accepts an `xlsx` spreadsheet with the following conventions.

- Spreadsheet must be three columns

#### First column

- The first column must be formatted as plain string only. This first column is your description for your own records

#### Second column

- The second column must be formatted as plain string only. This second column is for single Ethereum compatible addresses to which tokens will be sent

#### Third column

- The third column contains the amount of tokens in Wei (which will be sent to the Ethereum compatible address on that same row)

For example to send one ETH you would put 1000000000000000000 (1, followed by eighteen decimal places). For another example 1/2 ETH you would put 500000000000000000 (5, followed by seventeen decimal places).

Please use an [online Wei converter](https://eth-converter.com/) if you need assistance with this.

# NOTE

User is to:
-  ensure that no decimal places in the spreadsheet
- ensure that both address and wei columns are formatted to plain text
- ensure that first row must be data i.e. no headings/no heading row; just plain text and valid addresses and amounts only
- ensure that there are no spare rows i.e. no blank rows at the end

Ensure that the spreadsheet, mentioned above, is a file called `input.xlsx` and also make sure that the spreadsheet is saved into the same directory as the `bulkDepositTokens.py` script which we about to run


**Open the config.ini file and fill in all of the details including RPC, ChainId, private and public key of contract owner, block explorer URLs and so forth.**

#### Important!

You will need to update the `config.ini` when you repeat these tasks again for the other contract instances i.e. the `60` day timelock address and then the `90` day timelock contract address will need to be pasted into the `config.ini` file **otherwise you will send the tokens to the wrong contract**

The config.ini file looks like this

```
[blockchain]
rpc = https://ropsten.infura.io/v3/asdf
chainid = 3
gasprice = 5000000
gaslimit = 5000000

[sender]
privatekey = 
publickey = 

[data]
inputfile = input.xlsx

[explorer]
address = https://ropsten.etherscan.io/address/
transaction = https://ropsten.etherscan.io/tx/

# IMPORTANT, MAKE SURE YOU UPDATE THIS ADDRESS IF USING MORE THAN ONE TIMELOCK INSTANCE i.e. 60 day and 90 day etc.
# If this address is not updated when you work with the new timelock contract instances you will send funds to the wrong contract

[contract]
timelockaddress = 0x_ALWAYS_UPDATE_ME
```

When the config is sorted, run the following command in order to precheck the spreadsheet. This is a very important step because it actually gives you the total of ERC20 tokens (in wei) which you need to transfer to the timelock contract's address in an upcoming step. Please read the output, ensure that it is correct and then write down or save the total amount to be transferred in wei value (as shown below).

```

Total rows processed is 1106
Total amount to be transferred in wei is 3786800000000000000000
Total amount to be transferred in whole tokens is 3786.8


ONLY RUN THE BULK DEPOSIT TOKENS SCRIPT IF THESE NUMBERS ARE CORRECT!
```


Transfer the sum total of all ERC20 tokens (which are to be locked up) to the Timelock contract’s address.

IMPORTANT: This sum total must exactly equal the amount of tokens which will be processed via the Timelock token’s “depositTokens” function. 

This step makes the Timelock contract the owner of the ParaState ERC20 tokens.

Calling the depositTokens performs the allocation of these tokens to the potential recipient addresses.

The Timelock token then takes care of disbursing the tokens to the appropriate recipients at the appropriate time frames. This approach is non-custodial (fully controlled on chain once depositTokens step below is complete)


Note: the ERC20 contract must have 18 decimal places (in order to conform to ERC20 standard and be exchangeable on DEXs). For example, the transfer from the last step would be in wei i.e. 1 million tokens in wei would be `1000000000000000000000000`

Confirm via the ERC20 token’s “balanceOf” function, that the Timelock token owns the appropriate amount of tokens from the last step

Confirm that the owner of the ERC20 contract owns the appropriate amount of tokens (whatever that may be)

