
This is a modified version of https://github.com/Claustn/CreateProfile.
Removed tests primarily, as those were not Pester v5 compliant.

# CreateProfile
PowerShell Module that uses WINAPI to create system profiles

## SHORT DESCRIPTION
A PowerShell module to create a new local user profile before a user logs into a machine

## LONG DESCRIPTION
A PowerShell module that will create a new local user account and map it to a SID.  After that it will auto-login/create the user profile so that the user's profile is now mapped before they have even logged into a machine.

## DETAILED DESCRIPTION
A PowerShell module that will create a new local user account and map it to a SID.  After that it will auto-login/create the user profile so that the user's profile is now mapped before they have even logged into a machine.

## Example

```
> Import-Module .\CreateProfile\CreateProfile.psm1
> New-Profile -UserName 'Josh Thom' -Password 'P@ssw0rd123'
```