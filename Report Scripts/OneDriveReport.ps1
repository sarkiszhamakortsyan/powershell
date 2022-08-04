Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
##################################
##################################
$cred = Get-Credential
Import-Module MsOnline

Connect-MsolService -Credential $cred

Write-Host "Connected to MsolServices " -ForegroundColor Green

Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking

Connect-SPOService -Url https://technolinkad-admin.sharepoint.com -credential $cred
 
Write-Host "Connected to SharePoint" -ForegroundColor Green

foreach ($login in ((get-spouser -Site https://technolinkad-my.sharepoint.com).LoginName))
{
if($login.Contains('@')) 
{ $login=$login.Replace('@','_');
 $login=$login.Replace('.','_'); 
 $login=$login.Replace('.','_');
 $login="https://technolinkad-my.sharepoint.com/personal/"+$login;
  Get-SPOSite -erroraction silentlycontinue -Identity $login | select Status, title, *storage*   | export-csv c:\OneDriveReport.csv -Append -Encoding UTF8} 
}




