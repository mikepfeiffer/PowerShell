function Test-ExchangeCertificate {
    [CmdletBinding()]
    param(
        [Parameter(Position=0, Mandatory=$false)]
        [System.String]
        $identity
    )
	
	begin {
		if(!$identity) { $servers = Get-ExchangeServer }
		else { $servers = Get-ExchangeServer @PSBoundParameters }
		
		$certificates = $servers | %{
			$servername = $_.name
			Get-ExchangeCertificate -Server $servername | select @{n="Name";e={$servername}},
				Status,
				Services,
				CertificateDomains,
				NotAfter
		}
	}
	
	process {
		$certificates | %{
			New-Object PSObject -Property @{
				ServerName = $_.Name
				Status = $_.Status
				Services = $_.Services
				Domains = $_.CertificateDomains -Join ","
				ExpirationDate = $_.NotAfter
				DaysUntilExpire = ($_.NotAfter - (Get-Date)).Days
			}
		}
	}
}