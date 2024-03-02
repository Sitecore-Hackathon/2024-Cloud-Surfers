![Hackathon Logo](docs/images/hackathon.png?raw=true "Hackathon Logo")

# Sitecore Hackathon 2024

-   MUST READ: **[Submission requirements](SUBMISSION_REQUIREMENTS.md)**
-   [Entry form template](ENTRYFORM.md)

## Team name

<img src="https://github.com/Sitecore-Hackathon/2024-Cloud-Surfers/blob/main/src/datasyncapp/public/logo-h.png?raw=true" width="350" alt="Cloud Surfers Logo"/>

## Category

Best Module for XM/XP or XM Cloud

## Description

This is an XM Cloud Module to provide a dashboard for non-technical users to trigger automation flows via Webhooks to systems like Sitecore Connect.

There are three components to this submission:

-   Sitecore data
-   NextJS Dashboard App
    -   /src/datasyncapp
    -   Uses [Sitecore Blok](https://blok.sitecore.com)
-   Sitecore Connect Recipes
    -   Import CSV Job
    -   Export CSV Job

## Video link

⟹ [XM Cloud Module Demo](XXX)

## Pre-requisites and Dependencies

-   Sitecore XM Cloud
-   Sitecore Connect
-   Node.js 18+

## Installation instructions

### 1. Update the /src/datasyncapp/.env file

#### GraphQL Endpoint

The /src/datasyncapp/.env file needs two values:

1. GraphQL Endpoint
2. XM Cloud Access Token

To get the **GraphQL Endpoint**, visit this URL: https://deploy.sitecorecloud.io

Click on the your project.
![GraphQL1](docs/images/GraphQL_1.png?raw=true "GraphQL1")

Then, click on the name of your project under the "Environments tab"
![GraphQL2](docs/images/GraphQL_2.png?raw=true "GraphQL2")

Finally, click on the "Details" tab and copy the link from the bottom, where it says "Authoring GraphQL IDE". This is your **GraphQL Endpoint**.
![GraphQL3](docs/images/GraphQL_3.png?raw=true "GraphQL3")

To get your **XM Cloud Access Token**, follow these instructions:
https://doc.sitecore.com/xmc/en/developers/xm-cloud/walkthrough--enabling-and-authorizing-requests-to-the-authoring-and-management-api.html#obtain-an-access-token

Add both the **GraphQL Endpoint** and the **XM Cloud Access Token** into your /src/datasyncapp/.env file

### 2. Install data package on XM Cloud

Install the [CloudSurfersDataPack-1.0.zip](/install/CloudSurfersDataPack-1.0.zip) Sitecore package within the XM Cloud environment

This data package adds items to these locations:

-   /templates/Modules/DataSync
-   /templates/Project/Hackaton
-   /system/Modules/DataSync

\*See Appendix for manually syncing data

## Usage instructions

### Run App Locally

Open up a command prompt and navigate to the root of the project. \
Run: `cd ./src/datasyncapp`

Within this directory, run: \
`npm install`

Then run: \
`npm run dev`

You will be greeted by this dashboard
![DataSync_App](docs/images/DataSync_App.png?raw=true "DataSync_App")

This tool lets you file any webhook registered to the dashboard. \
We have included two examples:

1. Import data from a CSV into XM Cloud
2. Export that data from XM Cloud to a CSV which we've uploaded to Sitecore's Media Library

This tool also notifies you if the job has run successfully, as well as let you know the Last Run time.

---

### Appendix:

#### Developer Notes for serializing data to/from XM Cloud

1. Look up your project ID in XM Cloud portal

2. Use it to list your environment ids: (from top level solution root) \
   `dotnet sitecore cloud environment list --project-id <YOUR-PROJECT-ID>`

3. Use your environment id to connect: \
   `dotnet sitecore cloud environment connect --environment-id <YOUR-ENVIRONMENT-ID>`

4. Edit your .sitecore/user.json \
   Set `"allowWrite":true` for your desired endpoint

5. Run data push: \
   `dotnet sitecore serialization push -n development`

6. Similary, to serialize from XM Cloud: \
   `dotnet sitecore serialization pull -n development`
