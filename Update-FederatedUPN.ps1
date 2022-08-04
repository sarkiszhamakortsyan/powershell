######################################################################################################
#                                                                                                    #
# Name:        Update-FederatedUPN.ps1                                                               #
#                                                                                                    #
# Version:     1.1                                                                                   #
#                                                                                                    #
# Description: Looks up the UPN for a user based on the immutableID provided in the synchronization  #
#              error report and changes the UPN to the tenant default suffix so the user can be      #
#              changed to another federated domain.  Requires that you are connected to Azure AD via #
#              PowerShell and populate the $tenant value appropriately in the script.                #
#                                                                                                    #
# Author:      Joseph Palarchio                                                                      #
#                                                                                                    #
# Usage:       Additional information on the usage of this script can found at the following         #
#              blog post:  http://blogs.perficient.com/microsoft/?p=26462                            #
#                                                                                                    #
# Disclaimer:  This script is provided AS IS without any support. Please test in a lab environment   #
#              prior to production use.                                                              #
#                                                                                                    #
######################################################################################################

$immutableId = $args[0]
$tenant = "@technolinkad.onmicrosoft.com"

$user = Get-MsolUser -UserPrincipalName "test@technolink.org" | where {$_.ImmutableId -eq $immutableId}

$newUPN = "_temp_"+$user.UserPrincipalName.SubString(0,$user.UserPrincipalName.IndexOf("@"))+$tenant

Write-Host "Current UPN:" $user.UserPrincipalName
Write-Host "Changed To: " $newUPN

Set-MsolUserPrincipalName -UserPrincipalName $user.UserPrincipalName -NewUserPrincipalName $newUPN | Out-Null

Write-Host