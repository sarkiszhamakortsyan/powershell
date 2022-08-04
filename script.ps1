##### The list of folders and subfolders #####
$folder1 = "C:\script\one"
$folder2 = "C:\script\two"
$folder3 = "C:\script\three"
$folder4 = "C:\script\four"
$folder5 = "C:\script\five"
$mf = "C:\sako"

##### Function that will rename the file in the subfolder into                     #####
##### subfoldername-filename.extension In this case the subfolder name will be one #####
get-childitem $folder1 -file -recurse | foreach {

	rename-item $_.fullname -new ($_.directory.name + '-' + $_.name)

}
get-childitem $folder2 -file -recurse | foreach {

	rename-item $_.fullname -new ($_.directory.name + '-' + $_.name)

}
get-childitem $folder3 -file -recurse | foreach {

	rename-item $_.fullname -new ($_.directory.name + '-' + $_.name)

}
get-childitem $folder4 -file -recurse | foreach {

	rename-item $_.fullname -new ($_.directory.name + '-' + $_.name)

}
get-childitem $folder5 -file -recurse | foreach {

	rename-item $_.fullname -new ($_.directory.name + '-' + $_.name)

}
##### Renamed files in the subfolders will be moved to another folder #####
Get-ChildItem -Path $folder1 -Recurse -File | Move-Item -Destination $mf
Get-ChildItem -Path $folder2 -Recurse -File | Move-Item -Destination $mf
Get-ChildItem -Path $folder3 -Recurse -File | Move-Item -Destination $mf
Get-ChildItem -Path $folder4 -Recurse -File | Move-Item -Destination $mf
Get-ChildItem -Path $folder5 -Recurse -File | Move-Item -Destination $mf