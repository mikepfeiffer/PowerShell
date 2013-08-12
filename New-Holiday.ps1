function New-Holiday {
    [CmdletBinding(DefaultParametersetName='Identity')]
    param(
        [Parameter(Position=0, ParameterSetName='Identity')]
        $Identity,

        [Parameter(Position=1, Mandatory=$true)]
        $Subject,

        [Parameter(Position=2, Mandatory=$true)]
        $Date,

        [Parameter(Position=3)]
        [Switch]$Impersonate,

        [Parameter(Position=4)]
        $ExchangeVersion = 'Exchange2010_SP2',

        [Parameter(Position=5, ParameterSetName='Pipeline', ValueFromPipelineByPropertyName=$true)]
        $PrimarySmtpAddress,

        [Parameter(Position=6)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter(Position=7)]
        $EWSUrl
    )

    begin {
        #Load the EWS Assembly
        Add-Type -Path "C:\Program Files\Microsoft\Exchange\Web Services\1.2\Microsoft.Exchange.WebServices.dll"
    }

    process {
        #Is the identity coming from the pipeline?
        if($PsCmdlet.ParameterSetName -eq 'Pipeline') {
            $Identity = $PrimarySmtpAddress.ToString()
        }

        #Create the ExchangeService object
        $service = New-Object Microsoft.Exchange.WebServices.Data.ExchangeService -ArgumentList ([Microsoft.Exchange.WebServices.Data.ExchangeVersion]::$ExchangeVersion)

        #If Credential parameter used, set the credentials on the $service object
        if($Credential) {
            $service.Credentials = New-Object Microsoft.Exchange.WebServices.Data.WebCredentials -ArgumentList $Credential.UserName, $Credential.GetNetworkCredential().Password
        }

        #If EWSUrl parameter not used, locate the end-point using autoD
        if(!$EWSUrl) {
            $service.AutodiscoverUrl($Identity, {$true})
        }
        else {
            $service.Url = New-Object System.Uri -ArgumentList $EWSUrl
        }        

        #If Impersonation parameter used, impersonate the user
        if($Impersonate) {
            $ImpersonatedUserId = New-Object Microsoft.Exchange.WebServices.Data.ImpersonatedUserId -ArgumentList ([Microsoft.Exchange.WebServices.Data.ConnectingIdType]::SmtpAddress),$Identity
            $service.ImpersonatedUserId = $ImpersonatedUserId
        }

        #Configure the start and end time for this all day event
        $start = (get-date $date)
        $end = $start.addhours(24)

        #Create and save the appointment
        $appointment = New-Object Microsoft.Exchange.WebServices.Data.Appointment -ArgumentList $service
        $appointment.Subject = $Subject
        $appointment.Start = $Start
        $appointment.End = $End
        $appointment.IsAllDayEvent = $true
        $appointment.IsReminderSet = $false
        $appointment.Categories.Add('Holiday')
        $appointment.Location = 'United States'
        $appointment.LegacyFreeBusyStatus = [Microsoft.Exchange.WebServices.Data.LegacyFreeBusyStatus]::Free
        $appointment.Save([Microsoft.Exchange.WebServices.Data.SendInvitationsMode]::SendToNone)
    }
}