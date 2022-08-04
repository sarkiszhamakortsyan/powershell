#########################################################
# Chef Repo + Test Kitchen - Live and Local Development #
#########################################################

#############################################
### Configure PowerShell Execution Policy ###
#############################################
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force

######################
### Enable Hyper-V ###
######################
$hyperv = Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online
if($hyperv.State -eq "Enabled") {
    Write-Host "Hyper-V is already enabled." -ForegroundColor Green
} else {
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart
}

############################
### Install Just-Install ###
############################
If ((Test-Path 'C:\Windows\just-install.exe') -eq $true){
    Write-Host "Just-Install is present on your system!" -ForegroundColor Green
}
else {
    msiexec.exe /i http://go.just-install.it
}

###################
### Install Git ###
###################
If ((Test-Path 'C:\Program Files\Git') -eq $true){
    Write-Host "Git is present on your system!" -ForegroundColor Green
}
else {
    just-install git
}

#################
### Reload PS ###
#################
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

################
### Git Path ###
################
$path = [Environment]::GetEnvironmentVariable("PATH", "Machine")
$git_path = "C:\Program Files\Git\usr\bin"
if (([System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")) -like "*Git\usr\bin*") { Write-Host "
    env:Path GIT already exists!" -ForegroundColor Green
} else {
    [Environment]::SetEnvironmentVariable("PATH", "$path;$git_path", "Machine")
}

#################
### Reload PS ###
#################
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

#####################
### Git Configure ###
#####################
Write-Host "Configuring Git User All fields are required!" -ForegroundColor Green
$gitemail = Read-Host -Prompt 'Input your email'
$gitname = Read-Host -Prompt 'Input your name'
$gitkeypass = Read-Host -Prompt 'Input RSA Key Passphrase' -AsSecureString
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($gitkeypass)
$gitkeypassPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

##############################
### Git Keys - Be Patient! ###
##############################
ssh-keygen -t rsa -b 4096 -C $gitemail -P $gitkeypassPlain

#####################################
### Add your key to the ssh-agent ###
#####################################
ssh-add ~/.ssh/id_rsa

#####################################################
### Copy the contents of the key to the clipboard ###
#####################################################
Get-Content ~/.ssh/id_rsa.pub | Set-Clipboard

###############################################
### Go to GitHub Web and paste your new key ###
###############################################
Write-Host "You Public key is in the clipboard
Paste it to your https://github.com/settings/ssh > New SSH Key
 & Press any key to continue...
" -ForegroundColor Green
[void][System.Console]::ReadKey($true)

################
### Git User ###
################
git config --global user.email $gitemail
git config --global user.name $gitname
git config --global push.default simple
git config --global core.ignorecase false

##########################################
### Configure line endings for windows ###
##########################################
git config --global core.autocrlf true

#######################################
### Choose folder for the chef-repo ###
#######################################
Write-Host "Select the folder for Your Chef Repo" -ForegroundColor Green
Function Select-FolderDialog{
    param([string]$Description="Select Folder",[string]$RootFolder="Desktop")
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null     
    $objForm = New-Object System.Windows.Forms.FolderBrowserDialog
    $objForm.Rootfolder = $RootFolder
    $objForm.Description = $Description
    $Show = $objForm.ShowDialog()
    if ($Show -eq "OK"){
        Return $objForm.SelectedPath
    }
    Else{
        Write-Error "Operation cancelled by user."
    }
}

###################################################
### The variable contains user folder selection ###
###################################################
$folder = Select-FolderDialog

####################################
### Git Clone in selected folder ###
####################################
Write-Host "Input RSA Key Passphrase" -ForegroundColor Green
git clone git@github.com:techno-link/chef-repo.git $folder 
Write-Host "Cloning Chef Repo is complete" -ForegroundColor Green

##########################
### Visual Studio Code ###
##########################
If ((Test-Path 'C:\Program Files (x86)\Microsoft VS Code') -eq $true){
    Write-Host "VS Code is present on your system" -ForegroundColor Green
}
else {
    just-install visual-studio-code
}
##############
### ChefDK ###
##############
If ((Test-Path 'C:\opscode\chefdk') -eq $true){
    Write-Host "ChefDK is present on your system" -ForegroundColor Green
}
else {
    Invoke-WebRequest -usebasic https://omnitruck.chef.io/install.ps1 | Invoke-Expression; install chefdk
}

#################
### Reload PS ###
#################
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

#########################################
### Add DK to PS Profile or Create it ###
#########################################
if ((Test-Path $PROFILE) -eq $true){ 
    chef shell-init powershell | Add-Content $PROFILE 
} 
else { 
    New-Item -ItemType File $PROFILE -Force; chef shell-init powershell | Add-Content $PROFILE 
}

########################
### Chef DK env Path ###
########################
$path = [Environment]::GetEnvironmentVariable("PATH", "Machine")
$chef_path = "C:\opscode\chefdk\bin"
if (([System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")) -like "*chefdk\bin*"){
    Write-Host "env:Path Chef DK already exists!" -ForegroundColor Green
} else {
    [Environment]::SetEnvironmentVariable("PATH", "$path;$chef_path", "Machine")
}

#######################################
### Chef DK Embeded Extras env Path ###
#######################################
$path = [Environment]::GetEnvironmentVariable("PATH", "Machine")
$chefemb_path = "C:\opscode\chefdk\embedded\bin"
if (([System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")) -like "*chefdk\embedded\bin*"){
    Write-Host "env:Path Chef DK Embeded extras already exists!" -ForegroundColor Green
} 
else {
    [Environment]::SetEnvironmentVariable("PATH", "$path;$chefemb_path", "Machine")
}

#####################
### Ruby Env Path ###
#####################
$path = [Environment]::GetEnvironmentVariable("PATH", "Machine")
$ruby_path = "$env:USERPROFILE\appdata\local\chefdk\gem\ruby\2.1.0\bin"
if (([System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")) -like "*ruby\2.1.0\bin*"){
    Write-Host "env:Path Ruby already exists!" -ForegroundColor Green
}
else{
    [Environment]::SetEnvironmentVariable("PATH", "$path;$ruby_path", "Machine")
}

#################
### Chef Gems ###
#################
chef gem install 'knife-vsphere'
chef gem install 'test-kitchen'
chef gem install 'kitchen-vagrant'
chef gem install 'knife-windows'
chef gem install 'winrm'
chef gem install 'winrm-fs'
chef gem install 'winrm-elevated'

###############
### Vagrant ###
###############
if ((Test-Path C:\HashiCorp\Vagrant) -eq $true){ 
    Write-Host "Vagrant is present on your system" -ForegroundColor Green
} 
else { 
    just-install vagrant
}
########################
### Vagrant Env Path ###
########################
$path = [Environment]::GetEnvironmentVariable("PATH", "Machine")
$vagrant_path = "C:\HashiCorp\Vagrant\bin"
if (([System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")) -like "*Vagrant\bin*"){
    Write-Host "env:Path Vagrant already exists!" -ForegroundColor Green
}
else {
    [Environment]::SetEnvironmentVariable("PATH", "$path;$vagrant_path", "Machine")
}

#################
### Reload PS ###
#################
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

#######################
### Vagrant Plugins ###
#######################
vagrant plugin install 'vagrant-berkshelf'
vagrant plugin install 'vagrant-dsc'
vagrant plugin install 'vagrant-omnibus'
vagrant plugin install 'vagrant-reload'
vagrant plugin install 'vagrant-vbguest'
vagrant plugin install 'vagrant-vbox-snapshot'
vagrant plugin install 'vagrant-winrm'
vagrant plugin install 'winrm-fs'

#############################
### Install vagrant boxes ###
#############################
vagrant box add mwrock/Windows2016

#############
### Final ###
#############
Write-Host "Restart Your Computer!" -ForegroundColor Red