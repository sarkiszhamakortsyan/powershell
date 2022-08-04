Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
##################################
##################################
$cred = Get-Credential

Import-Module MsOnline

Connect-MsolService -Credential $cred

Write-Host "Connected to MsolServices " -ForegroundColor Green

$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $cred -Authentication "Basic" -AllowRedirection

Import-PSSession $exchangeSession -DisableNameChecking

Get-MsolGroup | select DisplayName, GroupType, Discription | export-csv c:/GroupReport.csv -Encoding UTF8
