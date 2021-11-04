##  ----------------------------------------------------------------------------
##  vCenter_Alarm_emails_audit.ps1
##  ----------------------------------------------------------------------------
Write-Host ------------------------------------------------------------

$credUsername = ''
$credPassword = ''

#$viServers = @('vcenter01', 'vcenter02', 'vcenter03')
$viServers = @('vcenter01')

##  ----------------------------------------------------------------------------
##  Set-PowerCLIConfiguration

##  Prevent prompt to update PowerCLI configuration, and ignore invalid cert. 
Set-PowerCLIConfiguration -ParticipateInCEIP $false -DisplayDeprecationWarnings $false -Scope User -Confirm:$false | Out-Null

##  Prevent prompt to update PowerCLI configuration, and ignore invalid cert. 
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -DisplayDeprecationWarnings $false -Scope Session -Confirm:$false | Out-Null

##  ----------------------------------------------------------------------------

foreach ($vSphereHost in $viServers)
{
    Write-Host Connecting to $vSphereHost ... 
    Connect-VIServer -Server $vSphereHost -User $credUsername -Password $credPassword | Select-Object Name,Port,User | Write-Host
    Write-Host ------------------------------------------------------------
    Write-Host Getting alarms that send email for $vSphereHost ... 
    Get-AlarmDefinition | Get-AlarmAction -ActionType SendEmail | Select-Object AlarmDefinition,AlarmVersion,Cc,To,Subject,Body | Format-Table -AutoSize
    #Write-Host ------------------------------
    #Write-Host Getting all alarms for $vSphereHost ... 
    #Get-AlarmDefinition | Get-AlarmAction -Server $vSphereHost | Select-Object AlarmDefinition,AlarmVersion,Cc,To | Format-Table -AutoSize
    #Write-Host Disconnecting from $vSphereHost ... 
    Write-Host ------------------------------------------------------------
    Disconnect-VIServer $vSphereHost -Confirm:$false
}

Write-Host Done. 
Write-Host ------------------------------------------------------------

##  ============================================================================