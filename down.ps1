Import-Module -Name (Join-Path $PSScriptRoot "tools\common\ShowLogo") -Force -DisableNameChecking
Import-Module -Name (Join-Path $PSScriptRoot "tools\common\UI") -Force -DisableNameChecking
Import-Module SitecoreDockerTools -RequiredVersion $dockerToolsVersion -DisableNameChecking

################################################
# SCRIPT PURPOSE:
#       1. Compose down docker containers
#       2. Prune docker system
################################################

Show-Logo

################################################
# Compose Down
################################################

Write-Host "Down containers..." -ForegroundColor Green
try {
  Show-Command "docker compose down"
  docker compose down
  if ($LASTEXITCODE -ne 0) {
    Write-Error "Container down failed, see errors above."
  }
  
  ################################################
  # Toggle app between xmcloud and local cm
  ################################################
  $localEnv = '.\src\head\.env.local'
  
  if (Test-Path "$localEnv")
  {    
      Write-Host "Restoring app endpoints to use XM Cloud" -ForegroundColor Yellow
      
      Set-EnvFileVariable "SITECORE_API_HOST" -Value 'https://xmc-americaneag7f3a-ahmedplaygr2f13-development.sitecorecloud.io' -Path "$localEnv"
      Set-EnvFileVariable "GRAPH_QL_ENDPOINT" -Value 'https://xmc-americaneag7f3a-ahmedplaygr2f13-development.sitecorecloud.io/sitecore/api/graph/edge' -Path "$localEnv"
      Set-EnvFileVariable "SITECORE_EDGE_CONTEXT_ID" -Value '4Pdx204bQtHszJrDYRM9J0' -Path "$localEnv"
      Set-EnvFileVariable "SITECORE_EDGE_URL" -Value 'https://edge-platform.sitecorecloud.io' -Path "$localEnv"
  }


  ################################################
  # Prune
  ################################################
  Write-Host
  Write-Host "Docker system prune..." -ForegroundColor Yellow
  Show-Command "docker system prune -f"
  docker system prune -f

}
finally {
}
