Get-ADComputer -Filter * -Property * | Select-Object Name,OperatingSystem,lastLogonDate,Ipv4Address | Export-CSV c:\asd\allcomputersproba.csv -NoTypeInformation