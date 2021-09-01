##  ----------------------------------------------------------------------------
##  vCenter_email_address_checks.ps1
##  ----------------------------------------------------------------------------
Write-Host ------------------------------------------------------------

$credUsername = 'vAdmin'
$credPassword = 'vPassword'

$viServers = @('vcenter01', 'vcenter02', 'vcenter03')

##  ----------------------------------------------------------------------------
##  Set-PowerCLIConfiguration

##  Prevent prompt for the VMware Customer Experience Improvement Program. 
Set-PowerCLIConfiguration -ParticipateInCEIP $false -DisplayDeprecationWarnings $false -Scope User -Confirm:$false | Out-Null

##  Set to ignore invalid cert. 

##  Prevent prompt to Update PowerCLI configuration. 
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -DisplayDeprecationWarnings $false -Scope Session -Confirm:$false | Out-Null

foreach ($vSphereHost in $viServers)
{
    Write-Host Connecting to $vSphereHost ... 
    Connect-VIServer -Server $vSphereHost -User $credUsername -Password $credPassword | Select-Object Name,Port,User | Write-Host
    Write-Host ------------------------------------------------------------
    Write-Host Getting alarms that send email for $vSphereHost ... 
    Get-AlarmDefinition | Get-AlarmAction -ActionType SendEmail | Select-Object AlarmDefinition,AlarmVersion,Cc,To,Subject,Body | Format-Table -AutoSize
    Write-Host ------------------------------
    Write-Host Getting all alarms for $vSphereHost ... 
    Get-AlarmDefinition | Get-AlarmAction -Server $vSphereHost | Select-Object AlarmDefinition,AlarmVersion,Cc,To | Format-Table -AutoSize
    Write-Host Disconnecting from $vSphereHost ... 
    Write-Host ------------------------------------------------------------
    Disconnect-VIServer $vSphereHost -Confirm:$false
}

Write-Host Done. 

##  ============================================================================
