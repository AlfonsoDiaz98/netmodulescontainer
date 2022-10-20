param(
	[string] $urlFtps, 
	[string] $resourceName, 
	[string] $passFtp
)

function MakeDirectoryRecursive {
	param(
		$uri,
		$cred
	)
	try{
		$reqFolder = [System.net.WebRequest]::Create($uri);
		$reqFolder.Method = [System.Net.WebRequestMethods+Ftp]::MakeDirectory;
		$reqFolder.Credentials = $cred;
		$reqFolder.GetResponse() >$null;
	}catch{
		MakeDirectoryRecursive($uri);
	}
}

#wrong calls array
$wrong = @();
Write-Output ($wrong);
#end

$ftpPath = $urlFtps.Replace('ftps', 'ftp');
$userFtp = $resourceName + '\$' + $resourceName;
$credentials = New-Object System.Net.NetworkCredential($userFtp, $passFtp);

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
	
#Create SmartLinkCentral folder
$uriSlc = "$ftpPath/SmartLinkCentral"
$slcFolderReq = [System.net.WebRequest]::Create($uriSlc);
$slcFolderReq.Method = [System.Net.WebRequestMethods+Ftp]::MakeDirectory;
$slcFolderReq.Credentials = $credentials;
$slcFolderReq.GetResponse() >$null;

#Create ftp folder structure
$currentPath = Get-Location;

$slFolderPath = $currentPath.Path + '/SmartLinkCentral';
$slFilesAndFolders = (Get-ChildItem $slFolderPath -Recurse);
$slFolders = $slFilesAndFolders | Where-Object { $_.PSIsContainer };

foreach($folder in $slFolders){
	$uriFolder = $folder.FullName.Replace($currentPath, $ftpPath);
	MakeDirectoryRecursive($uriFolder, $credentials);
}

# foreach ($folder in $slFolders) {
# 	try{
# 		$uriFolder = $folder.FullName.Replace($currentPath, $ftpPath);
# 		$reqFolder = [System.net.WebRequest]::Create($uriFolder);
# 		$reqFolder.Method = [System.Net.WebRequestMethods+Ftp]::MakeDirectory;
# 		$reqFolder.Credentials = $credentials;
# 		$reqFolder.GetResponse() >$null;
# 	}catch{
# 		Write-Host $_
# 		$wrong += $folder.FullName;
# 	}
# }

# #Upload files from local to ftp
# $slFiles = $slFilesAndFolders | Where-Object { !$_.PSIsContainer };

# $reqFile = new-object System.Net.WebClient;
# $reqFile.Credentials = $credentials
# foreach ($file in $slFiles) {
# 	try{
# 		$uriFile = $file.FullName.Replace($currentPath, $ftpPath);
# 		$reqFile.UploadFile($uriFile, $file.FullName);
# 	}catch{
# 		$wrong += $file.FullName;
# 		Write-Host $_
# 	}
# }

