###########################
#     CREATE NEW USER     #
###########################

# Create new local Admin user for script purposes

$Password = Read-Host -Prompt 'Input Password' -AsSecureString
New-LocalUser "kiosk" -Password $Password -FullName "Kiosk" -Description "default kiosk account" -AccountNeverExpires -PasswordNeverExpires -UserMayNotChangePassword

##########################
#     USER AUTOLOGON     #
##########################

Set-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon  -Value "1" -Force
Set-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultUserName" -Value "kiosk" -Force

function Test-RegistryValue {
    param (
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]$Path,
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]$Value
    )
    try {
    Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Value -ErrorAction Stop | Out-Null
    return $true
    }
    catch {
    return $false
    }
}

$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
$PasswordPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

if(Test-RegistryValue -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Value 'DefaultPassword'){
    Set-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultPassword" -Value $PasswordPlain
}
else{
    New-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultPassword" -Value $PasswordPlain -Force
}

###########################
#    DISABLE PC SLEEP     #
###########################

powercfg.exe -change disk-timeout-ac 0
powercfg.exe -change disk-timeout-dc 0
powercfg.exe -change monitor-timeout-ac 0
powercfg.exe -change monitor-timeout-dc 0
powercfg.exe -change standby-timeout-ac 0
powercfg.exe -change standby-timeout-dc 0
powercfg.exe -change hibernate-timeout-ac 0
powercfg.exe -change hibernate-timeout-dc 0

###############################
#    DISABLE TASK MANAGER     #
###############################

REG add HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System /v DisableTaskMgr /t REG_DWORD /d 1 /f

##################
#    FEATURES    #
##################

Dism /online /Enable-Feature /all /FeatureName:Client-EmbeddedShellLauncher

######################
#     KIOSK MODE     #
######################

# Check if shell launcher license is enabled
function Check-ShellLauncherLicenseEnabled
{
    [string]$source = @"
using System;
using System.Runtime.InteropServices;

static class CheckShellLauncherLicense
{
    const int S_OK = 0;

    public static bool IsShellLauncherLicenseEnabled()
    {
        int enabled = 0;

        if (NativeMethods.SLGetWindowsInformationDWORD("EmbeddedFeature-ShellLauncher-Enabled", out enabled) != S_OK) {
            enabled = 0;
        }

        return (enabled != 0);
    }

    static class NativeMethods
    {
        [DllImport("Slc.dll")]
        internal static extern int SLGetWindowsInformationDWORD([MarshalAs(UnmanagedType.LPWStr)]string valueName, out int value);
    }

}
"@

    $type = Add-Type -TypeDefinition $source -PassThru

    return $type[0]::IsShellLauncherLicenseEnabled()
}

[bool]$result = $false

$result = Check-ShellLauncherLicenseEnabled
"`nShell Launcher license enabled is set to " + $result
if (-not($result))
{
    "`nThis device doesn't have required license to use Shell Launcher"
    exit
}

$COMPUTER = "localhost"
$NAMESPACE = "root\standardcimv2\embedded"

# Create a handle to the class instance so we can call the static methods.
try {
    $ShellLauncherClass = [wmiclass]"\\$COMPUTER\${NAMESPACE}:WESL_UserSetting"
    } catch [Exception] {
    write-host $_.Exception.Message; 
    write-host "Make sure Shell Launcher feature is enabled"
    exit
    }


# This well-known security identifier (SID) corresponds to the BUILTIN\Administrators group.

$Admins_SID = "S-1-5-32-544"

# Create a function to retrieve the SID for a user account on a machine.

function Get-UsernameSID($AccountName) {

    $NTUserObject = New-Object System.Security.Principal.NTAccount($AccountName)
    $NTUserSID = $NTUserObject.Translate([System.Security.Principal.SecurityIdentifier])

    return $NTUserSID.Value

}

# Get the SID for a user account named "kiosk".

$kiosk_SID = Get-UsernameSID("kiosk")

# Define actions to take when the shell program exits.

$restart_shell = 0
$restart_device = 1
$shutdown_device = 2

# Examples. You can change these examples to use the program that you want to use as the shell.

# This example sets the command prompt as the default shell, and restarts the device if the command prompt is closed. 

$ShellLauncherClass.SetDefaultShell("cmd.exe", $restart_device)

# Display the default shell to verify that it was added correctly.

$DefaultShellObject = $ShellLauncherClass.GetDefaultShell()

"`nDefault Shell is set to " + $DefaultShellObject.Shell + " and the default action is set to " + $DefaultShellObject.defaultaction

# Set Internet Explorer as the shell for "kiosk", and restart the machine if Internet Explorer is closed.

$ShellLauncherClass.SetCustomShell($kiosk_SID, "C:\Program Files\Internet Explorer\iexplore.exe http://bg-pdv01-eprd01.technolink.org:8084/PapierloseFertigung", ($null), ($null), $restart_shell)

# Set Explorer as the shell for administrators.

$ShellLauncherClass.SetCustomShell($Admins_SID, "explorer.exe")

# View all the custom shells defined.

"`nCurrent settings for custom shells:"
Get-WmiObject -namespace $NAMESPACE -computer $COMPUTER -class WESL_UserSetting | Select-Object Sid, Shell, DefaultAction

# Enable Shell Launcher

$ShellLauncherClass.SetEnabled($TRUE)

$IsShellLauncherEnabled = $ShellLauncherClass.IsEnabled()

"`nEnabled is set to " + $IsShellLauncherEnabled.Enabled

################ RUN TO CLEAR SETTINGS

## Remove the new custom shells.
#$ShellLauncherClass.RemoveCustomShell($Admins_SID)
#$ShellLauncherClass.RemoveCustomShell($Cashier_SID)

## Disable Shell Launcher
#$ShellLauncherClass.SetEnabled($FALSE)
#$IsShellLauncherEnabled = $ShellLauncherClass.IsEnabled()
#"`nEnabled is set to " + $IsShellLauncherEnabled.Enabled