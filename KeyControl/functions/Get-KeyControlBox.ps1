function Get-KeyControlBox {
	[CmdletBinding()]
	param (
		[string]
		$Name = '*',

		[string]
		$ID
	)
	begin {
		Assert-KeyControlConnection -Cmdlet $PSCmdlet
	}
	process {
		(Invoke-KeyControlRequest -Path 'ListBoxes/').boxes | Where-Object {
			$_.Name -like $Name -and
			$_.box_id -like $ID
		}
	}
}