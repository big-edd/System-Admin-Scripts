##  ----------------------------------------------------------------------------
##  check_app_disconnect.ps1
##  ----------------------------------------------------------------------------

$procHost = "hostname"

$gracePeriod = 15

##  Seconds per min is adjustable for testing, 
##      as strange as that may sound.  
##  ---------------------------------------------
#$secondsPerMin = 60
$secondsPerMin = 1

#$removeFiles = "\\hostname\d$\MYOB\*.flk"
$removeFiles = "\\hostname\d$\Temp\test.txt"

#$appName = "MYOB"
$appName = "CMD"

#$procName = "myobp.exe"
$procName = "cmd.exe"

$adminTo = "admin.group@*.com"
$adminFrom = "disconnect.alert@*.com"

$usersTo = "user.group@*.com"
$usersFrom = "disconnected.notification@*.com"

$smtpServer = "smtp.*.local"

##  ----------------------------------------------------------------------------

$adminWarningSubject = "Diconnected session on $procHost for $appName"

$adminWarningBody = ""
$adminWarningBody += "Found $procName on $procHost with disconnected session." + "`r`n"

$usersWarningSubject = "Diconnected session for $appName"

$usersWarningBody = ""
$usersWarningBody += "Hello $appName users," + "`r`n"
$usersWarningBody += "`r`n"
$usersWarningBody += "An automatic check has found a process for $appName with a disconnected session." + "`r`n"
$usersWarningBody += "`r`n"
$usersWarningBody += "All $appName users will be reset after a grace period of $gracePeriod minutes." + "`r`n"
$usersWarningBody += "`r`n"
$usersWarningBody += "Regards," + "`r`n"
$usersWarningBody += "Tech Team" + "`r`n"
$usersWarningBody += "`r`n"

##  ----------------------------------------------------------------------------

$adminDoneSubject = "Logged off sessions on $procHost for $appName"

$adminDoneBody = ""
$adminDoneBody += "Logged off users for $procName on $procHost and removed lock files." + "`r`n"

$usersDoneSubject = "OK to continue using $appName"

$usersDoneBody = ""
$usersDoneBody += "Hello $appName users," + "`r`n"
$usersDoneBody += "`r`n"
$usersDoneBody += "The disconnected session for $appName has been logged off, and lock files have been removed." + "`r`n"
$usersDoneBody += "`r`n"
$usersDoneBody += "You can now use $appName as required." + "`r`n"
$usersDoneBody += "`r`n"
$usersDoneBody += "Regards," + "`r`n"
$usersDoneBody += "Technology Team" + "`r`n"
$usersDoneBody += "`r`n"

##  ----------------------------------------------------------------------------

$global:activeProcExists = $null
$global:discProcExists = $null
$global:discUsers = @()

##  ----------------------------------------------------------------------------

Function ProcRunning
{
    Param
    (
        [Parameter(Mandatory=$True, Position=0)] [string] $procHost,
        [Parameter(Mandatory=$True, Position=1)] [string] $procName
    )

    $procRunning = $null
    $procCount = Get-WmiObject -computername $procHost Win32_Process -Filter "name='$procName'" | Measure-Object | Select Count
    if ($procCount.Count -eq 0)
    {
        $procRunning = $False
    }
    elseif ($procCount.Count -gt 0)
    {
        $procRunning = $True
    }
    Return $procRunning
}

##  ----------------------------------------------------------------------------

Function Check-SessionStates
{
    Param
    (
        [Parameter(Mandatory=$True, Position=0)] [string] $procHost,
        [Parameter(Mandatory=$True, Position=1)] [string] $procName
    )

    $global:activeProcExists = $False
    $global:discProcExists = $False
    $sessionId = $null

    $procSessions = Get-WmiObject -computername $procHost Win32_Process -Filter "name='$procName'" | Select SessionId
    foreach ($procSessionId in $procSessions)
    {
        $sessionId = $procSessionId.SessionId
        $username = $null
        $sessionState = $null

        $outputReturned = query session $sessionId /SERVER:$procHost
        $outputRows = $outputReturned -split "`n"
        foreach ($row in $outputRows)
        {
            $regex = "Disc|Active"
            if ($row -NotMatch "SESSIONNAME" -and $row -Match $regex)
            {
                $splitRow = $($row -Replace ' {2,}', ',').split(',')
                $username = $splitRow[1]
                $sessionState = $splitRow[3]
                #Write-Host "Session $sessionId for $username is $sessionState"
            }
        }
        if ($sessionState -Match "Active")
        {
            $global:activeProcExists = $True
            #Write-Host "Evaluated $sessionId for $username as active"
        }
        elseif ($sessionState -Match "Disc")
        {
            $global:discProcExists = $True
            $global:discUsers += $username
            #Write-Host "Evaluated $sessionId for $username as disconnected."
        }
        else
        {
            Write-Host "Session $sessionId for $username..  ..  Session state is..  ..  UNKNOWN..!!!"
            Write-Host "..  ..  So something went wrong while running this script..!!!"
        }
    }
    #Write-Host "Var discProcExists value is..  ..  $global:discProcExists"
    #$tempArray = $global:discUsers | Sort-Object | Get-Unique
    #$tempArray = $global:discUsers | Sort-Object -Unique
    #$global:discUsers = $tempArray
}

##  ----------------------------------------------------------------------------

Function logOffProcUsers
{
    Param
    (
        [Parameter(Mandatory=$True, Position=0)] [string] $procHost,
        [Parameter(Mandatory=$True, Position=1)] [string] $procName
    )

    $sessionId = $null
    $procSessions = Get-WmiObject -computername $procHost Win32_Process -Filter "name='$procName'" | Select SessionId
    foreach ($procSessionId in $procSessions)
    {
        $sessionId = $procSessionId.SessionId
        Write-Host "About to log off Session ID $sessionId for $procName process."
        $outputReturned = logoff $sessionId /SERVER:$procHost
    }
}

##  ----------------------------------------------------------------------------
##
##  Main script. 
##


Check-SessionStates $procHost $procName
if ($global:discProcExists)
{
    Write-Host
    Write-Host "***   Not all $procHost sessions for $procName are active..!!!"
    $discUserList = ""
    $global:discUsers = $global:discUsers | Sort-Object -Unique
    foreach ($individual in $global:discUsers)
    {
        $discUserList += $individual + "`r`n"
    }
    Write-Host "***   This is for..  ..  `r`n"
    Write-Host $discUserList
    Write-Host "***"
    $adminWarningBody += "This is for..  ..  `r`n" + $discUserList
    Send-MailMessage -SmtpServer $smtpServer -From $adminFrom -To $adminTo -Subject $adminWarningSubject -Body $adminWarningBody
    Send-MailMessage -SmtpServer $smtpServer -From $usersFrom -To $usersTo -Subject $usersWarningSubject -Body $usersWarningBody

    ##  Timing grace period. 
    $minute = 0
    Write-Host "Minute $minute of $gracePeriod minute grace period..  ..  Waiting for another minute."
    Do
    {
        $minute += 1

        <#
                
        ##
        ##  Seconds per minute is adjustable for testing..  ..  As strange as that may sound.  
        ##
        ##  Check out the variable declaration section, at the start of this 
        ##    script, for something that looks like this; 
        ##  ##  ----------------------------------------
        ##  
        ##  #$secondsPerMin = 60
        ##  $secondsPerMin = 1
        ##  
        ##  ##  ----------------------------------------

        #>

        Start-Sleep -Seconds $secondsPerMin

        if ($secondsPerMin -eq 60)
        {
            Write-Host "Minute $minute has passed..  ..  Rechecking."
        }
        else
        {
            Write-Host "Minute $minute has passed (currently set to $secondsPerMin seconds per minute while testing)..  ..  Rechecking."
        }
        
        ##  Refresh.
        Check-SessionStates $procHost $procName
    } While ($global:activeProcExists = $True -and $minute -lt $gracePeriod)
    
    ##  All active users have logged off..  ..  or  ..  ..  grace period is over. 
    Write-Host "Either all active users have logged off or grace period is over."
    
    ##  Log off All (active and disc) proc users. 
    logOffProcUsers $procHost $procName
    Start-Sleep -Seconds 10
    if (ProcRunning $procHost $procName)
    {
        Write-Host
        Write-Host "***   Problem logging off $appName users."
        Write-Host "***   Some sessions remain after logoff command was run."
        Send-MailMessage -From $adminFrom -To $adminTo -Subject "Problem logging off $appName users." -Body "Some sessions remain after logoff command was run." -SmtpServer $smtpServer
    }
    else
    {
        Remove-Item $removeFiles
        Send-MailMessage -From $adminFrom -To $adminTo -Subject $adminDoneSubject -Body $adminDoneBody -SmtpServer $smtpServer
        Send-MailMessage -From $usersFrom -To $usersTo -Subject $usersDoneSubject -Body $usersDoneBody -SmtpServer $smtpServer
    }
}
else
{
    Write-Host
    Write-Host "***   All $procHost session for $procName are active."
    Write-Host "***   No need to do anything more." 
}
Write-Host
Write-Host "Done."
