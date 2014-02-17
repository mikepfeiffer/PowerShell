param(
    $Id,
    $CIDRBlocks,
    $FromPort,
    $ToPort,
    $Protocol
)

$CIDR = @()
$CIDR += $CIDRBlocks

$ipPermissions = New-Object Amazon.EC2.Model.IpPermission -Property @{
    IpProtocol = $Protocol
    FromPort = $FromPort
    ToPort = $ToPort
    IPRanges = $CIDR
}

Grant-EC2SecurityGroupIngress -GroupId $Id -IpPermissions $ipPermissions