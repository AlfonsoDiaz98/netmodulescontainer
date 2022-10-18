param(
		[string] $urlFtps, 
		[string] $resourceName, 
		[string] $passFtp
)
$userFtp = $resourceName+'\$'+$resourceName;

#Invoke-WebRequest 'https://raw.githubusercontent.com/AlfonsoDiaz98/netmodulescontainer/master/samplefile.txt' -OutFile 'samplefile.txt';

$urlFtp = $urlFtps.Replace('ftps', 'ftp');
$currentPath = Get-Location;

$filePath =  $currentPath.Path+"/samplefile.txt";
$file = Get-Item -Path $filePath;

try{	

	$uri = New-Object System.Uri("$urlFtp/$($file.Name)");

	$request = ([System.Net.FtpWebRequest])::Create($uri);
	$request.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile;
	$request.Credentials = New-Object System.Net.NetworkCredential($userFtp,$passFtp);
	$request.Credentials.UserName = $request.Credentials.UserName.Replace('\\','\');
	
	$fileBytes = [System.IO.File]::ReadAllBytes($filePath);
	$request.ContentLength = $fileBytes.Length;
	$requestStream = $request.GetRequestStream();
	
	try {
		$requestStream.Write($fileBytes, 0, $fileBytes.Length)
	}
	finally {
		$requestStream.Dispose()
	}
	
	#Write-Output $request;
	
}catch{
	Write-Output $_.exception;
}

# WAY 1
# $request = new-object System.Net.WebClient;
# $request.Credentials = New-Object System.Net.NetworkCredential($userFtp,$passFtp);
# $request.UploadFile($uri, $filePath);
# Write-Output $file.Name;
