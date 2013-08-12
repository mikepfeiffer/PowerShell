function Submit-PickupMessage {
	Param($To, $From, $Subject, $Message, $Bcc, $TransportServer)

	$string = New-Object System.Text.StringBuilder
	$string.AppendLine("To:$($To -join ';')") | Out-Null
	if($Bcc) {$string.AppendLine("Bcc:$($Bcc -join ';')") | Out-Null}
	$string.AppendLine("From:$From") | Out-Null
	$string.AppendLine("Subject:$Subject") | Out-Null
	$string.AppendLine() | Out-Null
	$string.AppendLine($Message) | Out-Null
	
	$path = (Get-TransportServer -identity $TransportServer).PickupDirectoryPath
	$path = "\\$TransportServer\$($path.ToString().replace(':','$'))"
	$temp = [guid]::NewGuid().guid
	New-Item -ItemType File -Value $string.ToString() -Path $path -Name "$temp.eml" | Out-Null
}