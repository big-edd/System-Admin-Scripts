# System-Admin-Scripts

Going to place some scripts here that I think might be handy for others. 

## check_app_disconnect.ps1

Originally intended to clean up MYOB processes running in disconnected RDP sessions, and remove the lockfile. The lock file (with .flk file extension) needed to be removed before a disconnected user could log on again. 

Tested extensively with disconnected sessions running cmd.exe, with a text file to delete, and found to be working well. 
Did not quite make it to production before the decision was made to move away from the MYOB via RDP, so this script became something that was uneeded. 

This could potentially be helpful for any program used via RDP, which needs disconnected sessions to be managed. 
