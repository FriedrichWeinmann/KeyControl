function Connect-KeyControl {
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