#connect to Vcenter
function Connect-VCenter {
    $credential = Get-Credential
    Connect-VIServer -Server bg-pdv01-vc01.technolink.org -Protocol https -Credential $Credential
}
Connect-VCenter

#variables
$VM="bg-pdv02-tst01"
$core01 = "esxi-core1.technolink.org"
$core02 = "esxi-core2.technolink.org"

#suspend VM, move to other VMHost and start
Suspend-VM -VM $VM -Confirm:$false
if ((Get-VMHost -VM $VM).Name -eq $core01){
    Move-VM -VM $VM -Destination $core02 | Start-VM
}
else {
    Move-VM -VM $VM -Destination $core01 | Start-VM
}