function ConvertFrom-Box {
	<#
	.SYNOPSIS
		Converts Box API responses into something presentable.
	
	.DESCRIPTION
		Converts Box API responses into something presentable.
	
	.PARAMETER InputObject
		The Box API response object to make pretty.
	
	.EXAMPLE
		PS C:\> (Invoke-KeyControlRequest @param).boxes | ConvertFrom-Box

		Searches for Boxes and makes them presentable.
	#>
	[CmdletBinding()]
	param (
		[Parameter(ValueFromPipeline = $true)]
		$InputObject
	)
	process {
		if (-not $InputObject) { return }

		[PSCustomObject]@{
			PSTypeName        = 'KeyControl.Box'
			BoxID             = $InputObject.box_id
			Name              = $InputObject.name
			Description       = $InputObject.Description
			Created           = $InputObject.created_at -as [datetime]
			Updated           = $InputObject.updated_at -as [datetime]
			Tags              = $InputObject.tags
			Revision          = $InputObject.revision
			MaxSecretVersions = $InputObject.max_secret_versions
			Rotation          = $InputObject.rotation
			ExclusiveCheckout = $InputObject.exclusive_checkout

			Object            = $InputObject
		}
	}
}