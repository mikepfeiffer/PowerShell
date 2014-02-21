<#

.Example

PS C:\> Get-CFNStackRuntimeStats -StackName adtest5353345 -Region sa-east-1


StackId      : 0001
StackStatus  : CREATE_COMPLETE
StartTime    : 2/19/2014 5:38:04 PM
EndTime      : 2/19/2014 6:37:58 PM
TotalRuntime : Days: 0, Hours: 0, Minutes: 59

#>

function Get-CFNStackRuntimeStats {
    param(
        $StackName,
        $Region
    )

    $stack = Get-CFNStack -StackName $StackName -Region $Region
    $endTime = (Get-CFNStackEvent -StackName $StackName -Region $Region | ?{$_.LogicalResourceId -eq $StackName})[0].TimeStamp

    $runTimeSpan = $endTime - $stack.CreationTime

    $runTime = "Days: {0}, Hours: {1}, Minutes: {2}" -f $runTimeSpan.days, $runTimeSpan.hours, $runTimeSpan.minutes

    $null = (Get-CFNStack -StackName $StackName -Region $Region).Description -match '\d\d\d\d'

    $stackId = $matches[0]

    $props = [ordered]@{
        StackId = $stackId
        StackStatus = $stack.StackStatus.Value
        StartTime = $stack.CreationTime.ToString()
        EndTime = $endTime
        TotalRuntime = $runTime
    }

    $result = New-Object psobject -Property $props
    Write-Output $result
}