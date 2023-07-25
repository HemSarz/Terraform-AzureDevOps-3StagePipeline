$backend_org = "https://dev.azure.com/tfazlab"
$backend_project = "tfazlab"
$vackend_projectDesc = "Project to be used in 3StagePipeline HoL"

az devops configure --defaults organization=$backend_org
az devops configure --defaults project=$backend_project

    Start-Sleep -Seconds 5

Write-Host "Creating Azure DevOps 'Project'..." -ForegroundColor Yellow
az devops project create `
    --name $backend_project `
    --description $vackend_projectDesc `
    --org $backend_org `
    --source-control git `
    --visibility private `
    --process 'Basic'

    Start-Sleep -Seconds 10

    $LocalRepoPath = (Get-Location).Path
    git init $LocalRepoPath
    git add -A
    git commit -m "InitialCommit"
    git branch -M main
    $RemoteRepoURL = (az repos list `
        --project $backend_project `
        --org $backend_org `
        --query "[?name=='$backend_RepoName'].webUrl" -o tsv)
    git remote add origin $RemoteRepoURL
    git push -u origin main