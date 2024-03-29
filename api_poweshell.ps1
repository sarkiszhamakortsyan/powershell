##############################################
######## RESTAPI CALL WITH CERTIFICATE #######
##############################################

 

#### PATH TO CERTIFICATE ####
$cert = "c:\storage\admind.crt"

 

#### SELECT SECURITY PROTOCOL TYPE ####
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

 

#### ADD CREDENTIALS YOU WILL BE PROMPTED FOR THEM ####
$cred = $(Get-Credential -message "Please enter username and password")

 

#### EXECUTE THE QUERY ####
$result = Invoke-RestMethod -Method Get -Uri "https://10.232.10.86:444/api/v1.4/transfers?limit=100&offset=0" -Credential $cred -ContentType "application/json" -Certificate $cert