#===========================================================================
# Name:
#		GUIDeployVMFromTemplate.ps1
#
# Description:
#		Script to deploy ST and MG VMs from template.
#
# Author:
#		Stiliyan Tihomirov Stefanov, stihomirov@axway.com
# 
# Technologies used:
#		.NET (XAML to be exact) for the GUI
#		PowerShell for the Backend
#		PowerCLI for integration with VMWare
#
# Requirements:
#		.NET Framework - the latest available, should be installed already
#		PowerShell - the latest available, should be installed already 
#		PowerCLI 6.5 - Available under http://10.232.10.2/install/vmware/VMWare.PowerCLI.v6.5.0-4624819/VMware-PowerCLI-6.5.0-4624819.exe
#		PowerShell policy to execute local scripts: Open PowerShell as Administrator and run "Set-ExecutionPolicy RemoteSigned"
#
# Resources Used:
#		PowerCLI Reference: https://www.vmware.com/support/developer/PowerCLI/PowerCLI65R1/html/index.html
#		PowerShell Cheat Sheet: http://www.dummies.com/programming/net/windows-powershell-2-for-dummies-cheat-sheet/
#		VMWare Community Script: https://communities.vmware.com/thread/427006?tstart=0
#		PowerCLI Script – Deploy VMs and Configure the Guest OS: http://www.altaro.com/vmware/powercli-script-deploy-vms-and-configure-the-guest-os/
#		Learning GUI Toolmaking Series: https://foxdeploy.com/resources/learning-gui-toolmaking-series/
#		PowerCLI Script to Collect Datastore Usage Report: http://www.vmwarearena.com/powershell-script-to-collect-datastore/
#
# Special Thanks To:
#		Momchil Nikolov, mnikolov@axway.com for creating all ST Templates
#		Andreja Nikolovska-Petkova, anikolovska@axway.com for creating all MG Templates
#		Danail Ivanov, divanov@axway.com for committing the LogMaster changes
#
# Version History
#		1.33 - Updated the list of SecureTransport, MailGate supported versions and support engineer personal folders (June 2016)
#		1.32 - Updated the list of SecureTransport, MailGate supported versions and support engineer personal folders
#		1.31 - Updated the list of LogMaster supported versions
#		1.30 - Added Support for LogMaster
#		1.20 - Rebranding and Refactoring for easier customization
#		1.10 - Added "Free Space" button to print the available free space on the largest datastore for each VMWare host.
#		1.00 - Initial Release
#===========================================================================

#===========================================================================
# GUI XAML
#===========================================================================

# This is generated using VisualStudio with WPF project. Only the XAML is used from that project.
$inputXML = @"
<Window x:Class="vmimages.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:vmimages"
        mc:Ignorable="d"
        Title="TemplateZilla-Sako" Height="479.919" Width="704.406" ResizeMode="NoResize">
    <Grid Margin="0,0,2,0">
        <GroupBox x:Name="groupBoxESXLogin" Header="VM Details" HorizontalAlignment="Left" Margin="10,10,0,0" VerticalAlignment="Top" Height="128" Width="251" Panel.ZIndex="-300"/>
        <Label x:Name="labelvSphereCluster" Content="Host/Cluster:" HorizontalAlignment="Left" Margin="21,40,0,0" VerticalAlignment="Top" Width="94"/>
        <Label x:Name="labelESXUsername" Content="Username:" HorizontalAlignment="Left" Margin="275,167,0,0" VerticalAlignment="Top" Width="94"/>
        <Label x:Name="labelESXPassword" Content="Password:" HorizontalAlignment="Left" Margin="459,167,0,0" VerticalAlignment="Top" RenderTransformOrigin="0.515,-0.245" Width="94"/>
        <ComboBox x:Name="comboBoxvSphereCluster" HorizontalAlignment="Left" Margin="120,44,0,0" VerticalAlignment="Top" Width="120" TabIndex="0"/>
        <TextBox x:Name="textBoxUsername" HorizontalAlignment="Left" Height="23" Margin="356,170,0,0" VerticalAlignment="Top" Width="100" TabIndex="13" Text=""/>
        <GroupBox x:Name="groupBoxTemplateSelection" Header="Template Selection" HorizontalAlignment="Left" Margin="10,143,0,0" VerticalAlignment="Top" Height="141" Width="251" Panel.ZIndex="-300"/>
        <PasswordBox x:Name="passwordBoxPassword" HorizontalAlignment="Left" Margin="558,170,0,0" VerticalAlignment="Top" Width="100" Height="23" TabIndex="14" Password=""/>
        <Label x:Name="labelOS" Content="OS:" HorizontalAlignment="Left" Margin="21,193,0,0" VerticalAlignment="Top" Width="76"/>
        <Label x:Name="labelProduct" Content="Product:" HorizontalAlignment="Left" Margin="21,167,0,0" VerticalAlignment="Top" Width="76"/>
        <Label x:Name="labelVersion" Content="Version:" HorizontalAlignment="Left" Margin="21,219,0,0" VerticalAlignment="Top" Width="66"/>
        <ComboBox x:Name="comboBoxOS" HorizontalAlignment="Left" Margin="120,194,0,0" VerticalAlignment="Top" Width="120" TabIndex="4"/>
        <ComboBox x:Name="comboBoxProduct" HorizontalAlignment="Left" Margin="120,167,0,0" VerticalAlignment="Top" Width="120" TabIndex="3"/>
        <ComboBox x:Name="comboBoxVersion" HorizontalAlignment="Left" Margin="120,221,0,0" VerticalAlignment="Top" Width="120" TabIndex="5"/>
        <CheckBox x:Name="checkBoxEdge" Content="Edge (ST on Windows Server Only)" HorizontalAlignment="Left" Margin="21,256,0,0" VerticalAlignment="Top" TabIndex="6" IsEnabled="False"/>
        <GroupBox x:Name="groupBoxNetwork" Header="VM Network" Margin="266,10,10,0" VerticalAlignment="Top" Height="128" Panel.ZIndex="-300"/>
        <Label x:Name="labelIP" Content="IP Address:" HorizontalAlignment="Left" Margin="275,40,0,0" VerticalAlignment="Top"/>
        <Label x:Name="labelGateway" Content="Gateway:" HorizontalAlignment="Left" Margin="275,67,0,0" VerticalAlignment="Top"/>
        <Label x:Name="labelNetmask" Content="Netmask:" HorizontalAlignment="Left" Margin="459,40,0,0" VerticalAlignment="Top"/>
        <Label x:Name="labelHostname" Content="Hostname:" HorizontalAlignment="Left" Margin="459,67,0,0" VerticalAlignment="Top"/>
        <Label x:Name="labelDNS1" Content="DNS Primary:" HorizontalAlignment="Left" Margin="275,95,0,0" VerticalAlignment="Top"/>
        <Label x:Name="labelDNS2" Content="DNS Seconday:" HorizontalAlignment="Left" Margin="459,95,0,0" VerticalAlignment="Top"/>
        <GroupBox x:Name="groupBoxLicenses" Header="File Transfer (ST Only)" HorizontalAlignment="Left" Margin="10,289,0,0" Width="251" Height="112" VerticalAlignment="Top" Panel.ZIndex="-300"/>
        <Button x:Name="buttonDeploy" Content="Deploy" Margin="0,0,10,10" Height="20" VerticalAlignment="Bottom" HorizontalAlignment="Right" Width="75" TabIndex="19"/>
        <Button x:Name="buttonLicense1" Content="Browse" HorizontalAlignment="Left" Margin="165,313,0,0" VerticalAlignment="Top" Width="75" TabIndex="15" IsEnabled="False"/>
        <Button x:Name="buttonLicense2" Content="Browse" HorizontalAlignment="Left" Margin="165,338,0,0" VerticalAlignment="Top" Width="75" TabIndex="16" IsEnabled="False"/>
        <GroupBox x:Name="groupBoxLog" Header="Log" Margin="266,213,10,0" VerticalAlignment="Top" Height="188" Panel.ZIndex="-300"/>
        <TextBox x:Name="textBoxLog" HorizontalAlignment="Left" Margin="275,232,0,0" VerticalAlignment="Top" Height="156" Width="383" BorderThickness="0" VerticalScrollBarVisibility="Visible" ScrollViewer.CanContentScroll="True" IsReadOnly="True"/>
        <TextBox x:Name="textBoxIP" HorizontalAlignment="Left" Height="23" Margin="356,44,0,0" VerticalAlignment="Top" Width="100" TabIndex="7"/>
        <TextBox x:Name="textBoxGateway" Text="10.232.10.1" HorizontalAlignment="Left" Height="23" Margin="356,71,0,0" VerticalAlignment="Top" Width="100" TabIndex="9"/>
        <TextBox x:Name="textBoxDNS1" Text="10.232.10.3" HorizontalAlignment="Left" Height="23" Margin="356,99,0,0" VerticalAlignment="Top" Width="100" TabIndex="11"/>
        <Button x:Name="buttonHelp" Content="Help" HorizontalAlignment="Left" Margin="10,0,0,10" Width="75" Height="20" VerticalAlignment="Bottom" TabIndex="18" IsEnabled="True"/>
        <TextBox x:Name="textBoxNetmask" Text="255.255.254.0" HorizontalAlignment="Left" Height="23" Margin="558,44,0,0" VerticalAlignment="Top" Width="100" TabIndex="8"/>
        <TextBox x:Name="textBoxHostname" HorizontalAlignment="Left" Height="23" Margin="558,71,0,0" VerticalAlignment="Top" Width="100" TabIndex="10"/>
        <TextBox x:Name="textBoxDNS2" Text="10.232.10.2" HorizontalAlignment="Left" Height="23" Margin="558,99,0,0" VerticalAlignment="Top" Width="100" TabIndex="12"/>
        <GroupBox x:Name="groupBoxVM" Header="ESX Login" Margin="266,143,10,0" VerticalAlignment="Top" Height="65" Panel.ZIndex="-300"/>
        <Label x:Name="labelVMName" Content="VM Name:" HorizontalAlignment="Left" Margin="21,67,0,0" VerticalAlignment="Top" Width="80"/>
        <TextBox x:Name="textBoxName" HorizontalAlignment="Left" Height="23" Margin="120,71,0,0" VerticalAlignment="Top" Width="120" TabIndex="1"/>
        <Label x:Name="labelVMFolder" Content="Folder:" HorizontalAlignment="Left" Margin="21,95,0,0" VerticalAlignment="Top" Width="91"/>
        <ComboBox x:Name="comboBoxVMFolder" HorizontalAlignment="Left" Margin="120,100,0,0" VerticalAlignment="Top" Width="120" TabIndex="2"/>
        <TextBox x:Name="textBoxLicense1" HorizontalAlignment="Left" Height="23" Margin="21,314,0,0" Text="Core License" VerticalAlignment="Top" Width="130" BorderThickness="0" IsReadOnly="True" IsEnabled="False"/>
        <TextBox x:Name="textBoxLicense2" HorizontalAlignment="Left" Height="23" Margin="21,339,0,0" Text="Features License" VerticalAlignment="Top" Width="130" BorderThickness="0" IsReadOnly="True" IsEnabled="False"/>
        <Button x:Name="buttonOtherFile" Content="Browse" HorizontalAlignment="Left" Margin="165,365,0,0" VerticalAlignment="Top" Width="75" IsEnabled="False" TabIndex="17"/>
        <TextBox x:Name="textBoxOtherFile" HorizontalAlignment="Left" Height="23" Margin="21,366,0,0" Text="Other File" VerticalAlignment="Top" Width="130" IsEnabled="False" IsReadOnly="True" BorderThickness="0"/>
        <Label x:Name="labelVer" Content="" HorizontalAlignment="Left" Margin="275,406,0,0" Width="311" IsEnabled="False" HorizontalContentAlignment="Right" Panel.ZIndex="20" Height="28" VerticalAlignment="Top"/>
        <Button x:Name="buttonFreeSpace" Content="Free Space" HorizontalAlignment="Left" Margin="90,0,0,10" Width="75" Height="20" VerticalAlignment="Bottom" IsEnabled="True"/>
    </Grid>
</Window>
"@

#===========================================================================
# .NET MOJO
#===========================================================================

# Sanitizing some markup left from VisualStudio. This is some shady black magic, but it works.
$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N'  -replace '^<Win.*', '<Window'
 
# Load WPF .NET Assembly to show the script GUI.
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML

# Parsing the XAML
$reader=(New-Object System.Xml.XmlNodeReader $xaml)
  try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
catch{Write-Host "Unable to load the GUI. Try reinstalling the latest version of .NET Framework."}

# Load assembly required for loading dialog to browse files
[void][System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")

# This allows the script to use the content of the GUI elements in the script
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name)}

Function Get-FormVariables{
if ($global:ReadmeDisplay -ne $true){Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true}
write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
get-variable WPF*
}

# Uncomment this line to print the GUI element variables and their value to the console for debug purposes
#Get-FormVariables


#===========================================================================
# Predefined variables
#===========================================================================

$ESXHost = "labvcenter.ptx.axway.int";
$VMDefaultDomain = "support.lab.sofi.axway.int";
$VMAdmin = "Administrator"
$VMRoot = "root"
$VMPass = "axway"
$VMOrg = "Axway"
$VMWorkGroup = "WORKGROUP"
$STServerPath = "/opt/server/SecureTransport/conf/"
$STEdgePath = "/opt/edge/SecureTransport/conf/"
$STOtherFilePath = "/root/"
$STWindowsPath = "C:\Axway\SecureTransport\STServer\conf\"
$STOtherWindowsPath = "C:\Axway\"
$STCoreLicenseFilename = "filedrive.license"
$STFeaturesLicenseFilename = "st.license"
$Timeout = 900
$VersionString = "Version 1.33 - June 2018"

# List of ESX Server Hostnames
$vSphereClusters = New-Object System.Collections.ArrayList;
$vSphereClusters.AddRange(("mandor.gss.lab.sofi.axway.int","unicorn.gss.lab.sofi.axway.int","corwin.gss.lab.sofi.axway.int","kolvir.gss.lab.sofi.axway.int","fiona.gss.lab.sofi.axway.int","finndo.gss.lab.sofi.axway.int"));

# List of SecureTransport supported versions. Use string that follows the naming convention of the templates.
$STVersionsArray = New-Object System.Collections.ArrayList;
$STVersionsArray.AddRange(("521","521_SP1","521_SP2","521_SP3","521_SP4","521_SP5","521_SP6","521_SP7","521_SP8","521_SP9","530","531","533","533_P6","536","540"));

# List of SecureTransport supported OSes. Use string that follows the naming convention of the templates.
$STOSArray = New-Object System.Collections.ArrayList;
$STOSArray.AddRange(("Appliance Platform","WIN2K8","WIN2K12","RHEL59","RHEL62","RHEL72"));

# List of MailGate supported versions. Use string that follows the naming convention of the templates.
$MGVersionsArray = New-Object System.Collections.ArrayList;
$MGVersionsArray.AddRange(("530","531","540","541","550","551","552","553","554"));

# List of MailGate supported OSes. Use string that follows the naming convention of the templates.
$MGOSArray = New-Object System.Collections.ArrayList;
$MGOSArray.Add(("Appliance Platform")) > $null;
# $MGOSArray has single value now, so the Add method is used. If new values are to be added, the line should be replaced with the one below:
# $MGOSArray.AddRange(("Appliance Platform",""));

# List of LogMaster supported versions. Use string that follows the naming convention of the templates.
$LMVersionsArray = New-Object System.Collections.ArrayList;
$LMVersionsArray.Add(("110")) > $null;
# $LMVersionsArray has single value now, so the Add method is used. If new values are to be added, the line should be replaced with the one below:
# $LMVersionsArray.AddRange(("100",""));

# List of LogMaster supported OSes. Use string that follows the naming convention of the templates.
$LMOSArray = New-Object System.Collections.ArrayList;
$LMOSArray.Add(("CENTOS7")) > $null;
# $LMOSArray has single value now, so the Add method is used. If new values are to be added, the line should be replaced with the one below:
# $LMOSArray.AddRange(("CENTOS7",""));

# List of products to deploy VMs for
$ProductsArray = New-Object System.Collections.ArrayList;
$ProductsArray.AddRange(("SecureTransport","MailGate","LogMaster"));

# List of Support Engineers and their folder names
$EngineersArray = New-Object System.Collections.ArrayList;
$EngineersArray.AddRange(("Adriana","Alex","AlexO","Chavdar","Delyan","Denitsa","Dimitar","GeorgiR","Guido","IvanT","IvanM","Ivaylo","Miglena","MiroM","Nikola","PavelB","PeterS","Plamen","Rado","Rosen","RosenK","Spas","Stanislav","Svetlin","Tanya","VasilM","VasilP","VasilY","ZP","Andreja","Bobby","Dinko","Evgeni","Joro","Lyusi","Momchil","Stylius","Velin","Vlado","Volen","Dani","Kosta","Yasho"));

$WPFcomboBoxProduct.ItemsSource = $ProductsArray;
$WPFcomboBoxVMFolder.ItemsSource = $EngineersArray;
$WPFcomboBoxvSphereCluster.ItemsSource = $vSphereClusters;
$WPFLabelVer.content = $VersionString;

#===========================================================================
# Functions
#===========================================================================

# Function to check whether the mandatory fields are filled up. 4 flags are returned whether: the deployment can continue, the network should be customized, whether Licenses should be uploaded and whether another file should be uploaded.
Function Check-FormFilled
{
	$ShallWeProceed = $true;
	$CustomizeNetwork = $true;
	$CustomizeLicenses = $false;
	$OtherFile = $false;
	
	# Checking if all Network settings are filled. If even one box is empty, skip the Network Customization.
	If (($WPFtextBoxIP.Text -eq "") -or ($WPFtextBoxNetmask.Text -eq "") -or ($WPFtextBoxGateway.Text -eq "") -or ($WPFtextBoxHostname.Text -eq "") -or ($WPFtextBoxDNS1.Text -eq ""))
	{
		# Checking if product is MailGate and the network details are missing. Network customization is mandatory for MailGate.
		If (($WPFcomboBoxProduct.SelectedItem -eq "MailGate"))
		{
			$WPFTextBoxLog.AppendText("FATAL: Missing Network Details mandatory for MailGate!`n");
			$ShallWeProceed = $false;
			# Since the error is fatal we stop processing further
			Return $ShallWeProceed,$false,$false,$false
		}
		ElseIf (($WPFcomboBoxProduct.SelectedItem -eq "LogMaster"))
		{
			$WPFTextBoxLog.AppendText("FATAL: Missing Network Details mandatory for LogMaster!`n");
			$ShallWeProceed = $false;
			# Since the error is fatal we stop processing further
			Return $ShallWeProceed,$false,$false,$false
		}
		Else
		{
			# There are missing Network Configuration parameters, but it is OK. The selected product allows optional network.
			$WPFTextBoxLog.AppendText("WARN: Missing Network Details. Proceeding without Network Customization!`n");
			$ShallWeProceed = $true;
			$CustomizeNetwork = $false;
		}
	}
	# Checking whether the IP, Gateway, Netmask and DNS values invalid using Regex. If so, disable Network Customization.
	ElseIf (($WPFtextBoxIP.Text -notmatch "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$") -or ($WPFtextBoxNetmask.Text -notmatch "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$") -or ($WPFtextBoxGateway.Text -notmatch "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$") -or ($WPFtextBoxDNS1.Text -notmatch "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"))
	{
		$WPFTextBoxLog.AppendText("WARN: Incorrect Network Details. Proceeding without Network Customization!`n");
		$ShallWeProceed = $true;
		$CustomizeNetwork = $false;
	}
	# Checking if the hostname does not follow RFC952 and disable Network Customization.
	ElseIf (($WPFtextBoxHostname.Text -notmatch "^(([a-zA-Z]|[a-zA-Z][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z]|[A-Za-z][A-Za-z0-9\-]*[A-Za-z0-9])$"))
	{
		$WPFTextBoxLog.AppendText("WARN: Incorrect Hostname. Proceeding without Network Customization!`n");
		$ShallWeProceed = $true;
		$CustomizeNetwork = $false;
	}
	
	# Checking if secondary DNS If the secondary DNS is not valid, make it empty, so network customization would work with just one DNS
	If (($WPFtextBoxDNS2.Text -notmatch "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"))
	{
		$WPFtextBoxDNS2.Text = "";
	}
	
	# Checking the ESX Login form. We need host, user and pass. Those fields are mandatory.
	If (($WPFtextBoxUsername.Text -eq "") -or ($WPFpasswordBoxPassword.Password -eq ""))
	{
		$WPFTextBoxLog.AppendText("FATAL: Missing ESX Login details. Aborting!`n");
		$ShallWeProceed = $false;
		# Since the error is fatal we stop processing further
		Return $ShallWeProceed,$false,$false,$false
	}
	
	# Checking for new VM name and folder. The script needs to know where to put the new VM. Those fields are mandatory
	If (($WPFcomboBoxVMFolder.SelectedItem -eq $Null) -or ($WPFtextBoxName.Text -eq ""))
	{
		$WPFTextBoxLog.AppendText("FATAL: Missing VM Name or Folder. Aborting!`n`n");
		$ShallWeProceed = $false;
		# Since the error is fatal we stop processing further
		Return $ShallWeProceed,$false,$false,$false
	}
	
	# Checking the Template values. To be used to construct the template name to use. Those fields are mandatory.
	If (($WPFcomboBoxProduct.SelectedItem -eq $Null) -or ($WPFcomboBoxOS.SelectedItem -eq $Null) -or ($WPFcomboBoxVersion.SelectedItem -eq $Null))
	{
		$WPFTextBoxLog.AppendText("FATAL: Missing Template Selection. Aborting!`n`n");
		$ShallWeProceed = $false;
		# Since the error is fatal we stop processing further
		Return $ShallWeProceed,$false,$false,$false
	}
	
	# Checking license files are selected, otherwise proceed without license customization.
	If ((($WPFtextBoxLicense1.Text -ne "Core License") -And (Test-Path $WPFtextBoxLicense1.Text)) -And (($WPFtextBoxLicense2.Text -ne "Features License") -And (Test-Path $WPFtextBoxLicense2.Text)))
	{
		$WPFTextBoxLog.AppendText("INFO: License Files selected!`n");
		$CustomizeLicenses = $true;
	}
	Else
	{
		$WPFTextBoxLog.AppendText("WARN: Invalid or missing license files. Proceeding without License Customization!`n");
		$CustomizeLicenses = $false;
	}
	
	# Checking if other file is selected to be copied to the new VM.
	If (($WPFtextBoxOtherFile.Text -ne "Other File") -And (Test-Path $WPFtextBoxOtherFile.Text))
	{
		$WPFTextBoxLog.AppendText("INFO: Additional file selected apart from licenses!`n");
		$OtherFile = $true;
	}
	
	# Returning the flags
	Return $ShallWeProceed,$CustomizeNetwork,$CustomizeLicenses,$OtherFile;
}

# Function to construct the template name to be used based on the selected product, version and OS.
Function Create-TemplateName 
{
	$TemplateConstructedName="";
	If (($WPFcomboBoxOS.SelectedItem -eq "Appliance Platform")) 
	{
		# Given the variety of AP versions, we use a wildcard here. Thankfully powercli is intelligent enough to pich the right one.
		$TemplateConstructedName=$TemplateConstructedName + "AP*_";
	}
	Else
	{
		# Otherwise we get the name from the drop down list.
		$TemplateConstructedName=$TemplateConstructedName + $WPFcomboBoxOS.SelectedItem + "_";
	}

	# Adding the product prefix to the template name string
	If (($WPFcomboBoxProduct.SelectedItem -eq "SecureTransport")) 
	{
		$TemplateConstructedName=$TemplateConstructedName + "ST";
	}
	ElseIf (($WPFcomboBoxProduct.SelectedItem -eq "MailGate"))
	{
		$TemplateConstructedName=$TemplateConstructedName + "MG";
	}
	ElseIf (($WPFcomboBoxProduct.SelectedItem -eq "LogMaster"))
	{
		$TemplateConstructedName=$TemplateConstructedName + "LM";
	}
	
	# Adding the version to the template name string
	$TemplateConstructedName=$TemplateConstructedName + $WPFcomboBoxVersion.SelectedItem;
	
	# Given that only one SecureTransport instance can be installed on Windows Server, we add _E to deploy from template with ST Edge installed.
	# Linux templates have both ST Core and ST Edge installed, so no separate template is necessary.
	If (($WPFcomboBoxOS.SelectedItem -like "WIN*") -And ($WPFcheckBoxEdge.IsChecked -eq $true))
	{
		$TemplateConstructedName=$TemplateConstructedName + "_E";
	}
	
	# Returning the constructed template name.
	return $TemplateConstructedName;
}

# Function to try connecting to ESX and checking for errors
Function Check-VMConnection
{
	# Load all powercli modules, as they are not loaded in PowerShell by default
	Get-Module -ListAvailable VMware* | Import-Module | Out-Null
	
	# Trying to connect to ESX
	$VSphereConnection=Connect-VIServer $ESXHost -User $WPFtextBoxUsername.Text -Password $WPFpasswordBoxPassword.Password -WarningAction Silently
	
	# Checking for successful connection.
	If (($VSphereConnection.IsConnected))
	{
		$WPFTextBoxLog.AppendText("INFO: Connection to ESX successful!`n");
		Return $true
	}
	Else
	{
		# Most commonly the connection would fail due to incorrect credentials.
		$WPFTextBoxLog.AppendText("ERROR: FAILED connection to ESX. Please check the Login Details!`n");
		
		# Re-enable the Deploy button
		$WPFbuttonDeploy.IsEnabled=$true;
		Return $false
	}
}

# Function to check whether the constructed Template name exists on the ESX server.
Function Check-VMTemplateExists
{
	# Trying to get details about template with the constructed name.
	$TemplateExists=Get-Template -Name "$TemplateConstructedName"
	
	If (($TemplateExists -ne $null))
	{
		# We get the template, so it exists. Hurray!
		$WPFTextBoxLog.AppendText("INFO: Template exists, proceeding!`n");
		Return $true
	}
	Else
	{
		# There is no template with the constructed name. Most commonly this is due to unsupported combination of product version and OS.
		# For example there is no template for ST 5.3.3 on Windows Server 2008 R2.
		$WPFTextBoxLog.AppendText("ERROR: No such template on the ESX Server. Please check if the Product Version and OS combo is supported!`n");
		Finalize-VMDeployment
		Return $false
	}
}

# Function to create OS Customization details
Function Create-OSCustomizationDetails
{
	# Setting hostname to be the same as the template from which the VM was deployed, with special characters stripped. For example: APST521SP4
	# This is only used if the Network configuration is skipped when deploying ST VMs.
	$HostNamePrefix = $TemplateConstructedName;
	$HostNamePrefix = $HostNamePrefix -replace "\W", ""
	$HostNamePrefix = $HostNamePrefix -replace "_", ""

	# Get the hostname and domain values in case FQDN is specified. Otherwise use the defailt domain.
	$hostnameFromFQDN = $WPFtextBoxHostname.Text;
	$hostnameFromFQDN = $hostnameFromFQDN.Split('.')[0];
	$VMDomain = $WPFtextBoxHostname.Text; 
	$VMDomain = $VMDomain -replace "$hostnameFromFQDN.","";
	If (($VMDomain -eq $hostnameFromFQDN))
	{
		$VMDomain = $VMDefaultDomain;
	}
	
	If (($WPFcomboBoxOS.SelectedItem -like "WIN*"))
	{
		# The follwoning part checks for the customize network flag and prepares the VM for custom network details.
		# Due to a bug in Windows Server 2012 or VMWare, customizing the network on WIN2K12 guests takes about 10 minutes. Win2k8 is much, much faster.
		# If the customize network flag is set to $false, no network would be configured and the server would look for DHCP details
		If  (($CustomizeNetwork -eq $true) -And ($WPFtextBoxDNS2.Text -ne ""))
		{
			# Windows OS Customization. This is necessary as it runs "sysprep" on the server an it resets the trial period. Windows Server templates are NOT activated. Customization with 2 DNS
			New-OSCustomizationSpec -Name OSCustomSpec -Type NonPersistent -OSType Windows -NamingScheme Fixed -NamingPrefix $hostnameFromFQDN -Workgroup $VMWorkGroup -FullName $VMAdmin -OrgName $VMOrg -ChangeSid:$true -AdminPassword $VMPass
			Get-OSCustomizationSpec OSCustomSpec | Get-OSCustomizationNicMapping | Set-OSCustomizationNicMapping -IpMode UseStaticIP -IPAddress $WPFtextBoxIP.Text -SubnetMask $WPFtextBoxNetmask.Text -DefaultGateway $WPFtextBoxGateway.Text -DNS $WPFtextBoxDNS1.Text,$WPFtextBoxDNS2.Text
			#$WPFTextBoxLog.AppendText("DEBUG: Windows - Yes, Network - Yes, Secondary DNS - Yes!`n");
			#$WPFTextBoxLog.AppendText("DEBUG: Hostname: $($hostnameFromFQDN)!`n");
			#$WPFTextBoxLog.AppendText("DEBUG: No Domain!`n");
		}
		ElseIf (($CustomizeNetwork -eq $true) -And ($WPFtextBoxDNS2.Text -eq ""))
		{
			# Windows OS Customization. This is necessary as it runs "sysprep" on the server an it resets the trial period. Windows Server templates are NOT activated. Customization with 1 DNS
			New-OSCustomizationSpec -Name OSCustomSpec -Type NonPersistent -OSType Windows -NamingScheme Fixed -NamingPrefix $hostnameFromFQDN -Workgroup $VMWorkGroup -FullName $VMAdmin -OrgName $VMOrg -ChangeSid:$true -AdminPassword $VMPass
			Get-OSCustomizationSpec OSCustomSpec | Get-OSCustomizationNicMapping | Set-OSCustomizationNicMapping -IpMode UseStaticIP -IPAddress $WPFtextBoxIP.Text -SubnetMask $WPFtextBoxNetmask.Text -DefaultGateway $WPFtextBoxGateway.Text -DNS $WPFtextBoxDNS1.Text
			#$WPFTextBoxLog.AppendText("DEBUG: Windows - Yes, Network - Yes, Secondary DNS - No!`n");
			#$WPFTextBoxLog.AppendText("DEBUG: Hostname: $($hostnameFromFQDN)!`n");
			#$WPFTextBoxLog.AppendText("DEBUG: No Domain!`n");
		}
		Else 
		{
			# Windows OS Customization. This is necessary as it runs "sysprep" on the server an it resets the trial period. Windows Server templates are NOT activated
			
			$WPFTextBoxLog.AppendText("INFO: No network details, using $($HostNamePrefix) for hostname!`n");
			New-OSCustomizationSpec -Name OSCustomSpec -Type NonPersistent -OSType Windows -NamingScheme Fixed -NamingPrefix $HostNamePrefix -Workgroup $VMWorkGroup -FullName $VMAdmin -OrgName $VMOrg -ChangeSid:$true -AdminPassword $VMPass
			#$WPFTextBoxLog.AppendText("DEBUG: Windows - Yes, Network - No, Secondary DNS - No!`n");
			#$WPFTextBoxLog.AppendText("DEBUG: Hostname: $($HostNamePrefix)!`n");
			#$WPFTextBoxLog.AppendText("DEBUG: No Domain!`n");
		}
	}
	Else
	{
		# Linux OS Customization, including Axway Appliances
		# If the customize network flag is set to $false, no network would be configured and the server would look for DHCP details
		If  (($CustomizeNetwork -eq $true) -And ($WPFtextBoxDNS2.Text -ne ""))
		{
			# Using network customization and both DNS fields are filled. Creating customization with 2 DNS entries.
			New-OSCustomizationSpec -Name OSCustomSpec -Type "NonPersistent" -Domain $VMDomain -OSType Linux -DnsServer $WPFtextBoxDNS1.Text,$WPFtextBoxDNS2.Text -NamingScheme Fixed -NamingPrefix $hostnameFromFQDN
			Get-OSCustomizationSpec OSCustomSpec | Get-OSCustomizationNicMapping | Set-OSCustomizationNicMapping -IpMode UseStaticIP -IPAddress $WPFtextBoxIP.Text -SubnetMask $WPFtextBoxNetmask.Text -DefaultGateway $WPFtextBoxGateway.Text
			#$WPFTextBoxLog.AppendText("DEBUG: Windows - No, Network - Yes, Secondary DNS - Yes!`n");
			#$WPFTextBoxLog.AppendText("DEBUG: Hostname: $($hostnameFromFQDN)!`n");
			#$WPFTextBoxLog.AppendText("DEBUG: Domain: $($VMDomain)!`n");
		}
		ElseIf (($CustomizeNetwork -eq $true) -And ($WPFtextBoxDNS2.Text -eq ""))
		{
			# Using network customization but only Primary DNS is filled. Creating customization with 1 DNS entry.
			New-OSCustomizationSpec -Name OSCustomSpec -Type "NonPersistent" -Domain $VMDomain -OSType Linux -DnsServer $WPFtextBoxDNS1.Text -NamingScheme Fixed -NamingPrefix $hostnameFromFQDN
			Get-OSCustomizationSpec OSCustomSpec | Get-OSCustomizationNicMapping | Set-OSCustomizationNicMapping -IpMode UseStaticIP -IPAddress $WPFtextBoxIP.Text -SubnetMask $WPFtextBoxNetmask.Text -DefaultGateway $WPFtextBoxGateway.Text
			#$WPFTextBoxLog.AppendText("DEBUG: Windows - No, Network - Yes, Secondary DNS - No!`n");
			#$WPFTextBoxLog.AppendText("DEBUG: Hostname: $($hostnameFromFQDN)!`n");
			#$WPFTextBoxLog.AppendText("DEBUG: Domain: $($VMDomain)!`n");
		}
		Else
		{
			# Not using network customization. Since DNS is mandatory, using 10.232.10.3
			$WPFTextBoxLog.AppendText("INFO: No network details, using $($HostNamePrefix) for hostname!`n");
			New-OSCustomizationSpec -Name OSCustomSpec -Type "NonPersistent" -Domain $VMDomain -OSType Linux -DnsServer "10.232.10.3" -NamingScheme Fixed -NamingPrefix $HostNamePrefix
			#$WPFTextBoxLog.AppendText("DEBUG: Windows - No, Network - No, Secondary DNS - No!`n");
			#$WPFTextBoxLog.AppendText("DEBUG: Hostname: $($HostNamePrefix)!`n");
			#$WPFTextBoxLog.AppendText("DEBUG: Domain: $($VMDomain)!`n");
		}
	}
}

# Function to verify that the OS Customization Specification was successfully created
Function Verify-OSCustomizationDetails
{
	# Probing the ESX for customization with that name
	$spec = Get-OSCustomizationSpec OSCustomSpec
	If (($spec -eq $null))
	{
		# No such specification.
		$WPFTextBoxLog.AppendText("ERROR: Failed to create OS Customization Specification!`n");
		Finalize-VMDeployment
		return $false
	}
	Else
	{
		# We are all good.
		$WPFTextBoxLog.AppendText("INFO: Successfully created OS Customization Specification!`n");
		return $true
	}
}

# Function to deploy VM from template.
Function Create-VMFromTemplate
{
	$NewVMDatastore = Get-LargestDatastoreForHost $WPFcomboBoxvSphereCluster.Text
	$WPFTextBoxLog.AppendText("INFO: Cloning VM from Template!`n");
	New-VM -Name $WPFtextBoxName.Text -Location $WPFcomboBoxVMFolder.SelectedItem -Template $TemplateConstructedName -ResourcePool $WPFcomboBoxvSphereCluster.Text -Datastore $NewVMDatastore -OSCustomizationSpec OSCustomSpec -RunAsync:$false
}

# Function to power on the VM once it is deployed
Function Start-GuestVM
{
	$WPFTextBoxLog.AppendText("INFO: Starting VM!`n");
	
	# Now query the VMWare for our new machine and power it on.
	Get-VM $Guest | Start-VM
}

# Function to wait for the OS customization to complete.
Function Wait-ForOSCustomizationComplete
{
	$CustomizationTimeout = $Timeout
	
	$WPFTextBoxLog.AppendText("INFO: Customization of VM $($VMname) Started.`n");
    while($True)
    {
        $DCvmEvents = Get-VIEvent -Entity $Guest
        $DCSucceededEvent = $DCvmEvents | Where { $_.GetType().Name -eq "CustomizationSucceeded" }
        $DCFailureEvent = $DCvmEvents | Where { $_.GetType().Name -eq "CustomizationFailed" }
        If (($DCFailureEvent))
        {
            $WPFTextBoxLog.AppendText("ERROR: Customization of VM $($VMname) failed.`n");
            return $False;
        }
        If (($DCSucceededEvent))
        {
			$WPFTextBoxLog.AppendText("INFO: Customization of VM $($VMname) Successful.`n");
            return $True;
        }
		
		If (($CustomizationTimeout -lt "0"))
		{
			$WPFTextBoxLog.AppendText("ERROR: Timeout waiting for OS Customization to complete!`n");
			Return $False;
		}
		Else
		{
			# OS customization not complete yet, but timeout has not been reached. Wait for 10 seconds and try again.
			Start-Sleep -Seconds 10
		}
    }
}

# Function to wait until the VMWare Tools are loaded on the Guest VM.
Function Wait-ForVMWareTools
{
	# Timeout is a variable, which is set to 15 minutes out of the box. This should cover Win2K12. Other OSes should load the tools much faster.
	
	$ToolsTimeout = $Timeout
	
	# Loop waiting for the VMWare tools to load
	While ($true)
	{
		$toolsStatus = (Get-VM $Guest | Get-View).Guest.ToolsStatus
		If (($toolsStatus -eq "toolsOk") -Or ($toolsStatus -eq "toolsOld"))
		{
			# VMWare tools loaded successfull
			$WPFTextBoxLog.AppendText("INFO: VMWare Tools started, proceeding with the file transfer!`n");
			Return $true;
		}
		ElseIf (($ToolsTimeout -lt "0"))
		{
			# VMWare tools not loaded and the timeout has been reached
			$WPFTextBoxLog.AppendText("ERROR: Timeout waiting for VMWare Tools to load!`n");
			Return $false;
		}
		Else
		{
			# VMWare tools not loaded, but timeout has not been reached. Wait for 10 seconds and try again.
			$ToolsTimeout = $ToolsTimeout - 10;
			Start-Sleep -s 10
		}
	}
}

# Function to upload license files to the newly deployed VM. Apparently this can only be done to ST.
Function Upload-LicenseFiles
{
	$GuestVM = Get-VM $Guest
	
	# Did the VMWare Tools load?
	If ((Wait-ForVMWareTools))
	{
		# Just in case something is still loading, especially on Appliance:
		#$WPFTextBoxLog.AppendText("DEBUG: Waiting for 2 minutes to allow services to start!`n");
		Start-Sleep -Seconds 120

		# Since the installation path differs between Windows and Linux, we use different commands
		If (($WPFcomboBoxOS.SelectedItem -like "WIN*") -And ($CustomizeLicenses -eq $true))
		{
			$WindowsCoreFullPath = $STWindowsPath + $STCoreLicenseFilename
			$WindowsFeaturesFullPath = $STWindowsPath + $STFeaturesLicenseFilename
			#$WPFTextBoxLog.AppendText("DEBUG: License File1 - $($WindowsCoreFullPath)!`n");
			#$WPFTextBoxLog.AppendText("DEBUG: License File2 - $($WindowsFeaturesFullPath)!`n");
			
			# Windows License Customization. We copy two files - Core and Features licenses. Restart of the ST services should be done manually to apply the new licenses.
			Copy-VMGuestFile -Source $WPFtextBoxLicense1.Text -LocalToGuest -Destination $WindowsCoreFullPath -VM $GuestVM -GuestUser $VMAdmin -GuestPassword $VMPass -Confirm:$false
			Copy-VMGuestFile -Source $WPFtextBoxLicense2.Text -LocalToGuest -Destination $WindowsFeaturesFullPath -VM $GuestVM -GuestUser $VMAdmin -GuestPassword $VMPass -Confirm:$false
			$WPFTextBoxLog.AppendText("INFO: License Files copied successfully. Please restart ST to apply them!`n");
		}
		ElseIf (($CustomizeLicenses -eq $true))
		{
			# Since Linux templates have both ST Edge and ST Core servers installed, we copy the files to both folders. Restart of the ST services should be done manually to apply the new licenses.
			# Scripting the restart is possible, but to be avoided due to possible conflicts between the Edge and Core servers. We can't run both.
			
			$ServerCoreFullPath = $STServerPath + $STCoreLicenseFilename
			$ServerFeaturesFullPath = $STServerPath + $STFeaturesLicenseFilename
			#$WPFTextBoxLog.AppendText("DEBUG: License File1 - $($ServerCoreFullPath)!`n");
			#$WPFTextBoxLog.AppendText("DEBUG: License File2 - $($ServerFeaturesFullPath)!`n");
			
			$EdgeCoreFullPath = $STEdgePath + $STCoreLicenseFilename
			$EdgeFeaturesFullPath = $STEdgePath + $STFeaturesLicenseFilename
			#$WPFTextBoxLog.AppendText("DEBUG: License File1 - $($EdgeCoreFullPath)!`n");
			#$WPFTextBoxLog.AppendText("DEBUG: License File2 - $($EdgeFeaturesFullPath)!`n");
			
			# Linux License Customization for the ST Server
			Copy-VMGuestFile -Source $WPFtextBoxLicense1.Text -LocalToGuest -Destination $ServerCoreFullPath -VM $GuestVM -GuestUser $VMRoot -GuestPassword $VMPass -Confirm:$false
			Copy-VMGuestFile -Source $WPFtextBoxLicense2.Text -LocalToGuest -Destination $ServerFeaturesFullPath -VM $GuestVM -GuestUser $VMRoot -GuestPassword $VMPass -Confirm:$false
			
			# Linux License Customization for the ST Edge
			Copy-VMGuestFile -Source $WPFtextBoxLicense1.Text -LocalToGuest -Destination $EdgeCoreFullPath -VM $GuestVM -GuestUser $VMRoot -GuestPassword $VMPass -Confirm:$false
			Copy-VMGuestFile -Source $WPFtextBoxLicense2.Text -LocalToGuest -Destination $EdgeFeaturesFullPath -VM $GuestVM -GuestUser $VMRoot -GuestPassword $VMPass -Confirm:$false
			$WPFTextBoxLog.AppendText("INFO: License Files copied successfully. Please restart ST to apply them!`n");
		}
	}
}

# Function to upload other file to the new ST VM.
Function Upload-OtherFile
{
	$GuestVM =  Get-VM $Guest
	$otherFileName = Split-Path $WPFtextBoxOtherFile.text -leaf
	
	# Did the VMWare Tools load?
	If ((Wait-ForVMWareTools))
	{

		# Just in case something is still loading, especially on Appliance. Since Licenses might have already waited for that, we can skip it.
		If (($CustomizeLicenses))
		{
			#$WPFTextBoxLog.AppendText("DEBUG: All good. Licenses uploaded, no need to wait!`n");
		}
		Else
		{
			#$WPFTextBoxLog.AppendText("DEBUG: No licenses uploaded, so waiting for 2 minutes to allow all services to start`n");
			Start-Sleep -Seconds 120
		}
		
		# Since the installation path differs between Windows and Linux, we use different commands
		If (($WPFcomboBoxOS.SelectedItem -like "WIN*"))
		{
			$WindowsOtherFullPath = $STOtherWindowsPath + $otherFileName
			#$WPFTextBoxLog.AppendText("DEBUG: Other File Full Path - $($WindowsOtherFullPath)!`n");
			
			# Windows License Customization. We copy two files - Core and Features licenses. Restart of the ST services should be done manually to apply the new licenses.
			Copy-VMGuestFile -Source $WPFtextBoxOtherFile.Text -LocalToGuest -Destination $WindowsOtherFullPath -VM $GuestVM -GuestUser $VMAdmin -GuestPassword $VMPass -Confirm:$false -Force:$true
			$WPFTextBoxLog.AppendText("INFO: $($otherFileName) copied successfully to $($STOtherWindowsPath)!`n");
		}
		Else
		{
			# Since Linux templates have both ST Edge and ST Core servers installed, we copy the files to both folders. Restart of the ST services should be done manually to apply the new licenses.
			# Scripting the restart is possible, but to be avoided due to possible conflicts between the Edge and Core servers. We can't run both.
			
			$ServerOtherFullPath = $STOtherFilePath + $otherFileName
			#$WPFTextBoxLog.AppendText("DEBUG: Other File Full Path - $($ServerOtherFullPath)!`n");
			
			# Linux License Customization for the ST Server
			Copy-VMGuestFile -Source $WPFtextBoxOtherFile.Text -LocalToGuest -Destination $ServerOtherFullPath -VM $GuestVM -GuestUser $VMRoot -GuestPassword $VMPass -Confirm:$false -Force:$true
			$WPFTextBoxLog.AppendText("INFO: $($otherFileName) copied successfully to $($STOtherFilePath)!`n");
		}
	}
}

# Function to delete the OS Customization specification
Function Delete-OSCustomizationDetails
{
	# Clear the OS Customization specification
	$WPFTextBoxLog.AppendText("INFO: Deleting OSCustomizationSpec!`n");
	Get-OSCustomizationSpec OSCustomSpec | Remove-OSCustomizationSpec -Confirm:$false
}

# Function to clean up the OS Customization specification from the ESX Server and disconnect
Function Finalize-VMDeployment
{
	# Disconnect
	$WPFTextBoxLog.AppendText("INFO: Disconnecting from ESX!`n`n");
	Disconnect-VIServer -Server * -Force -Confirm:$false
	# Enabling the Deploy button again after successful deployment
	$WPFbuttonDeploy.IsEnabled=$true;
}

# Function to get the datastore with the largest amount of free space for the specified VMWare Host
Function Get-LargestDatastoreForHost ($DatastoreHost)
{
	$datastores = Get-VMHost $DatastoreHost | get-datastore | where {$_.Name -notmatch "iso"} | select Name,FreeSpaceMB

	#Seting some static info
	$LargestFreeSpace = "0"
	$LargestDatastore = $null

	#Performs the calculation of which datastore has most free space
	foreach ($datastore in $datastores) 
		{
		If (($Datastore.FreeSpaceMB -gt $LargestFreeSpace)) 
			{ 
			$LargestFreeSpace = $Datastore.FreeSpaceMB
			$LargestDatastore = $Datastore.name
			}
		}
	return $LargestDatastore;
}

# Function to print the datastore free space to the log
Function Print-DatastoreFreeSpace
{
	If ((Check-Credentials))
	{
		If ((Check-VMConnection))
		{
			ForEach ($DatastoreHost in $vSphereClusters)
			{
				$LargestDatastore = Get-LargestDatastoreForHost $DatastoreHost
				#$WPFTextBoxLog.AppendText("DEBUG: Largest Datastore Name = $($LargestDatastore)!`n");
				$DataStoreFreeSpace = Get-Datastore -Name $LargestDatastore | select @{N="FreeSpace";E={[Math]::Round($_.FreeSpaceMB/1024,2)}}
				$WPFTextBoxLog.AppendText("INFO: Free Space on $($DatastoreHost) = $($DataStoreFreeSpace.FreeSpace)GB`n");
			}
			Finalize-VMDeployment
		}
	}

}

# Function to check for the credentials. This is required to connect to the VMWare and get the host free space
Function Check-Credentials
{
	If (($WPFtextBoxUsername.Text -eq "") -or ($WPFpasswordBoxPassword.Password -eq ""))
	{
		$WPFTextBoxLog.AppendText("FATAL: Missing ESX Login details. Aborting!`n");
		$ShallWeProceed = $false;
		# Since the error is fatal we stop processing further
		Return $false
	}
	Else
	{
		# Credentials are OK, proceeding.
		Return $true
	}
}

# Function to enable License buttons for ST deployment
Function Enable-FileTransfer
{
	# Enabling the License and other file buttons
	$WPFtextBoxLicense1.IsEnabled = $true
	$WPFtextBoxLicense2.IsEnabled = $true
	$WPFbuttonLicense1.IsEnabled = $true
	$WPFbuttonLicense2.IsEnabled = $true
	$WPFtextBoxOtherFile.IsEnabled = $true
	$WPFbuttonOtherFile.IsEnabled = $true
}

# Function to disable License buttons for MG and other products deployment
Function Disable-FileTransfer
{
	# Enabling the License and other file buttons
	$WPFtextBoxLicense1.IsEnabled = $false
	$WPFtextBoxLicense2.IsEnabled = $false
	$WPFbuttonLicense1.IsEnabled = $false
	$WPFbuttonLicense2.IsEnabled = $false
	$WPFtextBoxOtherFile.IsEnabled = $false
	$WPFbuttonOtherFile.IsEnabled = $false
}

#===========================================================================
# GUI action
#===========================================================================

# Product ComboBox - changing the value changes the list of OSes and Versions in the other two combo boxes.
$WPFcomboBoxProduct.Add_SelectionChanged({
	If (($WPFcomboBoxProduct.SelectedItem -eq "SecureTransport"))
	{
		# Filling the OS and Version ComboBoxes.
		$WPFcomboBoxVersion.ItemsSource = $STVersionsArray;
		$WPFcomboBoxOS.ItemsSource = $STOSArray;
		
		# Enable the file transfer functionality
		Enable-FileTransfer;
	}
	ElseIf (($WPFcomboBoxProduct.SelectedItem -eq "LogMaster"))
	{
		# Filling the OS and Version ComboBoxes.
		$WPFcomboBoxVersion.ItemsSource = $LMVersionsArray;
		$WPFcomboBoxOS.ItemsSource = $LMOSArray;
		
		# Disable the file transfer functionality
		Disable-FileTransfer;
	}
	ElseIf (($WPFcomboBoxProduct.SelectedItem -eq "MailGate"))
	{
		# Filling the OS and Version ComboBoxes.
		$WPFcomboBoxVersion.ItemsSource = $MGVersionsArray;
		$WPFcomboBoxOS.ItemsSource = $MGOSArray;
		
		# Disable the file transfer functionality
		Disable-FileTransfer;
	}
})

# Help Button action - open Jive web page with the script documentation
$WPFbuttonHelp.Add_Click({
	Start-Process -FilePath "https://axway.jiveon.com/groups/sofia-support/projects/templatezilla"
})

# Help Button action - open Jive web page with the script documentation
$WPFbuttonFreeSpace.Add_Click({
	Print-DatastoreFreeSpace;
})

# Deploy Button action - initiating the deployment
$WPFbuttonDeploy.Add_Click({
	# Disabling the butto when the deployment starts to avoid accidentally running that deployment again.
	$WPFbuttonDeploy.IsEnabled=$false;
	
	# Clearing the log
	$CurrentDateAndTime = Get-Date -Format g
	$WPFTextBoxLog.AppendText("INFO: Date: $($CurrentDateAndTime)`n");
	$WPFTextBoxLog.AppendText("INFO: Deployment Started!`n");
	
	# Validating the input from the GUI. Those 3 variables get the values returned by the Check-FormFilled function
	$ShallWeProceed,$CustomizeNetwork,$CustomizeLicenses,$OtherFile = Check-FormFilled
	#$WPFTextBoxLog.AppendText("DEBUG: Deployment Greenlight: $($ShallWeProceed)!`n");
	#$WPFTextBoxLog.AppendText("DEBUG: Customize Network: $($CustomizeNetwork)!`n");
	#$WPFTextBoxLog.AppendText("DEBUG: Install Licenses: $($CustomizeLicenses)!`n");
	#$WPFTextBoxLog.AppendText("DEBUG: Upload other file: $($OtherFile)!`n");
	
	# If we have a greenlight to proceed, a.k.a all mandatory fields are filled.
	If (($ShallWeProceed -eq $true))
	{
		# Since the VM would probably have some special characters, like the square brackets for the engineer name, we need to replace them with wildcard, so PowerShell can pass them to VMWare. 
		# \W is a regex that matches all characters apart from a-z, A-Z, 0-9 and underscore.
		$Guest = $WPFtextBoxName.Text
		$Guest = $Guest -replace '[\W]', '*'
		
		# Try to connect and only proceed if we have confirmed connection
		If ((Check-VMConnection))
		{
			# Combine the product name, version and OS into template name to use.
			$TemplateConstructedName=Create-TemplateName;
			$WPFTextBoxLog.AppendText("INFO: Template: $($TemplateConstructedName)!`n");
			
			# Probe the ESX for that template name and only proceed if it exists.
			If ((Check-VMTemplateExists))
			{
				# Create and verify the OS Customization details
				Create-OSCustomizationDetails
				If ((Verify-OSCustomizationDetails)){
					# Creating and Starting the new VM
					Create-VMFromTemplate
					Start-GuestVM
					
					# Wait for OS Customization. Once complete (regardless if successful), the OS should not restart anymore and the VMWare Tools should be stable for file transfers.
					Wait-ForOSCustomizationComplete
					
					# Uploading license files if selected
					If (($CustomizeLicenses)) {
						Upload-LicenseFiles
					}
					
					# Uploading license files if selected
					If (($OtherFile)) {
						Upload-OtherFile
					}
					
					# Delete the OS Customization Details
					Delete-OSCustomizationDetails
					
					# Cleaning and closing the connection
					$WPFTextBoxLog.AppendText("INFO: VM Cloning complete. The VM should be ready in few minutes!`n");
					Finalize-VMDeployment
				}
			}
		}
	}
	Else
	{
		# Re-enabling the deploy button after failed deploy attempt.
		$WPFbuttonDeploy.IsEnabled=$true;
	}
})

# If Windows OS is selected, a checkbox is enabled to allow engineers to select "Edge" deployment.
# Linux based OSes have both Core and Edge servers installed, so no such selection is necessary.
$WPFcomboBoxOS.Add_SelectionChanged({
	If (($WPFcomboBoxOS.SelectedItem -like "WIN*"))
	{
		$WPFcheckBoxEdge.IsEnabled=$true;
	}
	Else
	{
		$WPFcheckBoxEdge.IsEnabled=$false;
		$WPFcheckBoxEdge.IsChecked=$false;
	}
})

# Core License Browse button - Opens "Browse File" dialog for file selection.
$WPFbuttonLicense1.Add_Click({
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = "C:\"
    $OpenFileDialog.filter = "TXT (*.txt)| *.txt"
    $OpenFileDialog.ShowDialog() | Out-Null
	$WPFtextBoxLicense1.Text=$OpenFileDialog.filename;
	
	# The filename selected is stored temporarily in the text box before the button.
	# Functions use that text box to know which file to transfer to the VMs.
	# If no file is selected, the text box value is reset to default.
	If (($WPFtextBoxLicense1.Text -eq ""))
	{
		$WPFtextBoxLicense1.Text="Core License";
	}
})

# Features License Browse button - Opens "Browse File" dialog for file selection.
$WPFbuttonLicense2.Add_Click({
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = "C:\"
    $OpenFileDialog.filter = "TXT (*.txt)| *.txt"
    $OpenFileDialog.ShowDialog() | Out-Null
	$WPFtextBoxLicense2.Text=$OpenFileDialog.filename;

	# The filename selected is stored temporarily in the text box before the button.
	# Functions use that text box to know which file to transfer to the VMs.
	# If no file is selected, the text box value is reset to default.
	If (($WPFtextBoxLicense2.Text -eq ""))
	{
		$WPFtextBoxLicense2.Text="Features License";
	}
})

# Other File Browse button - Opens "Browse File" dialog for file selection.
$WPFbuttonOtherFile.Add_Click({
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = "C:\"
    $OpenFileDialog.filter = "All Files (*.*)| *.*"
    $OpenFileDialog.ShowDialog() | Out-Null
	$WPFtextBoxOtherFile.Text=$OpenFileDialog.filename;

	# The filename selected is stored temporarily in the text box before the button.
	# Functions use that text box to know which file to transfer to the VMs.
	# If no file is selected, the text box value is reset to default.
	If (($WPFtextBoxOtherFile.Text -eq ""))
	{
		$WPFtextBoxOtherFile.Text="Other File";
	}
})
 
#===========================================================================
# Shows the form
#===========================================================================

# This brings up the GUI upon script startup.
$Form.ShowDialog() | out-null