﻿###########################
##  SET KEYBOARD LAYOUT  ##
##        SCRIPT         ##
###########################

$langlist = Get-WinUserLanguageList
$langlist = New-WinUserLanguageList en-US
$langlist[0].InputMethodTips.Clear()

##### English United States #####
$langlist[0].InputMethodTips.Add('0409:00000409')
##### Bulgarian TypeWriter #####
$langlist[0].InputMethodTips.Add('0402:00000402')
##### Bulgarian Phonetic Traditional #####
$langlist[0].InputMethodTips.Add('0402:00040402')

Set-WinUserLanguageList $langlist -Force

# Print the results
$langlist