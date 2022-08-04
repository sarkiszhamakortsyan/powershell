#set Edition ID
$Edition = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name EditionID).EditionID
$reqEdition = 'EnterpriseN'
if($Edition -ne $reqEdition){
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name EditionID -Value $reqEdition}
#set Product Name
$prodName = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name ProductName).ProductName
$reqName = 'Windows 10 Enterprise N'
if($prodName -ne $reqName){
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name ProductName -Value $reqName}