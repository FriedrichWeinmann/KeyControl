function Disconnect-KeyControl {
	<#
	.SYNOPSIS
		Disconnects from the previously connected entrust Key Control secrets Vault.
	
	.DESCRIPTION
		Disconnects from the previously connected entrust Key Control secrets Vault.
		Use "Connect-KeyControl" to first establish a connection.

		Does not act at all, when not already connected.
	
	.EXAMPLE
		PS C:\> Disconnect-KeyControl

		Disconnects from the previously connected entrust Key Control secrets Vault.
	#>
	[CmdletBinding()]
	param ()
	process {
		if (-not $script:_KeyControlSession) { return }
		
		Invoke-KeyControlRequest -Path 'logout/'
		$script:_KeyControlSession = $null
	}
}