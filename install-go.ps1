# Installs golang on Windows.
#
# # Run script:
# .\install-go.ps1 -version 1.5.3 
#
# # Download and run script:
# $env:GOVERSION = '1.5.3'
# iex ((new-object net.webclient).DownloadString('SCRIPT_URL_HERE'))
Param(
    [String]$version,
    [switch]$h = $false,
    [switch]$help = $false,
    [switch]$clean = $false,
    [switch]$c = $false
)

$SCRIPT=$MyInvocation.MyCommand.Name

function print_usage() {
  Write-Output @"
Download and install Golang on Windows. It sets the GOROOT environment
variable and adds GOROOT\bin to the PATH environment variable.
Usage:
  $SCRIPT -version 1.9.3
Options:
  -h | -help
    Print the help menu.
  -version
    Golang version to install. Required.
  -clean | -c
    Remove download package after download
"@
}
$start_time = Get-Date

if ($help -or $h) {
  print_usage
  exit 0
}
if ($args -ne "") {
  Write-Error "Error: Unknown option $args"
  print_usage
  exit 1
}
if ($version -eq "") {
    $version = $env:GOVERSION
}
if ($version -eq "" ) {
  Write-Error "Error: -version is required"
  print_usage
  exit 1
}

#$downloadDir = $PSScriptRoot
$downloadDir = $env:LOCALAPPDATA
$url32 = 'https://storage.googleapis.com/golang/go' + $version + '.windows-386.zip'
$url64 = 'https://storage.googleapis.com/golang/go' + $version + '.windows-amd64.zip'
$goroot = "C:\go$version"

# Determine type of system
if ($ENV:PROCESSOR_ARCHITECTURE -eq "AMD64") {
  $url = $url64
} else {
  $url = $url32
}

if (Test-Path "$goroot\bin\go.exe") {
  Write-Output "Go is installed to $goroot"
  exit
}

Write-Output "Downloading $url"
$zip = "$downloadDir\golang-$version.zip"
if (!(Test-Path "$zip")) {
  $downloader = new-object System.Net.WebClient
  $downloader.DownloadFile($url, $zip)
}

Write-Output "Extracting $zip to $goroot"
if (Test-Path "$downloadDir\go") {
  Remove-Item -Force -Recurse -Path "$downloadDir\go"
}
else {
  Write-Output "No dowloadfolder"  
}
if (Test-Path $goroot) {
  Write-Output "Remove Go $version"
  Remove-Item -Force -Recurse -Path $goroot
}
else {
  Write-Output "Go $version not found"  
}
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory("$zip", $downloadDir)
Move-Item -Force -Path "$downloadDir\go" -Destination $goroot 

Write-Output "Setting GOROOT and PATH for Machine"
[System.Environment]::SetEnvironmentVariable("GOROOT", "$goroot", "Machine")
$p = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
$p = "$goroot\bin;$p"
[System.Environment]::SetEnvironmentVariable("PATH", "$p", "Machine")

if ($clean -or $c) {
  if (Test-Path "$downloadDir\go") {
    Remove-Item -Force -Recurse -Path "$downloadDir\go"
  }

  if (Test-Path "$downloadDir\golang-$version.zip") {
    Write-Output "Clean up!"
    Remove-Item -Path "$downloadDir\golang-$version.zip" -Force
  } 
}
Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"