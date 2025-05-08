function Invoke-KeyControlRequest {
	<#
	.SYNOPSIS
		Executes an API request against the entrust Key Control secrets Vault API.
	
	.DESCRIPTION
		Executes an API request against the entrust Key Control secrets Vault API.
		This tool is optimized to make request execution simple, handling authentication, headers & body formatting, while making path selection easy.
		Rather than specifying the full URL, with this helper you can provide simply the final endpoint you are executing against - e.g. "ListBoxes/".
				
		Will automatically refresh the session if it is about to expire (or already has expired).

		Requires an already established connection via "Connect-KeyControl".

		This command is mostly intended for internal use, but exposed for custom scenarios or non-implemented endpoints.

		Documentation:
		- KeyControl API Reference: https://docs.hytrust.com/DataControl/Online/Content/Books/Secrets-Vault-Programmers-Reference/API/Accessing-the-SV-API.html
		- Examples (in GO) for endpoints: https://github.com/EntrustCorporation/pasmcli/tree/master/pasmcli/cmd
	
	.PARAMETER Path
		Relative path to the base URI of the service.
		Usually expects something like "ListBoxes/" or "GetSecret/".
		Most paths expect a trailing "/"
	
	.PARAMETER Body
		The json payload to send.
		Will convert to json if not already a string.
	
	.EXAMPLE
		PS C:\> Invoke-KeyControlRequest -Path 'GetBox/' -Body @{ box_id = $id }

		Retrieves the specified box from the connected vault.
	#>
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

		Invoke-RestMethod @param -ErrorAction Stop
	}
}