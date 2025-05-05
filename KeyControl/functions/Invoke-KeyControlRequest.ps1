function Invoke-KeyControlRequest {
	[CmdletBinding()]
	param (
		[string]
		$Path,

		$Body = @()
	)
	begin {
		Assert-KeyControlConnection -Cmdlet $PSCmdlet

		if ($script:_KeyControlSession.Expires -lt (Get-Date).AddMinutes(2)) {
			Connect-KeyControl -ComputerName $script:_KeyControlSession.ComputerName -Credential $script:_KeyControlSession.Credential -Vault $script:_KeyControlSession.Vault
		}
	}
	process {
		$param = @{
			Method = 'POST'
			Uri = "$($script:_KeyControlSession.BasePath.Trim('/\'))/$($Path.TrimStart('/\'))"
			Headers = @{
				'content-type' = 'application/json'
				'x-vault-auth' = $script:_KeyControlSession.Token
			}
		}
		if ($Body) {
			$bodyJson = $Body
			if ($Body -isnot [string]) { $bodyJson = ConvertTo-Json -InputObject $Body }
			$param.Body = $bodyJson
		}

		Invoke-RestMethod @param
	}
}