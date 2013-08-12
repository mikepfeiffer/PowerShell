function Get-CASActiveUsers {
  [CmdletBinding()]
    param(
    [Parameter(Position=0, ParameterSetName="Value", Mandatory=$true)]
    [String[]]$ComputerName,
    [Parameter(Position=0, ParameterSetName="Pipeline", ValueFromPipelineByPropertyName=$true, Mandatory=$true)]
    [String]$Name
  )

  process {
    switch($PsCmdlet.ParameterSetName) {
      "Value" {$servers = $ComputerName}
      "Pipeline" {$servers = $Name}
    }
    $servers | %{
      $RPC = Get-Counter "\MSExchange RpcClientAccess\User Count" -ComputerName $_
      $OWA = Get-Counter "\MSExchange OWA\Current Unique Users" -ComputerName $_
      New-Object PSObject -Property @{
        Server = $_
        "RPC Client Access" = $RPC.CounterSamples[0].CookedValue
        "Outlook Web App" = $OWA.CounterSamples[0].CookedValue
      }
    }
  }
}