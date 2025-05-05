function Assert-KeyControlConnection {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		$Cmdlet
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