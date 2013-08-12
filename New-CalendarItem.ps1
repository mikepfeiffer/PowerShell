function New-CalendarItem {
    [CmdletBinding()]
    param(
        [Parameter(Position=1, Mandatory=$true)]
        $Subject,
        [Parameter(Position=2, Mandatory=$true)]
        $Body, 
        [Parameter(Position=3, Mandatory=$true)]
        $Start, 
        [Parameter(Position=4, Mandatory=$true)]
        $End, 
        [Parameter(Position=5, Mandatory=$false)]
        $RequiredAttendees, 
        [Parameter(Position=6, Mandatory=$false)]
        $OptionalAttendees, 
        [Parameter(Position=7, Mandatory=$false)]
        $Location,
        [Parameter(Position=8, Mandatory=$false)]
        $Impersonate
        )

    Add-Type -Path "C:\Program Files\Microsoft\Exchange\Web Services\1.1\Microsoft.Exchange.WebServices.dll"
    $sid = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
    $user = [ADSI]"LDAP://<SID=$sid>"        
    $service = New-Object Microsoft.Exchange.WebServices.Data.ExchangeService -ArgumentList ([Microsoft.Exchange.WebServices.Data.ExchangeVersion]::Exchange2010_SP1)
    $service.AutodiscoverUrl($user.Properties.mail)

    if($Impersonate) {
        $ImpersonatedUserId = New-Object Microsoft.Exchange.WebServices.Data.ImpersonatedUserId -ArgumentList ([Microsoft.Exchange.WebServices.Data.ConnectingIdType]::SmtpAddress),$Impersonate 
        $service.ImpersonatedUserId = $ImpersonatedUserId   
    }

    $appointment = New-Object Microsoft.Exchange.WebServices.Data.Appointment -ArgumentList $service
    $appointment.Subject = $Subject
    $appointment.Body = $Body
    $appointment.Start = $Start
    $appointment.End = $End 
    
    if($RequiredAttendees) {$RequiredAttendees | %{[void]$appointment.RequiredAttendees.Add($_)}}
    if($OptionalAttendees) {$OptionalAttendees | %{[void]$appointment.RequiredAttendees.Add($_)}}
    if($Location) {$appointment.Location = $Location}
    
    $appointment.Save([Microsoft.Exchange.WebServices.Data.SendInvitationsMode]::SendToAllAndSaveCopy)
}