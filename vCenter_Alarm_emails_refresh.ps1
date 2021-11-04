##  ----------------------------------------------------------------------------
##  vCenter_Email_alerts_refresh.ps1
##  ----------------------------------------------------------------------------
Write-Host ------------------------------------------------------------

$credUsername = ''
$credPassword = ''

$emailToAddress = ''

#$viServers = @('vcenter01', 'vcenter02', 'vcenter03')
$viServers = @('vcenter01')

$alarmsForEmailAlert = @('Host error', 'Snapshot Size', 'Datastore usage on disk')

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
    Write-Host Checking current email alarms for $vSphereHost ... 
    Get-AlarmDefinition | Get-AlarmAction -ActionType SendEmail | Select-Object AlarmDefinition,AlarmVersion,Cc,To,Subject,Body | Format-Table -AutoSize
    
    Write-Host ------------------------------
    Write-Host Clearing all email alarms  for $vSphereHost ... 
    Get-AlarmDefinition | Get-AlarmAction -ActionType SendEmail | Remove-AlarmAction -Confirm:$false

    Write-Host ------------------------------
    Write-Host Setting required email actions for $vSphereHost ... 
    foreach ($alarmName in $alarmsForEmailAlert)
    {
        $emailSubject = '[' + $($vSphereHost) + '] Alarm : ' + $alarmName

        ##  Since the vSphere web client does not allow us to view/edit it, 
        ##    let's leave out, the email body. 
        ##    This results in default content that is very useful anyway. 
        Get-AlarmDefinition -Name $alarmName | New-AlarmAction -Email -To $emailToAddress -Subject $emailSubject -Confirm:$false | Out-Null
    }

    Write-Host ------------------------------
    Write-Host Confirming new email alarms for $vSphereHost ... 
    Get-AlarmDefinition | Get-AlarmAction -ActionType SendEmail | Select-Object AlarmDefinition,AlarmVersion,Cc,To,Subject,Body | Format-Table -AutoSize

    Write-Host ------------------------------------------------------------
    Disconnect-VIServer $vSphereHost -Confirm:$false
}

Write-Host Done. 
Write-Host ------------------------------------------------------------

##  ============================================================================