# KeyControl: Vault for Secrets

PowerShell Client Module for the [Entrust KeyControl](https://www.entrust.com/products/key-management/keycontrol) component "Vault for Secrets".

## Notes

This module is somewhat limited, solving a very specific use-case, but I am open to contributions.

What it can currently do:

+ Connect to a Vault for Secrets using credentials (should work well for Local users & LDAP deployments).
+ List, Search and retrieve Boxes in a Vault
+ List, Search and retrieve Secrets from a Box

## Install

To install the module, run this in a PowerShell console:

```powershell
Install-Module KeyControl -Scope CurrentUser
```

## Use

To use the module, first we need to connect:

```powershell
$vaultID = '00000000-0000-0000-0000-000000000000'
$cred = Get-Credential
Connect-KeyControl -ComputerName vault.contoso.com -Credential $cred -Vault $vaultID
```

> List Boxes

```powershell
Get-KeyControlBox
```

> List Secrets

```powershell
Get-KeyControlSecret -BoxID $boxID
```

Note: This will _not_ retrieve the secret data, just list the secrets.

> Retrieve Secret (including secret data)

```powershell
Get-KeyControlSecret -BoxID $boxID -SecretID $secretID
```

> Search for Secrets

```powershell
# By Name
Get-KeyControlSecret -BoxID $boxID -Name "exch-*"

# By Tag (Where the tag "service" has the value "exo")
Get-KeyControlSecret -BoxID $boxID -Tags @{ service = 'exo' }
# By Tag (Where the tag "service" has the value "exo" and "stage" has the value "dev")
Get-KeyControlSecret -BoxID $boxID -Tags @{ service = 'exo'; stage = 'dev' }
```

## Developer Notes

Trying to figure things out with the available documentation can be a bit of a challenge, when you want to do it in native PowerShell.
Feel very free to use my own module as reference - I am aware the features it covers are limited, but it may prove useful when solving your own cases.

Resources I found useful when implementing this:

+ [API Reference](https://docs.hytrust.com/DataControl/Online/Content/Books/Secrets-Vault-Programmers-Reference/API/Accessing-the-SV-API.html): Mostly describes the data, less the rest calls, but good for that.
+ [Filter Documentation](https://docs.hytrust.com/DataControl/Online/Content/Books/Secrets-Vault-Programmers-Reference/API/API-Filters.html): Great when trying to make filters work.
+ [Source code of the commandline tool](https://github.com/EntrustCorporation/pasmcli/tree/master/pasmcli/cmd): Written in GO, but a good place to find the specific API endpoints and see what paramters are mandatory and what are optional, and how to provide them.

With the expectation, that this module is likely not enough to cover all your needs, I have exposed two commands for developer use:

+ `Invoke-KeyControlRequest`: This helps develop and execute your own requests and allows you to focus on the actual concerns of the endpoint you want to interact with.
+ `Assert-KeyControlConnection`: A simple check, whether you are already connected, providing a useful error information while being invisible to the user. Place at the beginning of commands depending on already being connected.
