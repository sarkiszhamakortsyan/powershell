$nxlog = "C:\Program Files (x86)\nxlog\"
$conf = "C:\Program Files (x86)\nxlog\conf\nxlog.conf.default"
if((Test-Path $nxlog) -eq $false){
    ### Install nxlog client
    msiexec.exe /i  "\\BG-PDV01-WDS01.technolink.org\Content\NXLog\nxlog-ce-2.9.1716.msi" /quiet 
    }
Start-Sleep -s 30
if(((Test-Path $nxlog) -eq $true) -and ((Test-Path $conf) -eq $false)){
    ### Rename default .conf file and copy new configuration file 
    Rename-Item "C:\Program Files (x86)\nxlog\conf\nxlog.conf" "C:\Program Files (x86)\nxlog\conf\nxlog.conf.default"
    Copy-Item "\\BG-PDV01-WDS01.technolink.org\Content\NXLog\nxlog.conf" "C:\Program Files (x86)\nxlog\conf\nxlog.conf"
    }