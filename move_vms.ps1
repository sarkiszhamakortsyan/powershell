#connect to Vcenter
function Connect-VCenter {
    $credential = Get-Credential
    Connect-VIServer -Server bg-pdv01-vcs01.technolink.org -Protocol https -Credential $Credential
}
Connect-VCenter


#Move VMS around
Get-VM | where {$_.VMHost.Name -eq "esxi-core1.technolink.org"} | Move-VM -Destination "esxi-core2.technolink.org"
Start-Sleep -s 10

Get-VM | where {$_.VMHost.Name -eq "esxi-core2.technolink.org"} | Move-VM -Destination "esxi-core1.technolink.org"
Start-Sleep -s 10

Get-VM | where {$_.VMHost.Name -eq "esxi-core1.technolink.org"} | Move-VM -Destination "esxi-core2.technolink.org"
Start-Sleep -s 10

Get-VM | where {$_.VMHost.Name -eq "esxi-core2.technolink.org"} | Move-VM -Destination "esxi-core1.technolink.org"
Start-Sleep -s 10

Get-VM | where {$_.VMHost.Name -eq "esxi-core1.technolink.org"} | Move-VM -Destination "esxi-core2.technolink.org"