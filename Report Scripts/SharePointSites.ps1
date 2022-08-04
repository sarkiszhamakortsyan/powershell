Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
##################################
##################################
$cred = Get-Credential
Import-Module MsOnline

Connect-MsolService -Credential $cred

Write-Host "Connected to MsolServices " -ForegroundColor Green

Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking

Connect-SPOService -Url https://technolinkad-admin.sharepoint.com -credential $cred

Get-SPOSite | select Title, StorageUsageCurrent, StorageQuota, StorageQuotaWarningLevel, Url, Status | export-csv c:/SharePointSitesReport.csv -Encoding UTF8


