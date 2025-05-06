function Get-KeyControlBox {
	<#
	.SYNOPSIS
		Searches for boxes in the connected Key Control Vault.
	
	.DESCRIPTION
		Searches for boxes in the connected Key Control Vault.

		Requires an already established connection via "Connect-KeyControl".
	
	.PARAMETER Name
		The name to search by.
	
	.PARAMETER ID
		The specific ID of the box to retrieve.
	
	.PARAMETER Filter
		A custom filter condition to search by.
		For when the builtin parameters do not cover your need.
		Filter reference: https://docs.hytrust.com/DataControl/Online/Content/Books/Secrets-Vault-Programmers-Reference/API/API-Filters.html
	
	.EXAMPLE
		PS C:\> Get-KeyControlBox
		
		Lists all boxes in the connected vault.

	.EXAMPLE
		PS C:\> Get-KeyControlBox -Name d12*

		Lists all boxes in the connected vault whose name starts with "d12"

	.EXAMPLE
		PS C:\> Get-KeyControlBox -ID $boxID

		Retrieves the specifically requested box.
	#>
	[CmdletBinding()]
	param (
		[Parameter(ParameterSetName = 'ByName')]
		[string]
		$Name = '*',

		[Parameter(Mandatory = $true, ParameterSetName = 'ByID')]
		[string]
		$ID,

		[Parameter(Mandatory = $true, ParameterSetName = 'ByFilter')]
		[string]
		$Filter
	)
	begin {
		Assert-KeyControlConnection -Cmdlet $PSCmdlet
	}
	process {
		if ($ID) {
			$body = @{
				'box_id' = $ID
			}
			Invoke-KeyControlRequest -Path 'GetBox/' -Body $body
			return
		}

		$param = @{
			Path = 'ListBoxes/'
		}

		if ($Name) {
			$filterString = "/name eq '$Name'"
			if ($Name -match '^\*') { $filterString = "endswith(/name, '$($Name.Trim('*'))')" }
			if ($Name -match '\*$') { $filterString = "startswith(/name, '$($Name.Trim('*'))')"}
	
			$body = @{
				filters = $filterString
			}
			$param.Body = $body
		}
		if ($Filter) {
			$body = @{
				$filters = $Filter
			}
			$param.Body = $body
		}
		(Invoke-KeyControlRequest @param).boxes
	}
}