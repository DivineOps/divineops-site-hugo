#copy the proxies.joson file into the right location
Copy-Item proxies.json -Destination d:\home\site\wwwroot

# Generates our blog to /public

#create the temp dir if it doesn't already exist
$tempPublicDir = "d:\local\temp\public"
if((Test-Path $tempPublicDir) -eq 0)
{
  New-Item -ItemType Directory -Force -Path $tempPublicDir
}

#run hugo to generate the site and output the files the the temp dir
.\tools\hugo.exe -d $tempPublicDir -s D:\home\site\repository

# Connection string associated with the blob storage.
$blobStorage = $env:AzureWebJobsStorage

# Then we extract the name and key below
$accountKey = ""
$accountName = ""
$array = $blobStorage.Split(';')
foreach($element in $array)
{
  if($element.Contains('AccountName')) {
    $accountName = $element.Replace("AccountName=", "")
  }  
  if($element.Contains('AccountKey')) {
      $accountKey = $element.Replace("AccountKey=", "")
  }
}

# Use AzCopy to deploy blob storage as long as we have an Account Key for the storage account
if($accountKey -ne "")
{
  .\tools\AzCopy\AzCopy.exe /Source:$tempPublicDir /Dest:https://$accountName.blob.core.windows.net/public /DestKey:$accountKey /SetContentType /S /Y
}
else
{
  Write-Host "Unable to find Storage Account Key"
}