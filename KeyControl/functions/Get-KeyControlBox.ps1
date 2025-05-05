function Get-KeyControlBox {
	[CmdletBinding()]
	param ()
	begin {
		Assert-KeyControlConnection -Cmdlet $PSCmdlet
	}
	process {
		Invoke-KeyControlRequest -Path ListBoxes
	}
}