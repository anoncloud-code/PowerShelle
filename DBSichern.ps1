param (
[String]$Server="",
[String]$User="",
[String]$PW="",
[String]$DB="",
[String]$Ort="",
[String]$bakName="",
[String]$PWFile="C:\tmp\PW.txt"
)
###########################################################################
#Um das unsignierte Script auszuführen, eines der Möglichkeiten nutzen    #
#powershell.exe -noprofile -executionpolicy bypass -command DBSichern.ps1 #
#Get-ExecutionPolicy Unrestricted                                         #
###########################################################################
#Verschlüsseltes PWFile erzeugen:                                         #
#read-host -assecurestring | convertfrom-securestring | out-file $PWFile  #
#$PW = cat $PWFile | ConvertTo-SecureString                               #
###########################################################################

if (Get-Module -ListAvailable -Name SqlServer) {
} else 
{
    Write-Host "Die SQL Module fehlen auf diesem PC/Server"
    switch(Read-Host "Sollen die Tools jetzt installiert werden?[y/N]"){
    
    y {Install-Module -Name SqlServer; break}
    n {Write-Host "Bitte installieren Sie das SQL Server Management Studio oder die PSTools SqlServer" ;exit ; break}
    default {"Ungültige Eingabe";exit; break}
    }
}

$date= (Get-Date).ToString("yyyyMd")

if ($Server -eq ""){$Server = Read-Host "SQLServer Namen oder IP(\Instanz) eingeben[localhost] "}
if ($Server -eq ""){$Server = "localhost"}

if ($User -eq ""){$User = Read-Host "Bitte DB User angeben[sa]"}
if ($User -eq ""){$User = "sa"}

if ($PW -eq "")
{$pass = Read-Host -assecurestring "Bitte Passwort eingeben"}
else
{$pass = $PW | ConvertTo-SecureString -AsPlainText -Force}

$login = New-Object System.Management.Automation.PsCredential ($User, $pass)

if ($DB -eq ""){$DB = Read-Host "Bitte DB eingeben. Fuer eine Liste der vorhandenen DBs einfach Enter druecken"}
if ($DB -eq "")
{
    (Get-SqlDatabase -ServerInstance $Server -Credential $login).Name
    $DB = Read-Host "Bitte DB eingeben"
}

if ($Ort -eq ""){$Ort=Read-Host "Bitte geben Sie den Speicherort auf dem Server fuer die BAK Datei an.?[default]"}
if ($Ort -ne "")
{
    if ( $Ort.EndsWith("\") ) {} else {$Ort = $Ort+"\"}
}

if ($bakName -eq ""){$bakName=Read-Host "Bitte Name der BAK Datei eingeben[sich_DB_Datum_vorUpdate.bak]"}
if ($bakName -eq ""){$bakName= "sich_"+$DB+"_"+$date+"_vorUpdate.bak"}

Backup-SqlDatabase -ServerInstance $Server -Database $DB -BackupFile $Ort$bakName -CompressionOption on -CopyOnly -Credential $login
