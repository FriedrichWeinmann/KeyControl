function Connect-KeyControl {
	<#
	.SYNOPSIS
		Connects to a entrust Key Control secrets Vault.
	
	.DESCRIPTION
		Connects to a entrust Key Control secrets Vault.

		This module assumes regular account authentication settings (local or ldap).
	
	.PARAMETER ComputerName
		The computer hosting the vault.
	
	.PARAMETER Vault
		The ID of the vault to connect to.
	
	.PARAMETER Credential
		The credentials of the account used for authentication.
	
	.EXAMPLE
		PS C:\> Connect-KeyControl -ComputerName vault.contoso.com -Credential $cred -Vault $vaultID
	
		Connects to the entrust Key Control secrets Vault hosted on "vault.contoso.com", using the credentials provided in $cred.
		It specifically connects to the vault in $vaultID
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$ComputerName,

		[Parameter(Mandatory = $true)]
		[string]
		$Vault,

		[Parameter(Mandatory = $true)]
		[PSCredential]
		$Credential
	)
	process {
		$session = [PSCustomObject]@{
			ComputerName = $ComputerName
			Credential   = $Credential
			Vault        = $Vault
			Token        = ''
			Expires      = (Get-Date).AddMinutes(30)
			BasePath     = "https://$ComputerName/vault/1.0"
		}

		$body = @{
			username = $Credential.UserName
			password = $Credential.GetNetworkCredential().Password
		}
		$response = Invoke-RestMethod -Method POST -Uri "$($session.BasePath)/Login/$Vault/" -Body ($body | ConvertTo-Json) -ContentType 'application/json'

		if ($response.access_token) {
			$session.Token = $response.access_token

			$script:_KeyControlSession = $session
		}
		else {
			throw "Failed to connect: $($response | ConvertTo-Json)"
		}
	}
}