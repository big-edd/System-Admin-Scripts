##  ----------------------------------------------------------------------------
##  vCenter_Alarm_history.ps1
##  ----------------------------------------------------------------------------
Write-Host ------------------------------------------------------------

$credUsername = ''
$credPassword = ''

$daysOfHistory = 30

#$viServers = @('vcenter01', 'vcenter02', 'vcenter03')
$viServers = @('vcenter01')

##  ----------------------------------------------------------------------------
##  Set-PowerCLIConfiguration

##  Prevent prompt for the VMware Customer Experience Improvement Program. 
Set-PowerCLIConfiguration -ParticipateInCEIP $false -DisplayDeprecationWarnings $false -Scope User -Confirm:$false | Out-Null

##  Prevent prompt to update PowerCLI configuration, and ignore invalid cert. 
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -DisplayDeprecationWarnings $false -Scope Session -Confirm:$false | Out-Null

##  ----------------------------------------------------------------------------

foreach ($vSphereHost in $viServers)
{
    Write-Host Connecting to $vSphereHost ... 
    Connect-VIServer -Server $vSphereHost -User $credUsername -Password $credPassword | Select-Object Name,Port,User | Write-Host

    Write-Host ------------------------------------------------------------
    Write-Host Get all events from the past $daysOfHistory days. 
    $events = Get-VIEvent -Start (Get-Date).AddDays(-$($daysOfHistory));
    $events | where {$_ -is [VMware.Vim.AlarmStatusChangedEvent] -and ($_.to -eq "yellow" -or $_.to -eq "red") -and $_.to -ne "gray"} | Format-List From,To,CreatedTime,FullFormattedMessage
    Write-Host ------------------------------------------------------------
    Write-Host Disconnecting from $vSphereHost ... 
    Write-Host ------------------------------------------------------------
    Disconnect-VIServer $vSphereHost -Confirm:$false
}

Write-Host Done. 
Write-Host ------------------------------------------------------------

##  ============================================================================