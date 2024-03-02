Import-Module -Name (Join-Path $PSScriptRoot "..\common\UI") -Force -DisableNameChecking

Set-StrictMode -Version Latest

function Invoke-NpmInit {	
	param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] 
        $Folder
		)

	Write-Host
    Write-Host "Running pnpm install in $Folder" -ForegroundColor Green

	Show-Command "cd $Folder"
    Push-Location $Folder
	try {
		Show-Command "pnpm i --frozen-lockfile"
		pnpm i --frozen-lockfile
	}
	catch {
		Write-Host
		Write-Host "This project uses pnpm for speed"
		Write-Host
		Write-Host "Installing pnpm..."
		Show-Command 'iwr https://get.pnpm.io/install.ps1 -useb | iex'
		iwr https://get.pnpm.io/install.ps1 -useb | iex
		
		Write-Host
		Write-Host "pnpm installed" -ForegroundColor Green
		
		Write-Host
		throw "You must now close and re-open console, then Try Again"
	}
	finally {
		Pop-Location
	}
}

function Start-Docker {
    param(
        [ValidateNotNullOrEmpty()]
        [string] 
        $DockerRoot = "" # ".\docker"
    )
	
	#[COVEO] {
	#[System.Environment]::SetEnvironmentVariable('CoveoLocalName',$(iex hostname))    
	#Write-Host
    #Write-Host "Coveo Farm Name set to use $([System.Environment]::GetEnvironmentVariable('CoveoLocalName'))" -ForegroundColor Green
	#Write-Host "Purging Deploy folder (to mitigate coveo-init conflict)..." -ForegroundColor Green
	#$cmd = Join-Path $PSScriptRoot '..\..\docker\clean.ps1'
	#Show-Command "Invoke-Expression $cmd"
    #Invoke-Expression $cmd
    #[COVEO] }
	
    if(-not [string]::IsNullOrWhiteSpace($DockerRoot))
    {
		Write-Host
		Write-Host "Entering $DockerRoot" -ForegroundColor Green
		Show-Command "cd $DockerRoot"	
		Push-Location $DockerRoot
	}

	try {
		# PREP
		Write-Host
		Write-Host "PREP: Clearing obstacles..." -ForegroundColor Green

		# STOP local iis service before running docker
		Write-Host
		Write-Host "[iis] Stopping your iis service in order to run docker" -ForegroundColor Green
		Show-Command "iisreset /stop"
		iisreset /stop

		# STOP local solr services before running docker
		Write-Host
		Write-Host "[solr] MANUAL - Please ensure solr is not running locally" -ForegroundColor Green
		# Write-Host "[solr] Scanning any solr or nssm services to stop them in order to run docker" -ForegroundColor Green
			
		Write-Host
		Write-Host "[license] Clearing Sitecore environment license variable to avoid issues..." -ForegroundColor Green
		Show-Command '$Env:Sitecore_License = ""'
		$Env:Sitecore_License = ""

		Invoke-SwitchDockerTo "windows"

		# Start the Sitecore instance
		Write-Host
		Write-Host "Starting Sitecore environment..." -ForegroundColor Green
		Show-Command "docker compose up -d"
		docker compose up -d
	
    } finally {
		if(-not [string]::IsNullOrWhiteSpace($DockerRoot))
		{
			Pop-Location
		}
    }

	Write-Host
	Write-Host "Deploying latest code..." -ForegroundColor Green
	
	Show-Command @'
msbuild .\src\platform\Platform.csproj `
		 /maxCpuCount `
		 /p:Configuration=debug `
		 /p:DeployOnBuild=true `
		 /p:PublishProfile=Local `
		 /nologo `
		 /detailedSummary:False `
		 /verbosity:quiet `
		 /clp:ErrorsOnly
'@
	msbuild .\src\platform\Platform.csproj `
	 /p:Configuration=debug `
	 /m `
	 /p:DeployOnBuild=true `
	 /p:PublishProfile=Local `
	 /nologo `
	 /detailedSummary:False `
	 /verbosity:quiet `
	 /clp:ErrorsOnly;

	# Wait for Traefik to expose CM route
	Write-Host
	Write-Host "Waiting for CM to become available..." -ForegroundColor Green
	Show-Command "Invoke-RestMethod `"http://localhost:8079/api/http/routers/cm-secure@docker`""
	$startTime = Get-Date
	do {
		Start-Sleep -Milliseconds 100
		try {
			$status = Invoke-RestMethod "http://localhost:8079/api/http/routers/cm-secure@docker"
		} catch {
			if ($_.Exception.Response.StatusCode.value__ -ne "404") {
				throw
			}
		}
	} while ($status.status -ne "enabled" -and $startTime.AddSeconds(15) -gt (Get-Date))
	if (-not $status.status -eq "enabled") {
		$status
		Write-Error "Timeout waiting for Sitecore CM to become available via Traefik proxy. Check CM container logs."
	}	
}

function Invoke-SwitchDockerTo {

    param(
        [ValidateNotNullOrEmpty()]
        [string] 
        $mode = "windows"
    )

    $current = docker info -f '{{.OSType}}'

    if($current -ne $mode)
    {
        Write-Host
        Write-Host "Switching Docker from $current to $($mode.ToUpper()) mode" -ForegroundColor Yellow
         & "$($env:ProgramFiles)\\Docker\\Docker\\DockerCli.exe" -SwitchDaemon
        if($mode -eq "windows")
        {
            # allow more time for windows
	        Write-PauseDanceAnim -PauseInSeconds 10
        } else {
	        Write-PauseDanceAnim -PauseInSeconds 5
        }
        Write-Host
    } else {
        Write-Host
        Write-Host "Docker is in $($current.ToUpper()) mode" -ForegroundColor Yellow
    }
}

Export-ModuleMember -Function *