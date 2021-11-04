# System-Admin-Scripts

Going to place some scripts here that I think might be handy for others. 

##  Windows

###  check_app_disconnect.ps1

Originally intended to clean up MYOB processes running in disconnected RDP sessions, and remove the lockfile. The lock file (with .flk file extension) needed to be removed before a disconnected user could log on again. 

Tested extensively with disconnected sessions running cmd.exe, with a text file to delete, and found to be working well. 
Did not quite make it to production before the decision was made to move away from the MYOB via RDP, so this script became something that was no longer required. 

This could potentially be helpful for any program used via RDP, which needs disconnected sessions to be managed. 

##  PowerCLI

###  vCenter_Alarm_emails_audit.ps1

Check email address currently being used for alarms. 

###  vCenter_Email_alerts_refresh.ps1

Set email address to use for alarms. 

###  vCenter_Alarm_history.ps1

Check alarm emails sent. Number of days of history can be set. 

##  Linux/Unix

###  dat2csv.py

At a previous role (way back) there were some Informix C-ISAM databases (and later D-ISAM I believe). 

As the development team were always too busy for ad hoc checks on the data, I often found myself writing script to search for information in the database files. So I wrote this script to read data out of a database table, and output this to a CSV file. People interested in this data could then use Excel to manipulate, filter and sort to their hearts content. 
