param(
	[string] $urlFtps, 
	[string] $resourceName, 
	[string] $passFtp
)

$triesFolder = @();
$triesFiles = @();

function MakeDirectoryRecursive {
	param(
		$uri,
		$cred,
		$counter = 1
	)
	try {
		$reqFolder = [System.net.WebRequest]::Create($uri);
		$reqFolder.Method = [System.Net.WebRequestMethods+Ftp]::MakeDirectory;
		$reqFolder.Credentials = $cred;
		$reqFolder.GetResponse() >$null;
		Write-Output $counter;
	}
	catch {
		$counter += 1;
		if ($counter -le 10) {
			MakeDirectoryRecursive $uri $cred $counter;
		}
		else {
			throw "Attempt limit exceeded: $uri"
		}
	}
}

function UploadFileRecursive {
	param(
		$uri,
		$localPath,
		$cred,
		$counter = 1
	)
	try {
		$reqFile = new-object System.Net.WebClient;
		$reqFile.Credentials = $cred;
		$reqFile.UploadFile($uri, $localPath);
		Write-Output $counter;
	}
	catch {
		$counter += 1;
		if ($counter -le 10) {
			UploadFileRecursive $uri $localPath $cred $counter;
		}
		else {
			throw "Attempt limit exceeded: $uri";
		}
	}
}

$ftpPath = $urlFtps.Replace('ftps', 'ftp');
$userFtp = $resourceName + '\$' + $resourceName;
$credentials = New-Object System.Net.NetworkCredential($userFtp, $passFtp);
$mainFolderName = 'SmartLinkCentral';

#Download smart link central
$storageName = 'efferentdev';
$storageKey = 'izikb23/CF62pq1J1RKG/RkhgDD7Stt52v6hpXxP3WFxiXacKNFKHTQ8By3eCzD3RukVZhkLlTsvSuJNzFjYCg==';
$defaultContainerName = 'smartlinkarmdefault'

$context = New-AzStorageContext -StorageAccountName $storageName -StorageAccountKey $storageKey -Protocol 'https';
$expiry = [DateTime]::Today.AddDays(+1);
$token = New-AzStorageContainerSASToken -Context $context -Name $defaultContainerName -Permission 'rl' -ExpiryTime $expiry;

$url_base = "https://efferentdev.blob.core.windows.net/$defaultContainerName";
$list = $url_base + $token + '&restype=container&comp=list';
Invoke-WebRequest $list -OutFile 'smartlinkcentral.xml';

[xml]$paths = Get-Content -Path './smartlinkcentral.xml';
$slcentralPaths = $paths.EnumerationResults.Blobs.Blob.Name | Where-Object { $_ -match "$mainFolderName/" }

foreach ($path in $slcentralPaths) {
	$url = $url_base + '/' + $path + $token;
	Invoke-WebRequest $url -OutFile (New-Item -Path ('./' + $path) -Force);
}
	
#Create ftp folder structure
$currentPath = Get-Location;
$slFolderPath = "$($currentPath.Path)/$mainFolderName";
$slFilesAndFolders = (Get-ChildItem $slFolderPath -Recurse);
$slFolders = $slFilesAndFolders | Where-Object { $_.PSIsContainer };

foreach ($folder in $slFolders) {
	$uriFolder = $folder.FullName.Replace($slFolderPath, $ftpPath);
	$triesFolder += MakeDirectoryRecursive $uriFolder $credentials;
}
	
$slFiles = $slFilesAndFolders | Where-Object { !$_.PSIsContainer };
foreach ($file in $slFiles) {
	$uriFile = $file.FullName.Replace($slFolderPath, $ftpPath);
	$triesFiles += UploadFileRecursive $uriFile $file.FullName $credentials;
}

Write-Output $triesFolder $triesFiles;

Restart-AzWebApp -ResourceGroupName "testMarketplace" -Name $resourceName;
