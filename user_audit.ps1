# mass audit of user systems
# disable non-essential user accounts
# remove from administrator groups

#Requires -RunAsAdministrator

Import-Module ActiveDirectory

# get list of all users on a system at start of competition
# backup list to jumpbox

Get-ADUser -Filter * -Properties * |
    Select -Property Name |
    Export-CSV "C:\UserAudit.csv" -NoTypeInformation -Encoding UTF8

# Disable all accounts
Import-Csv -Path "C:\UserAudit.csv" | ForEach-Object {
    $
        Set-ADUser-Identity $_.'User-Name' -Enabled $false
    }


