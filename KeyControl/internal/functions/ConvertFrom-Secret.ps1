function ConvertFrom-Secret {
	<#
	.SYNOPSIS
		Converts Secret API response objects into presentable data.
	
	.DESCRIPTION
		Converts Secret API response objects into presentable data.
	
	.PARAMETER InputObject
		The data to make pretty.
	
	.PARAMETER BoxID
		The ID of the box the secret is from.
		Added as data to the processed API response.
	
	.EXAMPLE
		PS C:\> (Invoke-KeyControlRequest @param).secrets | ConvertFrom-Secret -BoxID $BoxID

		Search for secrets abd make them pretty.
	#>
	[CmdletBinding()]
	param (
		[Parameter(ValueFromPipeline = $true)]
		$InputObject,

		[string]
		$BoxID
	)
	process {
		if (-not $InputObject) { return }

		[PSCustomObject]@{
			PSTypeName     = 'KeyControl.Secret'
			BoxID          = $BoxID
			SecretID       = $InputObject.secret_id
			Revision       = $InputObject.revision
			Name           = $InputObject.name
			Description    = $InputObject.desc
			BoxName        = $InputObject.box_name
			Tags           = $InputObject.tags
			Expired        = $InputObject.expired
			CanAccess      = $InputObject.checkout_allowed

			CurrentVersion = $InputObject.current_version
			VersionCount   = $InputObject.version_count

			VersionCreated = $InputObject.current_version_creation_time -as [datetime]
			FirstCreated   = $InputObject.created_at -as [datetime]
			Updated        = $InputObject.updated_at -as [datetime]
			Accessed       = $InputObject.last_accessed -as [datetime]

			Owner          = $InputObject.owner_name
			OwnerMail      = $InputObject.owner_email

			Type           = $InputObject.secret_type.type
			SubType        = $InputObject.secret_subtype_info
			Info           = $InputObject.secret_info

			Secret         = $null

			Object         = $InputObject
		}
	}
}