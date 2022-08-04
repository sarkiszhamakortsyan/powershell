 Get-AdUser -Filter * -SearchBase 'ou=employees, dc=technolink, dc=org' -Properties UserPrincipalName, Name, EmailAddress, ProxyAddresses | `
 Select-Object UserPrincipalName, Name, EmailAddress, @{L = "ProxyAddresses"; E = { $_.ProxyAddresses -join ","}} | `
 Export-CSV -Path C:\Users\dobromir.dobrev\Desktop\MyADUsers.csv -NoTypeInformation