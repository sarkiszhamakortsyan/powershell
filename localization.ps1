$path = Test-Path "C:\ProgramData\locales.OK"
if($path -eq $true)
{
break
}
else{
$langlist = Get-WinUserLanguageList
$langlist = New-WinUserLanguageList en-US
$langList[0].InputMethodTips.Clear()
$langList[0].InputMethodTips.Add('0402:00000402')
$langList[0].InputMethodTips.Add('0409:00000409')
$langList[0].InputMethodTips.Add('0402:00040402')
Set-WinUserLanguageList $langList -Force
New-Item "$Env:ALLUSERSPROFILE\locales.OK"
}