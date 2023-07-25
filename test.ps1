$backend_org = "https://dev.azure.com/tfazlab"
$backend_project = "tfazlab"
$backend_projectDesc = "Project to be used in 3StagePipeline HoL"
$backend_RepoName = "tfazlab"
$backend_RepoNameUpd = "3StageTFaz"
$backend_RepoBranch = "main"

az devops configure --defaults organization=$backend_org
az devops configure --defaults project=$backend_project

    Start-Sleep -Seconds 5

Write-Host "Creating Azure DevOps 'Project'..." -ForegroundColor Yellow
az devops project create `
    --name $backend_project `
    --description $backend_projectDesc `
    --org $backend_org `
    --source-control git `
    --visibility private `
    --process 'Basic'

    Start-Sleep -Seconds 5

    Start-Sleep -Seconds 10
    $backend_RepoId = (az repos list `
        --org $backend_org `
        --p $backend_project `
        --q "[?Name=='$backend_RepoName'].Id" -o tsv)

    Start-Sleep -Seconds 5

    az repos update `
        --repository $backend_RepoId `
        --org $backend_org `
        --n $backend_RepoNameUpd `
        --default-branch $backend_RepoBranch 

    $LocalRepoPath = (Get-Location).Path
    git init $LocalRepoPath
    git add -A
    git commit -m "InitialCommit"
    #git branch -M main
    $RemoteRepoURL = (az repos list `
        --project $backend_project `
        --org $backend_org `
        --query "[?name=='$backend_RepoName'].webUrl" -o tsv)
    git remote add origin $RemoteRepoURL
    git push -u origin main