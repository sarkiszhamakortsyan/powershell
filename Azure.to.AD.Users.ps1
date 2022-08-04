param(
[parameter(Mandatory=$false)]
[switch]$UpdateImmutableID = $false,
[parameter(Mandatory=$false)]
[switch]$CreateNewUsers = $true,
[parameter(Mandatory=$false)]
[string]$TargetOU = "OU=FRANCHISES,DC=technolink,DC=org"
)
  
#Load required Modules and Assemblys
Import-Module MSOnline
Import-Module ActiveDirectory
[Reflection.Assembly]::LoadWithPartialName("System.Web") | Out-Null
  
Connect-MsolService
  
$WAADUsers = Get-MsolUser -UserPrincipalName kaloyan.gaidarov@profilink.eu | Where-Object {$_.UserPrincipalName -notlike "*.onmicrosoft.com"}
  
foreach ($WAADUser in $WAADUsers) {
    $ADuser = Get-ADUser -Filter {UserPrincipalName -eq $WAADUser.UserPrincipalName}
       
    try {
  
        $Mail = $($WAADUser.ProxyAddresses | Where-Object {$_ -cmatch "^SMTP"}).substring(5)
          
        if ($ADuser) {
        #Update AD user with attributes from WAAD
        Set-ADUser -Identity $ADuser `
            -EmailAddress $Mail `
            -GivenName $WAADUser.FirstName `
            -SurName $WAADUser.LastName `
            -DisplayName $WAADUser.DisplayName `
            -Replace @{ProxyAddresses=[string[]]$WAADUser.ProxyAddresses} `
            -ErrorAction Stop -WarningAction Stop
  
        Write-Output "SUCCESS: Updated $($ADuser.userprincipalname) with proper attributes from WAAD"
          
        } else {
  
            if ($CreateNewUsers) {
  
                     #Generate password for the user aduser
                     $NewUserPassword = [System.Web.Security.Membership]::GeneratePassword(13,0)
  
                     #Generate samaccountname "firstname.lastname"
                     $SAM = [Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding("Cyrillic").GetBytes("$($WAADUser.Firstname).$($WAADUser.Lastname)".ToLower()))
                                            
                     New-ADUser -Path $TargetOU `
                        -Name $WAADUser.DisplayName `
                        -UserPrincipalName $WAADUser.UserPrincipalName `
                        -SamAccountName $sam `
                        -Enabled $true `
                        -EmailAddress $Mail `
                        -GivenName $WAADUser.FirstName `
                        -SurName $WAADUser.LastName `
                        -DisplayName $WAADUser.DisplayName `
                        -OtherAttributes @{ProxyAddresses=[string[]]$WAADUser.ProxyAddresses} `
                        -AccountPassword (ConvertTo-SecureString $NewUserPassword -AsPlainText -force) `
                        -ErrorAction Stop -WarningAction Stop
  
                     Write-Output "SUCCESS: Created user $sam with password $NewUserPassword"
 
            } else {
                     
                     Write-Warning "User $($WAADUser.UserPrincipalName) is not in AD, user might not be synchronized correctly or become a duplicate user.`r`nCreate the user manually or run the script with -CreateNewUsers switch."
             
            }
        }
                
        #If UpdateImmutableID switch has been used, construct and set ImmutableID for the WAAD user.
        if ($UpdateImmutableID) {
            $ADuser = Get-ADUser -Filter {UserPrincipalName -eq $WAADUser.UserPrincipalName}
            if ($ADuser) {
                $ImmutableID = [system.convert]::ToBase64String($ADuser.ObjectGUID.ToByteArray())
                Set-MsolUser -UserPrincipalName $WAADUser.UserPrincipalName -ImmutableId $ImmutableID -ErrorAction Stop -WarningAction Stop
            }
        }
       
   } catch [Microsoft.Online.Administration.Automation.MicrosoftOnlineException] {
              
            Write-Warning "Error when updating ImmutableID $ImmutableID for $Mail`r`n$_"
  
   } catch {
             
            Write-Warning "Error when creating user $Mail`r`n$_"
         
   }
  
}