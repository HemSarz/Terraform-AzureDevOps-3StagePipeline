Start-Sleep -Seconds 5

Write-Host "Creating Azure DevOps 'Project'..." -ForegroundColor Yellow
az devops project create `
    --name $backend_project `
    --description $backend_projectDesc `
    --org $backend_org `
    --source-control $RepoSourceControl `
    --visibility $RepoVisibility `
    --process $RepoProcess

Write-Host "Project '$backend_project' created successfully." -ForegroundColor Green

Start-Sleep -Seconds 5

$backend_RepoId = (az repos list `
    --org $backend_org `
    --project $backend_project `
    --query "[?name=='$backend_RepoName'].id" -o tsv)

Write-Host "Fetching repository ID for '$backend_RepoName'..." -ForegroundColor Yellow

Start-Sleep -Seconds 5

az repos update `
    --repository $backend_RepoId `
    --org $backend_org `
    --p $backend_project `
    --n $backend_RepoNameUpd `

Write-Host "Repository '$backend_RepoName' updated with name '$backend_RepoNameUpd'..." -ForegroundColor Green

Start-Sleep -Seconds 5

$LocalRepoPath = (Get-Location).Path
git init $LocalRepoPath
git add -A
git commit -m "InitialCommit"

Write-Host "Local Git repository initialized with an initial commit." -ForegroundColor Green

$RemoteRepoURL = (az repos list `
    --project $backend_project `
    --org $backend_org `
    --query "[?name=='$backend_RepoNameUpd'].webUrl" -o tsv)

git remote add origin $RemoteRepoURL
git push -u origin main

Write-Host "Local repository successfully linked with the remote repository." -ForegroundColor Green