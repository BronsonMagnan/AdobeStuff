#This will download the Adobe Stuff

$ftp = "ftp://ftp.adobe.com/pub/adobe/reader/win/AcrobatDC/"

#we have to use .NET to read a directory listing from FTP, it is different than downloading a file.
# Original C# code at https://docs.microsoft.com/en-us/dotnet/framework/network-programming/how-to-list-directory-contents-with-ftp

$request = [System.Net.FtpWebRequest]::Create($ftp);
$request.Credentials = [System.Net.NetworkCredential]::new("anonymous","password");
$request.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectoryDetails;
[System.Net.FtpWebResponse]$response = [System.Net.FtpWebResponse]$request.GetResponse();
[System.IO.Stream]$responseStream = $response.GetResponseStream();
[System.IO.StreamReader]$reader = [System.IO.StreamReader]::new($responseStream);
$DirList = $reader.ReadToEnd()
$reader.Close()
$response.close()

#Split into Lines, currently it is one big string.
$DirByLine = $DirList.split("`n")

#Get the token containing the folder name
$folders = @()
foreach ($line in $DirByLine ) { 
    $endtoken = ($line.split(' '))[-1]
    #filter out non version folder names
    if ($endtoken -match "[0-9]") {
        $folders += $endtoken
    }
}


#Sort the folders by newest first, and select the first 1, and remove the newline whitespace at the end
$currentfolder = ($folders | sort -Descending | select -First 1).trim()

#make sure we can write to this folder
Set-Location "$($env:USERPROFILE)\downloads"

#speed up the download - but I do like knowing what the progress is /cry
$ProgressPreference = 'SilentlyContinue'

#The backticks are to escape the / character
$MSPDownload = "$($ftp)$($currentfolder)`/AcroRdrDCUpd$($currentfolder).msp"
$filename = ($MSPDownload.split("/"))[-1]
wget -uri $MSPDownload -outfile .\$filename

$EXEDownload = "$($ftp)$($currentfolder)`/AcroRdrDC$($currentfolder)_en_US.exe"
$filename = ($EXEDownload.split("/"))[-1]
wget -uri $EXEDownload -outfile .\$filename

