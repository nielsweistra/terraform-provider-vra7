# Installs golang dep on Windows.
#
# # Run script:
# .\install-dep.ps1 -version 0.4.1 
#
# # Download and run script:
# $env:DEPVERSION = '0.4.1'
# iex ((new-object net.webclient).DownloadString('SCRIPT_URL_HERE'))
Param(
    [String]$version,
    [switch]$h = $false,
    [switch]$help = $false,
    [switch]$reinstall = $false
)
 
$SCRIPT=$MyInvocation.MyCommand.Name
$gopathbin = "$env:goroot\bin"
#$downloadDir = $env:LOCALAPPDATA
$url32 = 'https://github.com/golang/dep/releases/download/v'+ $version +'/dep-windows-386.exe'
$url64 = 'https://github.com/golang/dep/releases/download/v'+ $version +'/dep-windows-amd64.exe'
$url =   "https://github.com/golang/dep/releases/download/v0.4.1/dep-windows-amd64.exe"
$output = "$gopathbin\dep.exe"

function print_usage() {
  Write-Output @"
Download and install Golang Dep on Windows.
Usage:
  $SCRIPT -version 0.4.1
Options:
  -h | -help
    Print the help menu.
  -version
    Golang dep version to install. Required.
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
    $version = $env:DEPVERSION
}
if ($version -eq "" ) {
  Write-Error "Error: -version is required"
  print_usage
  exit 1
}

if ($reinstall) {
    Remove-Item -Path "$gopathbin\dep.exe" -Force
}
# Determine type of system
if ($ENV:PROCESSOR_ARCHITECTURE -eq "AMD64") {
    $url = $url64
    Write-Host $ENV:PROCESSOR_ARCHITECTURE
} 
else {
    $url = $url32
    Write-Host $ENV:PROCESSOR_ARCHITECTURE
}

$start_time = Get-Date
Write-Output "Downloading $url"
if (!(Test-Path "$output")) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $url -OutFile $output
}

Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
dep version