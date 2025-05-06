function Get-KeyControlSecret {
	<#
	.SYNOPSIS
		Searches for secrets in a Key Control Vault's specified box.
		
	.DESCRIPTION
		Searches for secrets in a Key Control Vault's specified box.
		Secret Data is only included when asking for a specific secret by ID!
	
		Requires an already established connection via "Connect-KeyControl".
	
	.PARAMETER BoxID
		The ID of the box to search in.
	
	.PARAMETER SecretID
		The secret ID of the specific secret to retrieve.
	
	.PARAMETER Name
		The name to search by.
		Supports wildcards at the beginning or the end, but not in the middle of the name.
	
	.PARAMETER Tags
		Tags to search of (including their value).
	
	.PARAMETER Filter
		A custom filter condition to search by.
		For when the builtin parameters do not cover your need.
		Filter reference: https://docs.hytrust.com/DataControl/Online/Content/Books/Secrets-Vault-Programmers-Reference/API/API-Filters.html
	
	.PARAMETER Version
		The specific version of the secret to retrieve.
	
	.EXAMPLE
		PS C:\> Get-KeyControlSecret -BoxID $boxID
		
		Lists all secrets' info from within the specified box.

	.EXAMPLE
		PS C:\> Get-KeyControlSecret -BoxID $boxID SecretID $secret.secret_id

		Retrieve the specified secret, including both metadata and the actual secret data.
	#>
	[CmdletBinding(DefaultParameterSetName = 'ByCondition')]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$BoxID,

		[Parameter(Mandatory = $true, ParameterSetName = 'ByID')]
		[string]
		$SecretID,

		[Parameter(ParameterSetName = 'ByCondition')]
		[string]
		$Name,

		[Parameter(ParameterSetName = 'ByCondition')]
		[hashtable]
		$Tags,

		[Parameter(ParameterSetName = 'ByFilter')]
		[string]
		$Filter,

		[Parameter(ParameterSetName = 'ByID')]
		[string]
		$Version
	)
	process {
		if ($SecretID) {
			$body = @{
				box_id = $BoxID
				secret_id = $SecretID
			}
			if ($Version) {
				$body['version'] = $Version
			}

			Invoke-KeyControlRequest -Path 'GetSecret/' -Body $body | Add-Member -MemberType NoteProperty -Name BoxID -Value $BoxID -PassThru
			return
		}

		$body = @{
			box_id = $BoxID
			fields = @(
				'secret_id'
				'name'
				'desc'
				'revision'
				'created_at'
				'updated_at'
				'expires_at'
				'tags'
				'version_count'
				'current_version'
				'secret_type'
			)
		}
		$conditions = @()
		if ($Name) {
			if ($Name -notmatch '^\*|\*$') { $conditions += "/name eq '$Name'" }
			if ($Name -match '^\*') { $conditions += "endswith(/name, '$($Name.Trim('*'))')" }
			if ($Name -match '\*$') { $conditions += "startswith(/name, '$($Name.Trim('*'))')"}
		}
		if ($Tags) {
			foreach ($pair in $Tags.GetEnumerator()) {
				$conditions += "/tags/{0} eq '{1}'" -f $pair.Key, $pair.Value
			}
		}
		if ($Filter) { $conditions = @($Filter) }
		
		if ($conditions.Count -gt 0) {
			$body['filters'] = $conditions -join ' and '
		}

		$param = @{
			Path = 'ListSecrets/'
			Body = $body
		}

		(Invoke-KeyControlRequest @param).secrets | Add-Member -MemberType NoteProperty -Name BoxID -Value $BoxID -PassThru
	}
}