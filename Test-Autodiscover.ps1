function Test-Autodiscover {
    [CmdletBinding()]
    param(
      [Parameter(Position=1, Mandatory=$true)]
      [String]
      $EmailAddress,
      
      [ValidateSet("Internal", "External")]
      [Parameter(Position=2, Mandatory=$false)]
      [String]
      $Location = "External",      
      
      [Parameter(Position=3, Mandatory=$false)]
      [System.Management.Automation.PSCredential]
      $Credential,
      
      [Parameter(Position=4, Mandatory=$false)]
      [switch]
      $TraceEnabled,
      
      [Parameter(Position=5, Mandatory=$false)]
      [bool]
      $IgnoreSsl = $true,
      
      [Parameter(Position=6, Mandatory=$false)]
      [String]
      $Url
      )
      
      begin{
        Add-Type -Path 'C:\Program Files\Microsoft\Exchange\Web Services\1.1\Microsoft.Exchange.WebServices.dll'
      }
      
      process {
        $autod = New-Object Microsoft.Exchange.WebServices.Autodiscover.AutodiscoverService
        $autod.RedirectionUrlValidationCallback = {$true}
        $autod.TraceEnabled = $TraceEnabled
        
        if($IgnoreSsl) {
          [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}        
        }
        
        if($Credential){
          $autod.Credentials = New-Object Microsoft.Exchange.WebServices.Data.WebCredentials -ArgumentList $Credential.UserName, $Credential.GetNetworkCredential().Password
        }
        
        if($Url) {
          $autod.Url = $Url
        }
        
        switch($Location) {
          "Internal" {
            $autod.EnableScpLookup = $true
            $response = $autod.GetUserSettings(
              $EmailAddress,
              [Microsoft.Exchange.WebServices.Autodiscover.UserSettingName]::InternalRpcClientServer,
              [Microsoft.Exchange.WebServices.Autodiscover.UserSettingName]::InternalEcpUrl,
              [Microsoft.Exchange.WebServices.Autodiscover.UserSettingName]::InternalEwsUrl,
              [Microsoft.Exchange.WebServices.Autodiscover.UserSettingName]::InternalOABUrl,
              [Microsoft.Exchange.WebServices.Autodiscover.UserSettingName]::InternalUMUrl,
              [Microsoft.Exchange.WebServices.Autodiscover.UserSettingName]::InternalWebClientUrls
            )
            
            New-Object PSObject -Property @{
              RpcClientServer = $response.Settings[[Microsoft.Exchange.WebServices.Autodiscover.UserSettingName]::InternalRpcClientServer]
              InternalOwaUrl = $response.Settings[[Microsoft.Exchange.WebServices.Autodiscover.UserSettingName]::InternalWebClientUrls].urls[0].url
              InternalEcpUrl = $response.Settings[[Microsoft.Exchange.WebServices.Autodiscover.UserSettingName]::InternalEcpUrl]
              InternalEwsUrl = $response.Settings[[Microsoft.Exchange.WebServices.Autodiscover.UserSettingName]::InternalEwsUrl]
              InternalOABUrl = $response.Settings[[Microsoft.Exchange.WebServices.Autodiscover.UserSettingName]::InternalOABUrl]
              InternalUMUrl = $response.Settings[[Microsoft.Exchange.WebServices.Autodiscover.UserSettingName]::InternalUMUrl]
            }
          }
          "External" {
            $autod.EnableScpLookup = $false
            $response = $autod.GetUserSettings(
              $EmailAddress,
              [Microsoft.Exchange.WebServices.Autodiscover.UserSettingName]::ExternalMailboxServer,
              [Microsoft.Exchange.WebServices.Autodiscover.UserSettingName]::ExternalEcpUrl,
              [Microsoft.Exchange.WebServices.Autodiscover.UserSettingName]::ExternalEwsUrl,
              [Microsoft.Exchange.WebServices.Autodiscover.UserSettingName]::ExternalOABUrl,
              [Microsoft.Exchange.WebServices.Autodiscover.UserSettingName]::ExternalUMUrl,
              [Microsoft.Exchange.WebServices.Autodiscover.UserSettingName]::ExternalWebClientUrls
            )
            
            New-Object PSObject -Property @{
              HttpServer = $response.Settings[[Microsoft.Exchange.WebServices.Autodiscover.UserSettingName]::ExternalMailboxServer]
              ExternalOwaUrl = $response.Settings[[Microsoft.Exchange.WebServices.Autodiscover.UserSettingName]::ExternalWebClientUrls].urls[0].url
              ExternalEcpUrl = $response.Settings[[Microsoft.Exchange.WebServices.Autodiscover.UserSettingName]::ExternalEcpUrl]
              ExternalEwsUrl = $response.Settings[[Microsoft.Exchange.WebServices.Autodiscover.UserSettingName]::ExternalEwsUrl]
              ExternalOABUrl = $response.Settings[[Microsoft.Exchange.WebServices.Autodiscover.UserSettingName]::ExternalOABUrl]
              ExternalUMUrl = $response.Settings[[Microsoft.Exchange.WebServices.Autodiscover.UserSettingName]::ExternalUMUrl]
            }            
          }
        }                
      }
<#
    .SYNOPSIS
        This function uses the EWS Managed API to test the Exchange Autodiscover service.

    .DESCRIPTION
        This function will retreive the Client Access Server URLs for a specified email address
        by querying the autodiscover service of the Exchange server.

    .PARAMETER  EmailAddress
        Specifies the email address for the mailbox that should be tested.

    .PARAMETER  Location
        Set to External by default, but can also be set to Internal. This parameter controls whether
        the internal or external URLs are returned.
        
    .PARAMETER  Credential
        Specifies a user account that has permission to perform this action. Type a user name, such as 
        "User01" or "Domain01\User01", or enter a PSCredential object, such as one from the Get-Credential cmdlet.
        
    .PARAMETER  TraceEnabled
        Use this switch parameter to enable tracing. This is used for debugging the XML response from the server.    
        
    .PARAMETER  IgnoreSsl
        Set to $true by default. If you do not want to ignore SSL warnings or errors, set this parameter to $false.
        
    .PARAMETER  Url
        You can use this parameter to manually specifiy the autodiscover url.        

    .EXAMPLE
        PS C:\> Test-Autodiscover -EmailAddress administrator@uclabs.ms -Location internal
        
        This example shows how to retrieve the internal autodiscover settings for a user.

    .EXAMPLE
        PS C:\> Test-Autodiscover -EmailAddress administrator@uclabs.ms -Credential $cred
        
        This example shows how to retrieve the external autodiscover settings for a user. You can
        provide credentials if you do not want to use the Windows credentials of the user calling
        the function.

    .LINK
        http://msdn.microsoft.com/en-us/library/dd633699%28v=EXCHG.80%29.aspx

#>      
}
