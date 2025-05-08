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

	.PARAMETER NameProperty
		The property on the info object to use for a credential name.
		If Specified, this command will return a PSCredential object, with the value of that property as Username and the secret as password.
	
	.EXAMPLE
		PS C:\> Get-KeyControlSecret -BoxID $boxID
		
		Lists all secrets' info from within the specified box.

	.EXAMPLE
		PS C:\> Get-KeyControlSecret -BoxID $boxID SecretID $secret.secret_id

		Retrieve the specified secret, including both metadata and the actual secret data.

	.EXAMPLE
		PS C:\> Get-KeyControlSecret -BoxID $boxID SecretID $secret.secret_id -NameProperty name

		Retrieve the specified secret, returning a PSCredential object with the secret name as username and secret as password.
	#>
	[CmdletBinding(DefaultParameterSetName = 'ByCondition')]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[string]
		$BoxID,

		[Parameter(ParameterSetName = 'ByID', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
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

		[Parameter(ParameterSetName = 'ByID', ValueFromPipelineByPropertyName = $true)]
		[Alias('CurrentVersion')]
		[string]
		$Version,

		[Parameter(ParameterSetName = 'ByID')]
		[string]
		$NameProperty
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

			$secretInfo = Invoke-KeyControlRequest -Path 'GetSecret/' -Body $body | ConvertFrom-Secret -BoxID $BoxID
			$secret = Invoke-KeyControlRequest -Path 'CheckoutSecret/' -Body $body | Add-Member -MemberType NoteProperty -Name BoxID -Value $BoxID -PassThru
			if ($secret.secret_data -is [string]) { $secretInfo.Secret = $secret.secret_data | ConvertTo-SecureString -AsPlainText -Force }
			else { $secretInfo.Secret = $secret.secret_data | ConvertTo-Json -Depth 99 | ConvertTo-SecureString -AsPlainText -Force }

			if (-not $NameProperty) { return $secretInfo }
			
			[PSCredential]::new($secret.$NameProperty, $secret.Secret)
			return
		}

		$body = @{
			box_id = $BoxID
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

		(Invoke-KeyControlRequest @param).secrets | ConvertFrom-Secret -BoxID $BoxID
	}
}