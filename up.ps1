$dockerToolsVersion = "10.2.7"
# Run as Administrator
Import-Module SitecoreDockerTools -RequiredVersion $dockerToolsVersion -DisableNameChecking
Import-Module -Name (Join-Path $PSScriptRoot "tools\common\ShowLogo") -Force -DisableNameChecking
Import-Module -Name (Join-Path $PSScriptRoot "tools\common\UI") -Force -DisableNameChecking
Import-Module -Name (Join-Path $PSScriptRoot "tools\local\Up") -Force -DisableNameChecking
Import-Module -Name (Join-Path $PSScriptRoot "tools\local\Init") -Force -DisableNameChecking

################################################
# SCRIPT PURPOSE:
#       0. Initial checks
#       1. Toggle app between xmcloud and local cm
#       2. Call npm i for all headless apps
#       3. Start Docker Containers (building images if necessary)
#       4. Init indexes (if first run)
#       5. Sync data (if desired)
#       6. Option to start headless app
################################################

Show-Logo

$ErrorActionPreference = "Stop";

. .\upFunctions.ps1

Write-Host "Validating Sitecore License..." -ForegroundColor Cyan
Validate-LicenseExpiry

$envContent = Get-Content .env -Encoding UTF8
$xmCloudHost = $envContent | Where-Object { $_ -imatch "^CM_HOST=.+" }
$sitecoreDockerRegistry = $envContent | Where-Object { $_ -imatch "^SITECORE_DOCKER_REGISTRY=.+" }
$sitecoreVersion = $envContent | Where-Object { $_ -imatch "^SITECORE_VERSION=.+" }
$ClientCredentialsLogin = $envContent | Where-Object { $_ -imatch "^SITECORE_FedAuth_dot_Auth0_dot_ClientCredentialsLogin=.+" }
$sitecoreApiKey = ($envContent | Where-Object { $_ -imatch "^SITECORE_API_KEY_xmcloudpreview=.+" }).Split("=")[1]

$xmCloudHost = $xmCloudHost.Split("=")[1]
$sitecoreDockerRegistry = $sitecoreDockerRegistry.Split("=")[1]
$sitecoreVersion = $sitecoreVersion.Split("=")[1]
$ClientCredentialsLogin = $ClientCredentialsLogin.Split("=")[1]
if ($ClientCredentialsLogin -eq "true") {
	$xmCloudClientCredentialsLoginDomain = $envContent | Where-Object { $_ -imatch "^SITECORE_FedAuth_dot_Auth0_dot_Domain=.+" }
	$xmCloudClientCredentialsLoginAudience = $envContent | Where-Object { $_ -imatch "^SITECORE_FedAuth_dot_Auth0_dot_ClientCredentialsLogin_Audience=.+" }
	$xmCloudClientCredentialsLoginClientId = $envContent | Where-Object { $_ -imatch "^SITECORE_FedAuth_dot_Auth0_dot_ClientCredentialsLogin_ClientId=.+" }
	$xmCloudClientCredentialsLoginClientSecret = $envContent | Where-Object { $_ -imatch "^SITECORE_FedAuth_dot_Auth0_dot_ClientCredentialsLogin_ClientSecret=.+" }
	$xmCloudClientCredentialsLoginDomain = $xmCloudClientCredentialsLoginDomain.Split("=")[1]
	$xmCloudClientCredentialsLoginAudience = $xmCloudClientCredentialsLoginAudience.Split("=")[1]
	$xmCloudClientCredentialsLoginClientId = $xmCloudClientCredentialsLoginClientId.Split("=")[1]
	$xmCloudClientCredentialsLoginClientSecret = $xmCloudClientCredentialsLoginClientSecret.Split("=")[1]
}

#set nuget version
$xmCloudBuild = Get-Content "xmcloud.build.json" | ConvertFrom-Json
$nodeVersion = $xmCloudBuild.renderingHosts.xmcloudpreview.nodeVersion
if (![string]::IsNullOrWhitespace($nodeVersion)) {
    Set-EnvFileVariable "NODEJS_VERSION" -Value $xmCloudBuild.renderingHosts.xmcloudpreview.nodeVersion
}

# Double check whether init has been run
$envCheckVariable = "HOST_LICENSE_FOLDER"
$envCheck = $envContent | Where-Object { $_ -imatch "^$envCheckVariable=.+" }
if (-not $envCheck) {
    throw "$envCheckVariable does not have a value. Did you run 'init.ps1 -InitEnv'?"
}

################################################
# 1. Toggle app between xmcloud and local cm
################################################
$localEnv = '.\src\head\.env.local'

if (!(Test-Path "$localEnv"))
{
   New-Item -path ".\src\head" -name ".env.local" -type "file" -value ""
}

if(Confirm -Question "Use DOCKER ENDPOINTS? - point Next.js data endpoints to local cm container?" -DefaultYes)
{
    Write-Host "Switching app endpoints to use docker cm" -ForegroundColor Yellow

    Set-EnvFileVariable "SITECORE_API_HOST" -Value 'https://xmcloudcm.localhost' -Path "$localEnv"
    Set-EnvFileVariable "GRAPH_QL_ENDPOINT" -Value 'https://xmcloudcm.localhost/sitecore/api/graph/edge' -Path "$localEnv"
    Set-EnvFileVariable "SITECORE_EDGE_CONTEXT_ID" -Value '' -Path "$localEnv"
    Set-EnvFileVariable "SITECORE_EDGE_URL" -Value '' -Path "$localEnv"
    
}
else{    
    Write-Host "Restoring app endpoints to use XM Cloud" -ForegroundColor Yellow
    
    Set-EnvFileVariable "SITECORE_API_HOST" -Value 'https://xmc-americaneag7f3a-ahmedplaygr2f13-development.sitecorecloud.io' -Path "$localEnv"
    Set-EnvFileVariable "GRAPH_QL_ENDPOINT" -Value 'https://xmc-americaneag7f3a-ahmedplaygr2f13-development.sitecorecloud.io/sitecore/api/graph/edge' -Path "$localEnv"
    Set-EnvFileVariable "SITECORE_EDGE_CONTEXT_ID" -Value '4Pdx204bQtHszJrDYRM9J0' -Path "$localEnv"
    Set-EnvFileVariable "SITECORE_EDGE_URL" -Value 'https://edge-platform.sitecorecloud.io' -Path "$localEnv"
}

################################################
# 2. Call npm i for all headless apps
################################################
Invoke-NpmInit './src/head'

################################################
# 3. Start Docker Containers
################################################
Write-Host "Keeping XM Cloud base image up to date" -ForegroundColor Green
Show-Command "docker pull `"$($sitecoreDockerRegistry)sitecore-xmcloud-cm:$($sitecoreVersion)`""
docker pull "$($sitecoreDockerRegistry)sitecore-xmcloud-cm:$($sitecoreVersion)"

# Build all containers in the Sitecore instance, forcing a pull of latest base containers
#Write-Host "Building containers..." -ForegroundColor Green
#docker compose build

Invoke-DockerBuild

if ($LASTEXITCODE -ne 0) {
    Write-Error "Container build failed, see errors above."
}

# Enhanced Start-up, and build solution
Start-Docker

# Start the Sitecore instance
#Write-Host "Starting Sitecore environment..." -ForegroundColor Green
#docker compose up -d

# Wait for Traefik to expose CM route
#Write-Host "Waiting for CM to become available..." -ForegroundColor Green
#$startTime = Get-Date
#do {
#    Start-Sleep -Milliseconds 100
#    try {
#        $status = Invoke-RestMethod "http://localhost:8079/api/http/routers/cm-secure@docker"
#    } catch {
#        if ($_.Exception.Response.StatusCode.value__ -ne "404") {
#            throw
#        }
#    }
#} while ($status.status -ne "enabled" -and $startTime.AddSeconds(15) -gt (Get-Date))
#if (-not $status.status -eq "enabled") {
#    $status
#    Write-Error "Timeout waiting for Sitecore CM to become available via Traefik proxy. Check CM container logs."
#}

Write-Host "Restoring Sitecore CLI..." -ForegroundColor Green
Show-Command "dotnet tool restore"
    dotnet tool restore
Write-Host "Installing Sitecore CLI Plugins..."
Show-Command "dotnet sitecore --help | Out-Null"
dotnet sitecore --help | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Error "Unexpected error installing Sitecore CLI Plugins"
}

#####################################

Write-Host "Logging into Sitecore..." -ForegroundColor Green
if ($ClientCredentialsLogin -eq "true") {
    Show-Command "dotnet sitecore cloud login --client-id $xmCloudClientCredentialsLoginClientId --client-secret **** --client-credentials true"
    dotnet sitecore cloud login --client-id $xmCloudClientCredentialsLoginClientId --client-secret $xmCloudClientCredentialsLoginClientSecret --client-credentials true
    Show-Command "dotnet sitecore login --authority $xmCloudClientCredentialsLoginDomain --audience $xmCloudClientCredentialsLoginAudience --client-id $xmCloudClientCredentialsLoginClientId --client-secret **** --cm https://$xmCloudHost --client-credentials true --allow-write true"
    dotnet sitecore login --authority $xmCloudClientCredentialsLoginDomain --audience $xmCloudClientCredentialsLoginAudience --client-id $xmCloudClientCredentialsLoginClientId --client-secret $xmCloudClientCredentialsLoginClientSecret --cm https://$xmCloudHost --client-credentials true --allow-write true
}
else {
    Show-Command "dotnet sitecore cloud login"
    dotnet sitecore cloud login
    Show-Command "dotnet sitecore connect --ref xmcloud --cm https://$xmCloudHost --allow-write true -n default"
    dotnet sitecore connect --ref xmcloud --cm https://$xmCloudHost --allow-write true -n default
}

if ($LASTEXITCODE -ne 0) {
    Write-Error "Unable to log into Sitecore, did the Sitecore environment start correctly? See logs above."
}

################################################
#       4. Init indexes (if first run)
################################################
# Populate Solr managed schemas to avoid errors during item deploy
Write-Host "Populating Solr managed schema..." -ForegroundColor Green
dotnet sitecore index schema-populate
if ($LASTEXITCODE -ne 0) {
    Write-Error "Populating Solr managed schema failed, see errors above."
}

# Rebuild indexes
Write-Host "Rebuilding indexes ..." -ForegroundColor Green
Show-Command "dotnet sitecore index rebuild"
dotnet sitecore index rebuild

################################################
#       5. Sync data (if desired)
################################################
Write-Host "Pushing Default rendering host configuration" -ForegroundColor Green
Show-Command "dotnet sitecore ser push -i RenderingHost"
dotnet sitecore ser push -i RenderingHost

Write-Host "Pushing sitecore API key" -ForegroundColor Green
Show-Command "docker\build\cm\templates\import-templates.ps1 -RenderingSiteName `"xmcloudpreview`" -SitecoreApiKey $sitecoreApiKey"
& docker\build\cm\templates\import-templates.ps1 -RenderingSiteName "xmcloudpreview" -SitecoreApiKey $sitecoreApiKey

if ($ClientCredentialsLogin -ne "true") {
    Write-Host "Opening site..." -ForegroundColor Green
    Show-Command "Start-Process https://xmcloudcm.localhost/sitecore/"
    Start-Process https://xmcloudcm.localhost/sitecore/
}

Write-Host ""
Write-Host "Use the following command to monitor your Rendering Host:" -ForegroundColor Green
Write-Host "docker compose logs -f rendering"
Write-Host ""

################################################
#       6. Option to start headless app
################################################
if(Confirm -Question "Start head (NextJs App)?" -DefaultYes)
{
    Write-Host "starting head" -ForegroundColor Yellow
    Push-Location './src/head'
    pnpm run start
    Pop-Location
}
