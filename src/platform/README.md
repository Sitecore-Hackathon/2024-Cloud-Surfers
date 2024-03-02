
[//]: # "--help"
[< Back](../../README.md) to Repo README.md

# Sitecore Platform Project

This Visual Studio / MSBuild project is used to deploy code, configuration, and data
to XMCloud.

> [!IMPORTANT] XMCloud uses separate versions of dlls (Sitecore.Kernel.dll) than XM/XP

It is important to use the proper XMCloud nuget packages.

## Quick Start

1. In an ADMIN terminal:

    ```ps1
    .\init.ps1 -InitEnv -LicenseXmlPath "C:\path\to\license.xml" -AdminPassword "b"
    ```

2. Restart your terminal and run:

    ```ps1
    .\up.ps1
    ```

*** 

## Local Deployments and Debugging


To deploy configuration, assemblies, and content from this project into your running Docker
environment, run a Publish of it from Visual Studio. To debug, you can attach to
the `w3wp` process within the `cm` container.


## XM Cloud Deployments

This project contains an [Azure DevOps pipeline](../../azure-pipelines.yml) for steps to deploy to XM Cloud, managed by Azure DevOps.

As an overview, calling `dotnet sitecore cloud deployment ...` runs all the magic:
  - Deploys the configs and dlls from Platform.csproj
  - Takes the Sitecore Serialization files and bakes them into an Items as a Resource layer
  - Deploys the Next.js app to an internal rendering host (for page editor)

The **xmcloud.build.json** file is important to define the location and details of the Next.js app.

> The platform project must be named **Platform.csproj** for deployment command to work

***

## Docker

Sitecore provides windows based Docker images for local containerized development.
This allows isolated development from XM Cloud instance. Often you can develop directly against XM Cloud without needing the isolation.

| File                            | Purpose |
| ------------------------------- | ------- |
| **.env**                        | Variables available to docker-compose files |
| **docker-compose.yml**          | Base Sitecore container solution (best not to edit). This is the default file used when running `docker compose up` |
| **docker-compose.override.yml** | `docker compose up` merges this file with docker-compose.yml. This file contains solution specific extensions and modifications. |
| /docker                         | Space for Docker related things. (The above three are not in here, so you can run `docker compose` commands from the root folder) |
| /docker/build/**                | Location of Dockerfile and assets for layered extensions to base images |
| /docker/data/**                 | Persistent data locations. These volume mounts maintain your data state. Wiping these reverts back to initial vanilla state. |
| /docker/clean.ps1               | Run this (while containers are down) to wipe data folders, reverting back to initial state. |
| /docker/deploy/platform/**      | Docker for Windows does not support volume mounts where the container side has contents. <br /> So, for deploying to IIS website folder in container Sitecore provides this folder which maps to an empty folder in the container which smartly syncs to its IIS website folder. <br /> Any file added here is deployed to cm app. <br /> This is the VS publishing target of the Platform project.
| /docker/traefik/**              | [Traefik](https://traefik.io/traefik/) allows us to use local hostnames instead of just ports. It also handles SSL termination, and so uses this area for the cert store and certs. These files are generated as part of the init.ps1 run.
| **init.ps1**                    | This is a one time script needed to run. It: <br /> + downloads Sitecore powershell tools, <br /> + adds host names to the local host file (C:\Windows\System32\drivers\etc\hosts) <br /> + creates certs for https (under /docker/traefik/certs) <br /> + downloads and builds docker containers <br /> + and inits .env vars <br /> It is safe to run multiple times, can be used to reset instance (option to clear data).|
| **up.ps1**                      | Run this to spin up local environment. See [Troubleshooting Docker](https://doc.sitecore.com/xp/en/developers/103/developer-tools/troubleshooting-docker.html) for common issues. |
| **down.ps1**                    | Run this to spin down local environment. |
| /tools/local/**                 | Imported scripts for init/up/down to keep them cleaner |
| .dockerignore                   | Used by Docker to exclude files and directories from the context that is sent to the Docker daemon during the build process. <br /> **Important to exclude** irrelevant areas to keep memory usage down during build. |

***

## Other Files

Sitecore provides windows based Docker images for local containerized development.

| File                      | Purpose |
| ------------------------- | ------- |
| .gitignore                | Control which files are excluded from source control. |
| Directory.Build.targets   | Default MSBuild items, properties, and targets inherited to all csproj files |
| New-EdgeToken.ps1         | Optional tool to [generate edge token](https://doc.sitecore.com/xmc/en/developers/xm-cloud/generate-an-edge-token.html) for GraphQL API endpoint |
| nuget.config              | Register Sitecore's Nuget Package feeds. |
| **Packages.props**        | Central control of Nuget Package versions used in C# projects |
| upFunctions.ps1           | Helper function from Sitecore to validate license file |
| **XmCloudSXAStarter.sln** | Visual Studio solution to configure and extend XM Cloud platform instance |


***

## Front-end App

See the [Next.js app ReadMe](../head/README.md) for more info there.