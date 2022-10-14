param(
		[string] $urlFtps, 
		[string] $userFtp, 
		[string] $passFtp
)
$urlFtp = $urlFtps.Replace('ftps', 'ftp');
$currentPath = Get-Location;
$filePath =  $currentPath+"/samplefile.txt";
$file = Get-Item -Path $filePath;
$uri = New-Object System.Uri("$urlFtp/$($file.Name)");

$request = ([System.Net.FtpWebRequest])::Create($uri);
$request.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile;
$request.Credentials = New-Object System.Net.NetworkCredential($userFtp,$passFtp);

#$request.EnableSsl = 'true';
$fileBytes = [System.IO.File]::ReadAllBytes($filePath);
$request.ContentLength = $fileBytes.Length;
$requestStream = $request.GetRequestStream();

try {
    $requestStream.Write($fileBytes, 0, $fileBytes.Length);
}
finally {
    $requestStream.Dispose();
}



