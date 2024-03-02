Import-Module -Name (Join-Path $PSScriptRoot "..\common\UI") -Force -DisableNameChecking
Import-Module -Name (Join-Path $PSScriptRoot "..\common\ShowLogo") -Force -DisableNameChecking

Set-StrictMode -Version Latest

# TL;DR
#      Import-Module -Name ".\tools\local\Renamer" -Force -DisableNameChecking
#      Replace-SolutionName "FromOldName" "ToNewName" # Replaces exact matches and lowercase to lowercase variant

##########################################
# Purpose:
#      Rename PROJECTPREFIX or similar term across all types of files
#       > Filenames in solution
#       > Namespaces and references in .cs code and .csproj
#       > Config file references
#       > Serialized data .yml files
#       > React Code
#       > etc

##########################################
# Usage:
#       1. Ensure:
#           a. No pending changes in git - provides an easy way to undo all changes as failback plan
#           b. No files open in any software - VS and VSCode are closed, docker is composed down - avoids lock failures
#       2. Open Powershell terminal at solution root
#       3. Import Module with this command:
#           Import-Module -Name ".\tools\local\Renamer" -Force -DisableNameChecking
#       4. Run Rename with this command:
#           Replace-SolutionName "FromOldName" "ToNewName"
#       5. Review change to ensure coverage and not corruption.
#          While this tool has been used successfully, there are many moving and changing parts. Here are steps to verify a successful bulk rename.
#           a. Check for missed content replacements.
#               Use a tool like Notepad++ to search solution recursively for file contents with old value
#           b. Check for missed file name replacements.
#               Use a tool like Notepad++ to search solution recursively for file names with old value
#           c. Check for unexpected renames.
#               Sample git pending changes to spot any unexpected replacements.

##########################################
# Additional Steps:
#      You may also want to consider running these steps after rename and before step #5
#       - purge old build assets in ./docker/deploy/*:
#           ./docker/clean.ps1
#       - purge persistent image data:
#           ./run/sitecore-xm1-sxa/clean.ps1
#       - rebuilds newly renamed images
#           docker compose build
#       - verify successful build
#           build solution
#           ./init.ps1
#           ./up.ps1

##########################################
# FYI:
#   This script has an Allow List of extensions to process, append values below as solutions evolve.
#
#   This script handles some of the complications to doing solution renames, such as:
#       Avoid system folders like .git, .vscode, .vs, etc
#       Avoid node_modules (takes unnecessary long time and can break things)
#       Respect docker's need for certain terms to be all lowercase
#       Purge obj and bin build assets having old name
#
#   For making placeholder terms that can be replaced later you can:
#       - Use an exact match case: UniqueTerm
#       - Use lowercase match case: uniqueterm
#       - Pick a term that is distinctly unique to avoid unexpected replacements

# Manage Allowed extensions here
New-Variable -Name RenamerAllowedExtensionsList -Value @(
    ".cache"
    ".config"
    ".cs"
    ".cshtml"
    ".csproj"
    ".css"
    ".disabled"
    ".env"
    ".example"
    ".js"
    ".json"
    ".manifest"
    ".md"
    ".ps1"
    ".psm1"
    ".scriban"
    ".scss"
    ".svg"
    ".targets"
    ".ts"
    ".tsx"
    ".user"
    ".xml"
    ".yml"
    "Dockerfile"
    ""
) -Scope Script -Option ReadOnly -Force

# Main Method - Apply replacement to entire solution
function Replace-SolutionName {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] 
        $FromName,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] 
        $ToName
    )

	Show-Logo
    
    Write-Host
    Write-Host "Before continuing, be sure you have:" -ForegroundColor Cyan
    Write-Host " 1. A clean git state, no pending changes." -ForegroundColor Yellow
    Write-Host " 2. Closed all code editors so no files are locked or loaded." -ForegroundColor Yellow
    Write-Host " 3. Composed down your docker containers." -ForegroundColor Yellow
    Read-Host -Prompt "Press any key to continue..."

    Write-Host
    Write-Host "Replacing all occurrences of $FromName with $ToName ..." -ForegroundColor Green	
	
	# Certs	
	if ($(Test-Path -Path '.\docker\traefik\config\dynamic\certs_config.yaml' -PathType Leaf) -and $(Confirm  -Question "Changing Hostname? (which affects Certs)" -DefaultYes))
    {
        Write-Host " > Certificates ..." -ForegroundColor Yellow
        Remove-Files ".\docker\traefik\certs" "*.pem"
        Replace-SolutionName-InFile (Get-Item '.\docker\traefik\config\dynamic\certs_config.yaml') $FromName $ToName
    }

	# Solution file
    Write-Host " > Solution file ..." -ForegroundColor Yellow
	if (Test-Path -Path ".\$FromName.sln" -PathType Leaf) {
		Replace-SolutionName-InFile (Get-Item ".\$FromName.sln") $FromName $ToName
	}
	
	# .env file
    Write-Host " > .env file ..." -ForegroundColor Yellow
	if (Test-Path -Path ".\.env" -PathType Leaf) {
		Replace-SolutionName-InFile (Get-Item ".\.env") $FromName $ToName
	}
	
	# Run Folder
    Write-Host " > Docker Run folder ..." -ForegroundColor Yellow
    Replace-SolutionName-InFolder '.\docker\build' $FromName $ToName

	# Scripts    
    Write-Host " > Scripts ..." -ForegroundColor Yellow
	Replace-SolutionName-InFile (Get-Item '.\init.ps1') $FromName $ToName
	Replace-SolutionName-InFile (Get-Item '.\up.ps1') $FromName $ToName
	Replace-SolutionName-InFile (Get-Item '.\down.ps1') $FromName $ToName
    Replace-SolutionName-InFolder '.\tools\' $FromName $ToName
	if (Test-Path -Path '.\create-jss-project.ps1' -PathType Leaf) {
		Replace-SolutionName-InFile (Get-Item '.\create-jss-project.ps1') $FromName $ToName
	}
    
	# ReadMe
    Write-Host " > README.md ..." -ForegroundColor Yellow
	if (Test-Path -Path '.\README.md' -PathType Leaf)
    {
		Replace-SolutionName-InFile (Get-Item '.\README.md') $FromName $ToName
	}

	# Build Targets
    Write-Host " > Build targets ..." -ForegroundColor Yellow
	if (Test-Path -Path '.\Directory.build.targets' -PathType Leaf)
    {
		Replace-SolutionName-InFile (Get-Item '.\Directory.build.targets') $FromName $ToName
	}
		
	# .sitecore	..hmm better to just delete?
    Write-Host " > .sitecore schema ..." -ForegroundColor Yellow
    Replace-SolutionName-InFolder '.sitecore\' $FromName $ToName
	
	# Source Code	
    Write-Host " > Source code ..." -ForegroundColor Yellow
    Replace-SolutionName-InFolder '.\src\' $FromName $ToName

	# Helix Templates	
	if (Test-Path -Path '.\helix')
    {
        Write-Host " > Helix templates ..." -ForegroundColor Yellow
        Replace-SolutionName-InFolder '.\helix\' $FromName $ToName
    }

    Write-Host "Done" -ForegroundColor Green

    Write-Host
    Write-Host "Consider these next steps:" -ForegroundColor Yellow
    Write-Host
    Write-Host " - purge old build assets in ./docker/deploy/*:"
    Write-Host "     ./docker/clean.ps1" -ForegroundColor Cyan
    Write-Host
    Write-Host " - purge persistent image data:"
    Write-Host "     ./run/sitecore-xm1-sxa/clean.ps1" -ForegroundColor Cyan
    Write-Host
    Write-Host " - rebuild newly renamed images"
    Write-Host "     docker compose build" -ForegroundColor Cyan
    Write-Host
    Write-Host " - verify successful build"
    Write-Host "     build solution"
    Write-Host
}

function Remove-Files {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FolderPath,
        [string]$Filter = "*"
    )
    
    Write-Host "Removing contents of $FolderPath..." -ForegroundColor Gray
	if (Test-Path -Path $FolderPath)
    {
        $files = Get-ChildItem -Path $FolderPath -Filter $Filter -Force

        foreach ($file in $files) {
            try {
                Remove-Item -Path $file.FullName -Force -Recurse
                Write-Host "Removed file: $($file.Name)" -ForegroundColor Gray
            } catch {
                Write-Host "Failed to remove file: $($file.Name)" -ForegroundColor Red
                Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
}

# Make replacements in directory
function Replace-SolutionName-InFolder {
	param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] 
        $FolderPath,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] 
        $FromName,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] 
        $ToName
    )
	Get-ChildItem $FolderPath -Recurse | ForEach {
		if($_ -is [System.IO.DirectoryInfo])
        {
            # Rename directories
            if($_.FullName -like "*$($FromName)*")
            {
                Rename-Item $_.FullName ($_.FullName -replace $FromName, $ToName)
            }
            elseif($_.Name -eq ".next")
            { # Remove all CLI cache files
                Write-Host "Clearing .next directory: $($_.FullName)" -ForegroundColor Gray
			    Remove-Item -Path $_.FullName -Force -Recurse;
            }
            elseif($_.Name -eq ".next-container")
            { # Remove all CLI cache files
                Write-Host "Clearing .next-container directory: $($_.FullName)" -ForegroundColor Gray
			    Remove-Item -Path $_.FullName -Force -Recurse;
            }
        }
        elseif( $_.FullName -like "*\node_modules\*" )
        {
            # Do nothing, skip this folder			
        }
        elseif( ($_.FullName -like "*\bin\*") -or ($_.FullName -like "*\obj\*") )
        {
            # Clean bin and obj noise
            if($_.Name -like "*$($FromName)*")
            {
			    Remove-Item -Path $_.FullName -Force;
            }
        }
        elseif($_.extension -in $RenamerAllowedExtensionsList)
        {
            # Handle code files
            Replace-SolutionName-InFile $_ $FromName $ToName
        }
        elseif($_.Name -eq ".scindex")
        { # Remove all CLI cache files
            Write-Host "Removed cache file: $($_.FullName)" -ForegroundColor Gray
			Remove-Item -Path $_.FullName -Force;
        }
        if($_.extension -eq ".csproj" -or $_.name -eq "HPP.Identity")
        { # Purge Obj and Debug from csproj directories (keeping any lib bin folders safe)
            Remove-Files $(Join-Path $_.Directory.FullName "obj")
            Remove-Files $(Join-Path $_.Directory.FullName "bin")
        }
	}
}

# Make replacements in file
function Replace-SolutionName-InFile {	
	param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo] 
        $File,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] 
        $FromName,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] 
        $ToName
		)
		$FromFile = "$($File.DirectoryName)\$($File.Name)";
		$ToFile = "$($File.DirectoryName)\$($File.Name -replace $FromName, $ToName)";

        # Replace file contents
        # This way was messing with line endings, causing needless source control changes
		# (Get-Content $FromFile) -replace $FromName, $ToName | Set-Content $ToFile

        # This way did not mess up file endings
        $content = [System.IO.File]::ReadAllText($FromFile)

        if(($FromFile -ne $ToFile) -or ($content.contains($FromName)) -or ($content.contains($FromName.ToLower())))
        {
            $content = $content.Replace($FromName.ToLower(),$ToName.ToLower()).Replace($FromName,$ToName) # handle exact match and lowercase match (for docker and hostnames and such)
            [System.IO.File]::WriteAllText($ToFile, $content)

            # Remove old file (when new file was renamed)
		    if($FromFile -ne $ToFile)
		    {
			    Remove-Item -Path $FromFile -Force;
		    }
        }
}

Export-ModuleMember -Function *
