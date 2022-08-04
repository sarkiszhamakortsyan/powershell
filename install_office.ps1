############################################################################################################################################
# Date of creation - July 2021                                                                                                             #
# Creator - Google.com mostly                                                                                                              #
# Script for "silent" MS Office installation. As up until this date, MS officially does not support Office silent installation.            #
# There are two options to you can install MS Office without any stuped questions.                                                         #
# Option #1:                                                                                                                               #
# Used for current installation. The ISO which we use, installs Office automatically - no accepting, no clicking, no nothing.              #
# Just start the setup.exe file from the mounted image. You can find explonation on every comment.                                         #
#                                                                                                                                          #
# Option #2:                                                                                                                               #
# This method uses .xml file where you add the options during the Office installation (like License Agreement, select what and where       #
# to install and etc.) and Office Deployment tool to apply the .xml file. Officially, this method supports only Office 2019 and Office 365 #
# installations. In this case I need to install any Office versions like 2016 which is why I use "Option #1". I will leave the lines       #
# for this installation option commented. Edit and uncomment them in case you need to use this option. More information you can find in    #
# google.com - knows everything including passwords.                                                                                       #
############################################################################################################################################

## Import module for file transfer over HTTP. With this module I get fastest transfer speed for files with large size - over 1GB
Import-Module BitsTransfer

## Creates a temporary directory to store the files used for installation.
New-Item -Path "c:\" -Name "tmp" -ItemType "directory"
Start-Sleep -s 5

## Changing the folder.
Set-Location -Path c:\tmp
Start-Sleep -s 2

## The line below will download the Office ISO file from the link in c:\tmp folder
Start-BitsTransfer -Source "http://192.168.0.100/en_office_professional_plus_2016_x86_x64_dvd_6962141.iso" -Destination "c:\tmp\en_office_professional_plus_2016_x86_x64_dvd_6962141.iso"
Start-Sleep -s 5

## The line below will download the configuration .xml file and Office Deployment tool used for the silent installation. Edit and uncomment the line if you are about to use "Option #2".
#Start-BitsTransfer -Source "http://10.129.110.65/Office/configuration.xml" -Destination "c:\tmp\Configuration.xml"
#Start-BitsTransfer -Source "http://10.129.110.65/Office/officedeploymenttool_14131-20278.exe" -Destination "c:\tmp\officedeploymenttool_14131-20278.exe"

## Get rid of ""Yes, I want to run this action" in Windows
Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0

## Extract the Office Deployment Tool archive. Edit and uncomment the line below if you want to use "Option #2"
#Expand-Archive -LiteralPath '.\officedeploymenttool_14131-20278.exe'

## Mount the ISO file which we download before.
Mount-DiskImage -ImagePath "c:\tmp\en_office_professional_plus_2016_x86_x64_dvd_6962141.iso"
Start-Sleep -s 5

## Changing the drive where we mounted the ISO.
Set-Location -Path e:\
Start-Sleep -s 5

## Start Office installation. You can use the line below for "Option #1" and "Option #2". For "Option #2" just double check the path to configuration file.
start-process ("\setup.exe") -verb runas -Argumentlist "/configure c:\tmp\configuration.xml" -Wait | out-null
Start-Sleep -s 5

## Changing the folder.
Set-Location -Path "C:\Program Files (x86)\Microsoft Office\Office16\"
Start-Sleep -s 2

## Change the Product key.
cscript ospp.vbs /inpkey:3BNMD-9TTPB-C4824-HFKCJ-QDB3P
Start-Sleep -s 2

## Activate the Office.
cscript ospp.vbs /act
Start-Sleep -s 2

## Let clean up the mess which we have made. Unmount the ISO file which we already mounted.
Dismount-DiskImage -ImagePath "c:\tmp\en_office_professional_plus_2016_x86_x64_dvd_6962141.iso"
Start-Sleep -s 2

## Delete te tmp folder which we created before.
Remove-Item 'c:\tmp'