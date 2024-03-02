# Thank you for code from: https://stackoverflow.com/questions/60048492/how-to-create-a-comment-in-azure-devops-pr-in-case-of-build-failure
param(
    [Parameter(Mandatory=$true)]
    [String]$markdown
)

#Going to create the comment in an Closed status [4] (Active state=1), assuming it needs to be resolved
#See https://learn.microsoft.com/en-us/dotnet/api/microsoft.teamfoundation.sourcecontrol.webapi.commentthreadstatus?view=azure-devops-dotnet
$StatusCode = 4 

#Build the JSON body up
$body = @"
{
    "comments": [
      {
        "parentCommentId": 0,
        "content": "$markdown",
        "commentType": 1
      }
    ],
    "status": $StatusCode 
  }
"@

Write-Debug $Body
#Post the message to the Pull Request
#https://learn.microsoft.com/en-us/rest/api/azure/devops/git/pull%20request%20threads?view=azure-devops-rest-5.1
try {
    $url = "$($env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI)$env:SYSTEM_TEAMPROJECTID/_apis/git/repositories/$($env:Build_Repository_Name)/pullRequests/$($env:System_PullRequest_PullRequestId)/threads?api-version=5.1"
    Write-Host "URL: $url"
    $response = Invoke-RestMethod -Uri $url -Method POST -Headers @{Authorization = "Bearer $env:SYSTEM_ACCESSTOKEN"} -Body $Body -ContentType application/json
  if ($response -ne $Null) {
    Write-Host "*******************Bingo*********************************"
  }
}
catch {
  Write-Error $_
  Write-Error $_.Exception.Message
}