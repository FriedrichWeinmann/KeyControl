function Assert-KeyControlConnection {
	<#
	.SYNOPSIS
		Ensure there exists a working connection the an entrust Key Control secrets Vault.
	
	.DESCRIPTION
		Ensure there exists a working connection the an entrust Key Control secrets Vault.
		This function is mostly used internally to ensure commands fail early when not connected.

		Use the "Connect-KeyControl" command to establish a connection.
	
	.PARAMETER Cmdlet
		The $PSCmdlet variable of the command calling this command.
		By providing this parameter, the error thrown in case of a missing connection happens within the context of the calling command.
		In essence, this hides this function - Assert-KeyControlConnection - from the user and instead only shows the calling command.
	
	.EXAMPLE
		PS C:\> Assert-KeyControlConnection -Cmdlet $PSCmdlet
		
		Will do nothing if already connected or throw a terminating exception in the context of the calling command if not so.
		This function will be fully invisible to the end user.
	#>
	[CmdletBinding()]
	param (
		$Cmdlet = $PSCmdlet
	)
	process {
		if ($script:_KeyControlSession) { return }

		$Cmdlet.ThrowTerminatingError(
			[System.Management.Automation.ErrorRecord]::new(
				[System.Exception]::new("Not connected yet! Use Connect-KeyControl to connect to a KeyControl server first."),
				"NotAuthenticated",
				[System.Management.Automation.ErrorCategory]::AuthenticationError,
				$null
			)
		)
	}
}