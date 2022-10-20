param(
	[string] $urlFtps, 
	[string] $resourceName, 
	[string] $passFtp,
	[string] $homeStamp
)

$ftpPath = $urlFtps.Replace('ftps', 'ftp');
$userFtp = $resourceName + '\$' + $resourceName;
$domainFtp = "$homeStamp.ftp.azurewebsites.windows.net";
$credentials = New-Object System.Net.NetworkCredential($userFtp, $passFtp);
$credentials.Domain = $domainFtp;
 
#Download smart link central
$storageName = 'efferentdev';
$storageKey = 'izikb23/CF62pq1J1RKG/RkhgDD7Stt52v6hpXxP3WFxiXacKNFKHTQ8By3eCzD3RukVZhkLlTsvSuJNzFjYCg==';
$defaultContainerName = 'smartlinkarmdefault'

$context = New-AzStorageContext -StorageAccountName $storageName -StorageAccountKey $storageKey -Protocol 'https';
$expiry = [DateTime]::Today.AddDays(+1);
$token = New-AzStorageContainerSASToken -Context $context -Name $defaultContainerName -Permission 'rl' -ExpiryTime $expiry;

$url_base = 'https://efferentdev.blob.core.windows.net/smartlinkarmdefault';
$list = $url_base + $token + '&restype=container&comp=list';
Invoke-WebRequest $list -OutFile 'smartlinkcentral.xml';

[xml]$paths = Get-Content -Path './smartlinkcentral.xml';
$slcentralPaths = $paths.EnumerationResults.Blobs.Blob.Name | Where-Object { $_ -match "SmartLinkCentral/" }

foreach ($path in $slcentralPaths) {
	$url = $url_base + '/' + $path + $token;
	Invoke-WebRequest $url -OutFile (New-Item -Path ('./' + $path) -Force);
}

Write-Output ($credentials);

#Create SmartLinkCentral folder
$uriSlc = "$ftpPath/SmartLinkCentral"
$slcFolderReq = [System.net.WebRequest]::Create($uriSlc);
$slcFolderReq.Method = [System.Net.WebRequestMethods+Ftp]::MakeDirectory;
$slcFolderReq.Credentials = $credentials;
$slcFolderReq.GetResponse() >$null;

# #Create ftp folder structure
# $currentPath = Get-Location;

# $slFolderPath = $currentPath.Path + '/SmartLinkCentral';
# $slFilesAndFolders = (Get-ChildItem $slFolderPath -Recurse);
# $slFolders = $slFilesAndFolders | Where-Object { $_.PSIsContainer };


# foreach ($folder in $slFolders) {
# 	$uriFolder = $folder.FullName.Replace($currentPath, $ftpPath);
# 	$webRequest = [System.net.WebRequest]::Create($uriFolder);
# 	$reqFolder = [System.Net.FtpWebRequest]$webRequest;
# 	$reqFolder.Method = [System.Net.WebRequestMethods+Ftp]::MakeDirectory;
# 	$reqFolder.Credentials = $credentials;
# 	$reqFolder.GetResponse() >$null;
# }

# #Upload files from local to ftp
# $slFiles = $slFilesAndFolders | Where-Object { !$_.PSIsContainer };
# $reqFile = new-object System.Net.WebClient;
# $reqFile.Credentials = New-Object System.Net.NetworkCredential('webApp-webapptesteffe\$webApp-webapptesteffe', $passFtp);

# foreach ($file in $slFiles) {
# 	$uriFile = $file.FullName.Replace($currentPath, $ftpPath);
# 	$reqFile.UploadFile($uriFile, $file.FullName);
# }