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
			Connect-KeyControl -ComputerName $script:_KeyControlSession.ComputerName -Credential $script:_KeyControlSession.Credential
		}
	}
	process {
		$bodyJson = $Body
		if ($Body -isnot [string]) { $bodyJson = ConvertTo-Json -InputObject $Body }

		Invoke-RestMethod -Method POST -Uri "$($script:_KeyControlSession.BasePath.Trim('/\'))/$($Path.TrimStart('/\'))" -Body $bodyJson -Headers @{
			'content-type' = 'application/json'
			'x-vault-auth' = $script:_KeyControlSession.Token
		}
	}
}