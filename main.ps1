param(
	[string] $urlFtps, 
	[string] $resourceName, 
	[string] $passFtp
)
$userFtp = $resourceName + '\$' + $resourceName;

#Invoke-WebRequest 'https://raw.githubusercontent.com/AlfonsoDiaz98/netmodulescontainer/master/samplefile.txt' -OutFile 'samplefile.txt';

$urlFtp = $urlFtps.Replace('ftps', 'ftp');
$currentPath = Get-Location;

$filePath = $currentPath.Path + "/samplefile.txt";
$file = Get-Item -Path $filePath;

$uri = New-Object System.Uri("$urlFtp/$($file.Name)");

$request = [System.net.WebRequest]::Create($uri);
$request.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile;
$request.Credentials = New-Object System.Net.NetworkCredential($userFtp, $passFtp);

$fileBytes = [System.IO.File]::ReadAllBytes($filePath);
$request.ContentLength = $fileBytes.Length;
$requestStream = $request.GetRequestStream();

try {
	$requestStream.Write($fileBytes, 0, $fileBytes.Length)
}
finally {
	$requestStream.Dispose()
}

# $request = ([System.Net.FtpWebRequest])::Create($uri);
# $request.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile;
# $request.Credentials = New-Object System.Net.NetworkCredential($userFtp, $passFtp);
	
# $fileBytes = [System.IO.File]::ReadAllBytes($filePath);
# $request.ContentLength = $fileBytes.Length;
# $requestStream = $request.GetRequestStream();
	
# try {
# 	$requestStream.Write($fileBytes, 0, $fileBytes.Length)
# }
# finally {
# 	$requestStream.Dispose()
# }

Write-Output $request;
