<#
.Synopsis
   Creates a new DHCP Option Set and attaches to VPC.
   Deletes the previous DHCP Option Set attached to the VPC
.EXAMPLE
    .\New-DHCPOptionSet.ps1 -CIDR '10.0.0.0/16' `
    -DomainName contoso.com `
    -DomainNameServers '10.0.2.10','10.0.3.10' `
    -NtpServers '10.0.2.10','10.0.3.10' `
    -NetbiosNameServers '10.0.2.10','10.0.3.10' `
    -AccessKey YOURACCESSKEY `
    -SecretKey 'YOURSECRETKEY' `
    -Region us-east-1
#>

param(
    [Parameter(Mandatory=$true)]
    $CIDR,

    [Parameter(Mandatory=$true)]
    $DomainName,

    [Parameter(Mandatory=$true)]
    $DomainNameServers,

    [Parameter(Mandatory=$true)]
    $NtpServers,

    [Parameter(Mandatory=$true)]
    $NetbiosNameServers,

    [Parameter(Mandatory=$false)]
    $NetbiosNodeType = 2,

    [Parameter(Mandatory=$true)]
    $AccessKey,

    [Parameter(Mandatory=$true)]
    $SecretKey,

    [Parameter(Mandatory=$true)]
    $Region
)

Initialize-AWSDefaults -AccessKey $AccessKey -SecretKey $SecretKey -Region $Region


$option1 = New-Object -TypeName Amazon.EC2.Model.DhcpConfiguration
$option1.Key = "domain-name"
$option1.Values = $DomainName

$option2 = New-Object -TypeName Amazon.EC2.Model.DhcpConfiguration
$option2.Key = "domain-name-servers"
$option2.Values = $DomainNameServers

$option3 = New-Object -TypeName Amazon.EC2.Model.DhcpConfiguration
$option3.Key = "ntp-servers"
$option3.Values = $NtpServers

$option4 = New-Object -TypeName Amazon.EC2.Model.DhcpConfiguration
$option4.Key = "netbios-name-servers"
$option4.Values = $NetbiosNameServers

$option5 = New-Object -TypeName Amazon.EC2.Model.DhcpConfiguration
$option5.Key = "netbios-node-type"
$option5.Values = $NetbiosNodeType

$options = @($option1, $option2, $option3, $option4, $option5)


$vpc = Get-EC2Vpc | ?{$_.CidrBlock -eq $CIDR}

if($vpc) {
    $DHCPOptions = New-EC2DhcpOption -DhcpConfiguration $options
    Register-EC2DhcpOption -DhcpOptionsID $DHCPOptions.DhcpOptionsId -VpcId $VPC.VpcId    
    
    if(!$vpc.IsDefault){
        Remove-EC2DhcpOption -DhcpOptionsId $vpc.DhcpOptionsId -Force -Confirm:$false
    }
}
