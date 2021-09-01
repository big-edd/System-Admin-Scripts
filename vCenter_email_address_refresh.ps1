##  ----------------------------------------------------------------------------
##  vCenter_email_address_refresh.ps1
##  ----------------------------------------------------------------------------
Write-Host ------------------------------------------------------------

$credUsername = 'vAdmin'
$credPassword = 'vPassword'

$viServers = @('vcenter01', 'vcenter02', 'vcenter03')

$emailToAddress = 'alerts@corp'

$alarmsForEmailAlert = @('Host error', 'Snapshot Size', 'Datastore usage on disk')

##  ----------------------------------------------------------------------------
##  Set-PowerCLIConfiguration

##  Prevent prompt for the VMware Customer Experience Improvement Program. 
Set-PowerCLIConfiguration -ParticipateInCEIP $false -DisplayDeprecationWarnings $false -Scope User -Confirm:$false | Out-Null

##  Set to ignore invalid cert. 

##  Prevent prompt to Update PowerCLI configuration. 
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -DisplayDeprecationWarnings $false -Scope Session -Confirm:$false | Out-Null

##  ----------------------------------------------------------------------------

foreach ($vSphereHost in $viServers)
{
    Write-Host Connecting to $vSphereHost ... 
    Connect-VIServer -Server $vSphereHost -User $credUsername -Password $credPassword | Select-Object Name,Port,User | Write-Host

    Write-Host ------------------------------------------------------------
    Write-Host Checking current email alarms for $vSphereHost ... 
    Get-AlarmDefinition | Get-AlarmAction -ActionType SendEmail | Select-Object AlarmDefinition,AlarmVersion,Cc,To,Subject,Body | Format-Table -AutoSize
    
    Write-Host ------------------------------
    Write-Host Clearing all email alarms  for $vSphereHost ... 
    Get-AlarmDefinition | Get-AlarmAction -ActionType SendEmail | Remove-AlarmAction -Confirm:$false

    Write-Host ------------------------------
    Write-Host Setting required email actions for $vSphereHost ... 
    foreach ($alarmName in $alarmsForEmailAlert)
    {
        $emailSubject = $($vSphereHost) + ' - ' + $($alarmName) + '.'
        $emailBody = 'Alarm for ' + $($vSphereHost) + ' regarding ' + $($alarmName) + '.'
        Get-AlarmDefinition -Name $alarmName | New-AlarmAction -Email -To $emailToAddress -Subject $emailSubject -Body $emailBody -Confirm:$false | Out-Null
    }

    Write-Host ------------------------------
    Write-Host Confirming new email alarms for $vSphereHost ... 
    Get-AlarmDefinition | Get-AlarmAction -ActionType SendEmail | Select-Object AlarmDefinition,AlarmVersion,Cc,To,Subject,Body | Format-Table -AutoSize

    Write-Host ------------------------------------------------------------
    Disconnect-VIServer $vSphereHost -Confirm:$false
}

Write-Host Done. 

##  ============================================================================
