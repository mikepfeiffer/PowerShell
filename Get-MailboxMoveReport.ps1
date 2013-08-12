function Get-MailboxMoveReport {
    [CmdletBinding()]
    param(
        [Parameter(Position=0, Mandatory=$false)]
        [String]
        $Mailbox,
        [Parameter(Position=1, Mandatory=$false)]
        [String]
        $Server = $env:COMPUTERNAME,
        [Parameter(Position=2, Mandatory=$false)]
        [String]
        $Path = (Join-Path -Path $exinstall -ChildPath "Logging\MigrationLogs")
        )

    process {
        $report = @()
        $path = Join-Path "\\$server" $path.replace(":","$")
        foreach ($item in gci $path *.xml) {
            $report += [xml](Get-Content $item.fullname)
        }        
        
        $report | %{  
            $MovedBy = $_."move-Mailbox".TaskHeader.RunningAs
            $StartTime = $_."move-Mailbox".TaskHeader.StartTime
            $EndTime = $_."move-Mailbox".TaskFooter.EndTime
            
            $result = $_."move-mailbox".taskdetails.item | %{
                New-Object PSObject -Property @{
                    Mailbox = $_.MailboxName
                    MovedBy = $MovedBy
                    MailboxSize = $_.MailboxSize
                    StartTime = $StartTime
                    EndTime = $EndTime
                    IsWarning = $_.result.IsWarning
                    ErrorCode = $_.result.ErrorCode
                }                
            }
        }
        
        if($Mailbox) {
            $result | ?{$_.Mailbox -eq (Get-Mailbox $Mailbox).DisplayName}
        }
        else {
            $result
        }        
    }
}