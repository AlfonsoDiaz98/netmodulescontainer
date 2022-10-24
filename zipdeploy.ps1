$resourceName = $args[0];

#Download smart link central
$storageName = 'efferentdev';
$storageKey = 'izikb23/CF62pq1J1RKG/RkhgDD7Stt52v6hpXxP3WFxiXacKNFKHTQ8By3eCzD3RukVZhkLlTsvSuJNzFjYCg==';
$defaultContainerName = 'smartlinkarmdefault'
$mainFolderName = 'SmartLinkCentral';

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

$currentPath = Get-Location;
$zipName = 'slcentral.zip';
Compress-Archive -Path "$currentPath/$mainFolderName" -DestinationPath $zipName;
Publish-AzWebApp -ResourceGroupName 'testMarketplace' -Name 'webApp-webapptesteffe' -ArchivePath "C:\Users\alfon\OneDrive\Escritorio\netmodules\slcentral.zip";