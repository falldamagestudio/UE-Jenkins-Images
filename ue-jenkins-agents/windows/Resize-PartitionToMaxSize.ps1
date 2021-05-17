function Resize-PartitionToMaxSize {

	<#
		.SYNOPSIS
		Expands the specified partition to use any unallocated disk space.
		This is useful for growing a small boot image to use all space available on the drive it has been installed onto.
	#>

	param (
		[Parameter(Mandatory=$true)][string]$DriveLetter
	)

	$CurrentPartitionSize = (Get-Partition -DriveLetter $DriveLetter).Size
	$MaxPartitionSupportedSize = (Get-PartitionSupportedSize -DriveLetter $DriveLetter).SizeMax

	if ($CurrentPartitionSize -lt $MaxPartitionSupportedSize) {
		Resize-Partition -DriveLetter $DriveLetter -Size $MaxPartitionSupportedSize
	}
}
