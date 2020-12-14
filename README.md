# System-Admin-Scripts

## check_app_disconnect.ps1

Originally intended to clean up MYOB processes running in disconnected RDP sessions, and remove the lock file. 

Tested extensively with disconnected sessions running cmd.exe, with a text file to delete, and found to be working well. 
Did not quite make it to production before the decision was made to move away from the MYOB via RDP, so this script became something that was uneeded. 

This could potentially be helpful for any program used via RDP, which needs disconnected sessions to be managed. 
