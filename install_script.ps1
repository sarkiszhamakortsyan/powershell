# Runs after Windows Updates have been applied

Install-Module WindowsBox.AutoLogon -Force
Install-Module WindowsBox.Compact -Force
Install-Module WindowsBox.Explorer -Force
Install-Module WindowsBox.Hibernation -Force
Install-Module WindowsBox.RDP -Force
Install-Module WindowsBox.UAC -Force
Install-Module WindowsBox.VagrantAccount -Force
Install-Module WindowsBox.VMGuestTools -Force

Disable-AutoLogon
Disable-UAC
Enable-RDP
Set-ExplorerConfiguration
Disable-Hibernation
Set-VagrantAccount
Install-VMGuestTools

# Install Docker if the provider is available on this OS
Install-Module DockerMsftProvider -Force
if ((Get-PackageProvider -ListAvailable).Name -Contains "DockerMsftProvider") {
  Install-Package -Name docker -ProviderName DockerMsftProvider -Force
}

# Install Linux subsystem
Install-Module WindowsBox.DevMode -Force
Enable-DevMode

# Install chocolatey and use it to install dev tools
Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression

# Install software using chocolatey

# Visual Studio tools 2017
#choco install visualstudio2017community -y
#choco install visualstudio2017-workload-netcoretools -y
#choco install visualstudio2017-workload-netweb -y
#choco install visualstudio2017-workload-node -y
#choco install visualstudio2017-workload-azure -y
#choco install visualstudio2017-workload-nativedesktop -y
#choco install visualstudio2017-workload-manageddesktop -y

# Visual Studio tools 2019
#choco install visualstudio2019community -y
#choco install visualstudio2019-workload-netcoretools -y
#choco install visualstudio2019-workload-netweb -y
#choco install visualstudio2019-workload-node -y
#choco install visualstudio2019-workload-azure -y
#choco install visualstudio2019-workload-nativedesktop -y
#choco install visualstudio2019-workload-manageddesktop -y
#choco install vscode -y

# Install browsers
choco install googlechrome -y
#choco install firefox -y
#choco install microsoft-edge -y

# Install SQL tools
#choco install sql-server-management-studio -y
#choco install sqlite -y

# Install other tools
#choco install 7zip
#choco install powershell-packagemanagement -y
#choco install notepadplusplus.install -y
#choco install fiddler -y
#choco install nuget.commandline -y
#choco install snaketail -y
#choco install procmon -y
#choco install procexp -y
#choco install screentogif -y
#choco install git.install -y

#[System.Net.HttpWebRequest]::DefaultWebProxy = New-Object System.Net.WebProxy
#Invoke-WebRequest http://artifactory.dev.syncplicity.com:80/artifactory/vagrant/install-office.ps1 -UseBasicParsing | Invoke-Expression
./install-office.ps1

# Final cleanup
Optimize-DiskUsage