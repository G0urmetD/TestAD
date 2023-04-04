# TestAD Module
```PowerShell
Import-Module .\TestAD.psm1
```

# Scripts
## Test-ADPasswords
Script to test AD passwords on one or more accounts.
Note: Every test from this script, counts as failed login on a user account. Be careful to not lock someone out.

## Usage
```PowerShell
# Test one account with specific password
Test-ADPasswords -username test1 -password asdF1234 -computername testserver01

# Test several accounts with on specific password
'test1', 'test2' | Test-ADPasswords -password asdF1234 -computername testserver01

# Test user from specific OU
Get-ADUser -Filter * -SearchBase '<OU>' | Test-ADPasswords -password asdF1234 -computername testserver01 | Sort-Object -Property PasswordCorrect

# Test user from specific OU, only returns password matched accounts
Get-ADUser -Filter * -SearchBase '<OU>' | Test-ADPasswords -password asdF1234 -computername testserver01 | Where-Object PasswordCorrect -eq $true
```
