function Connect-KeyControl {
	[CmdletBinding()]
	param (
		[string]
		$ComputerName,

		[PSCredential]
		$Credential
	)
	process {
		$session = [PSCredential]@{
			ComputerName = $ComputerName
			Credential   = $Credential
			Token        = ''
			Expires      = (Get-Date).AddMinutes(30)
			BasePath     = "https://$ComputerName/vault/1.0"
		}

		$body = @{
			username = $Credential.UserName
			password = $Credential.GetNetworkCredential().Password
		}
		$response = Invoke-RestMethod -Method POST -Uri "$($session.BasePath)/login/" -Body ($body | ConvertTo-Json) -ContentType 'application/json'

		if ($response.result -eq 'success') {
			$session.Token = $response.access_token

			$script:_KeyControlSession = $session
		}
	}
}