function Disconnect-KeyControl {
	[CmdletBinding()]
	param ()
	process {
		if (-not $script:_KeyControlSession) { return }
		
		Invoke-KeyControlRequest -Path 'logout/'
		$script:_KeyControlSession = $null
	}
}