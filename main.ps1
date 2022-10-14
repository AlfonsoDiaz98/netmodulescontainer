param(
		[string] $urlFtps, 
		[string] $userFtp, 
		[string] $passFtp
)
$urlFtp = $urlFtps.Replace('ftps', 'ftp');

$currentPath = Get-Location;
$filePath =  $currentPath.Path+"/samplefile.txt";
$file = Get-Item -Path $filePath;
$uri = New-Object System.Uri("$urlFtp/$($file.Name)");

$request = new-object System.Net.WebClient;
$request.Credentials = New-Object System.Net.NetworkCredential($userFtp,$passFtp);
$request.UploadFile($uri, $filePath);