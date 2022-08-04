#####################################################################################################
#                                                                                                   # 
# This part of the code will rename all files in folder and subfolders with the name of the folder. #
# VERY IMPORTANT - SPECIFY THE CORRECT FOLDER (the default one is c:\sako)!!!                       #
# IF YOU DON'T, PREPAIR TO REINSTALL THE WINDOWS!!!                                                 #
#                                                                                                   # 
#####################################################################################################

Get-ChildItem "c:\sako" -file -Recurse | foreach {
    Rename-Item $_.FullName -New ($_.directory.Name + '_' + $_.name)
}

#####################################################################################################
#                                                                                                   # 
# This part of the code will move all files in folder and subfolders to another folder (c:\moved).  #
# VERY IMPORTANT - SPECIFY THE CORRECT FOLDER (the default one is c:\sako)!!!                       #
# IF YOU DON'T, PREPAIR TO REINSTALL THE WINDOWS!!!                                                 #
#                                                                                                   # 
#####################################################################################################

Get-ChildItem -Path "c:\sako\*.*" -Recurse | Move-Item -Destination "c:\moved"