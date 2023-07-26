############################################ 
# Set Azure the resource variables
############################################

$backend_spn = "tfazinfra"
$backend_spn_role = "Contributor"
$backend_rg = "backend-tf-rg"
$backend_stg = "backendstgtf"
$backend_stg_sku = "Standard_LRS"
$backend_cont = "backendcont"
$backend_location = "norwayeast"
$backendAzureRmKey = "terraform.tfstate"

############################################ 
# SPN | Permissions VB
############################################

$MSGraphApi = "00000003-0000-0000-c000-000000000000" # MS Graph API Id
$appDirRoleId = "19dbc75e-c2e2-444c-a770-ec69d8559fc7=Role" # Directory.ReadWrite.All | 'Delete users' not allowed' https://graphpermissions.merill.net/permission/Directory.ReadWrite.All
$appUsrRoleId = "741f803b-c850-494e-b5df-cde7c675a1ca=Role" # User.ReadWrite.All | This role is needed to delete AD Users
#$scope = "Directory.ReadWrite.All"

##################################################################
# Key Vault variables | Generate a random number between 1 and 999
##################################################################

$randomNumber = Get-Random -Minimum 1 -Maximum 999
# Create the backend_kv variable with a random name
$backend_kv = "backend-tfaz-kv$('{0:D3}' -f $randomNumber)"

# Key Vault Secret Names
$backend_AZDOSrvConnName_kv_sc = "AZDOName"
$backend_RGName_kv_sc = "RGName"
$backend_STGName_kv_sc = "STGName"
$backend_ContName_kv_sc = "ContName"
$backendAzureRmKey_kv_sc = "TFStatefileName"
$backend_SUBid_Name_kv_sc = "SUBidName"
$backend_TNTid_Name_kv_sc = "TNTidName"
$backend_STGPass_Name_kv_sc = "STGPass"
$backend_SPNPass_Name_kv_sc = "SPNPass"
$backend_SPNappId_Name_kv_sc = "SPNappId"

############################################ 
# Set the Azure DevOps organization and project details
############################################

# Azure DevOps 'Project' Variables
$backend_org = "https://dev.azure.com/tfazlab"
$backend_project = "tfazlab"
$backend_projectDesc = "Project to be used in 3StagePipeline HoL"

# Set the variable group details
$backend_VBGroup = "hawaVB"
$description = "backendVB"

# Azure DevOps Service Connection Variables
$backend_AZDOSrvConnName = 'azdo-tfaz-conn'

# Repository variables
$backend_RepoName = "tfazlab"
$backend_RepoNameUpd = "3StageTFaz"
$RepoSourceControl = "git"
$RepoVisibility = "private"
$RepoProcess = "Basic"

# Pipeline variables
$backend_PipeDesc = "Pipeline for running 3 stage pipeline in 'tfazlab' project"
$backend_PipeBuild_Name = "TFaz-Build-Pipe"
$backend_PipeDest_Name = "Tfaz-Destroy-Pipe"
$backend_tfdest_yml = "tfaz_destroy.yml"
$backend_tfaz_build_yml = "3stagedeploy.yml"
$PipeSkipFirstRun = "true"
$PipeRepositoryType = "tfsgit"
$PipeBranch = "main"

############################################ 
# Azure resource configuration
############################################

Write-Host "Retrieving Azure Ids..." -ForegroundColor Green
# Retrieve AZ IDs
$backend_SUBid = $(az account show --query 'id' -o tsv)
$backend_SUBName = $(az account show --query 'name' -o tsv)
$backend_TNTid = $(az account show --query 'tenantId' -o tsv)

Start-Sleep -Seconds 5

Write-Host "Creating service principal..." -ForegroundColor Yellow
$backend_SPNPass = $(az ad sp create-for-rbac `
        --name $backend_spn `
        --role $backend_spn_role `
        --scope /subscriptions/$backend_SUBid `
        --query 'password' -o tsv)

Start-Sleep -Seconds 5

$env:AZURE_DEVOPS_EXT_AZURE_RM_SERVICE_PRINCIPAL_KEY = $backend_SPNPass

Start-Sleep -Seconds 5

Write-Host "Creating resource group..." -ForegroundColor Yellow
az group create `
    --name $backend_rg `
    --location $backend_location

Write-Host "Creating storage account..." -ForegroundColor Yellow
az storage account create `
    --resource-group $backend_rg `
    --name $backend_stg `
    --sku $backend_stg_sku `
    --encryption-services blob

$backend_STGPass = $(az storage account keys list `
        --resource-group $backend_rg `
        --account-name $backend_stg `
        --query "[0].value" -o tsv)

Start-Sleep -Seconds 5

Write-Host "Creating storage container..." -ForegroundColor Yellow
az storage container create `
    --name $backend_cont `
    --account-name $backend_stg `
    --account-key $backend_STGPass

Start-Sleep -Seconds 5

Write-Host "Creating the Key Vault..." -ForegroundColor Yellow
az keyvault create `
    --resource-group $backend_rg `
    --name $backend_kv `
    --location $backend_location

Start-Sleep -Seconds 5

Write-Host "Allowing the Service Principal Access in Key Vault..." -ForegroundColor Yellow
$backend_SPNappId = $(az ad sp list `
        --display-name $backend_spn `
        --query '[0].appId' -o tsv)

$backend_SPNid = $(az ad sp show `
        --id $backend_SPNappId `
        --query id -o tsv)

Start-Sleep -Seconds 5

az keyvault set-policy `
    --name $backend_kv `
    --object-id $backend_SPNid `
    --secret-permissions get list set delete purge

Start-Sleep -Seconds 10

Write-Host "Assign SPN AD Permissions..." -ForegroundColor Yellow

Write-Host 'Assign permission appDir...' -ForegroundColor Green
az ad app permission add `
    --id $backend_SPNappId `
    --api $MSGraphApi `
    --api-permissions $appDirRoleId

Start-Sleep -Seconds 20

Write-Host 'Assign permission appUsr...' -ForegroundColor Green
az ad app permission add `
    --id $backend_SPNappId `
    --api $MSGraphApi `
    --api-permissions $appUsrRoleId

Start-Sleep -Seconds 20

Write-Host 'Add Permission grant...' -ForegroundColor Green
az ad app permission grant `
    --id $backend_SPNappId `
    --api $MSGraphApi

Start-Sleep -Seconds 20

Write-Host 'Add admin-consent' -ForegroundColor Green
az ad app permission admin-consent --id $backend_SPNappId

Start-Sleep -Seconds 5

Write-Host "Storing Azure DevOps Service Connection Name in Key Vault..." -ForegroundColor Yellow
az keyvault secret set `
    --vault-name $backend_kv `
    --name $backend_AZDOSrvConnName_kv_sc `
    --value $backend_AZDOSrvConnName

Start-Sleep -Seconds 5

Write-Host "Storing Resource Group Name in Key Vault..." -ForegroundColor Yellow
az keyvault secret set `
    --vault-name $backend_kv `
    --name $backend_RGName_kv_sc `
    --value $backend_rg

Start-Sleep -Seconds 5

Write-Host "Storing Storage Account Password in Key Vault..." -ForegroundColor Yellow
az keyvault secret set `
    --vault-name $backend_kv `
    --name $backend_STGPass_Name_kv_sc `
    --value $backend_stg

Start-Sleep -Seconds 5

Write-Host "Storing Container Name in Key Vault..." -ForegroundColor Yellow
az keyvault secret set `
    --vault-name $backend_kv `
    --name $backend_ContName_kv_sc `
    --value $backend_cont

Start-Sleep -Seconds 5

Write-Host "Storing Azure Resource Manager Key in Key Vault..." -ForegroundColor Yellow
az keyvault secret set `
    --vault-name $backend_kv `
    --name $backendAzureRmKey_kv_sc `
    --value $backendAzureRmKey

Start-Sleep -Seconds 5

Write-Host "Storing Subscription ID in Key Vault..." -ForegroundColor Yellow
az keyvault secret set `
    --vault-name $backend_kv `
    --name $backend_SUBid_Name_kv_sc `
    --value $backend_SUBid

Start-Sleep -Seconds 5

Write-Host "Storing Tenant ID in Key Vault..." -ForegroundColor Yellow
az keyvault secret set `
    --vault-name $backend_kv `
    --name $backend_TNTid_Name_kv_sc `
    --value $backend_TNTid

Start-Sleep -Seconds 5

Write-Host "Storing the Storage Account Access Key in Key Vault..." -ForegroundColor Yellow
az keyvault secret set `
    --vault-name $backend_kv `
    --name $backend_STGPass_Name_kv_sc `
    --value $backend_STGPass

Start-Sleep -Seconds 5

Write-Host "Storing the Storage Account Name in Key Vault..." -ForegroundColor Yellow
az keyvault secret set `
    --vault-name $backend_kv `
    --name $backend_STGName_kv_sc `
    --value $backend_stg

Start-Sleep -Seconds 5

Write-Host "Storing SPN Password in Key Vault..." -ForegroundColor Yellow
az keyvault secret set `
    --vault-name $backend_kv `
    --name $backend_SPNPass_Name_kv_sc `
    --value $backend_SPNPass

Start-Sleep -Seconds 5

Write-Host "Storing SPN appId..." -ForegroundColor Yellow 
az keyvault secret set `
    --vault-name $backend_kv `
    --name $backend_SPNappId_Name_kv_sc `
    --value $backend_SPNappId

Start-Sleep -Seconds 5

############################################ 
# AZURE DEVOPS configuration
############################################

az devops configure --defaults organization=$backend_org
az devops configure --defaults project=$backend_project

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

Start-Sleep -Seconds 10

Write-Host "(Create &) Initialize Azure DevOps 'Repository'..." -ForegroundColor Yellow
# use this to create a new repo | Remove "#"
#az devops repo create `
#  --name $backend_RepoName `
# --description $backend_RepoDesc `
# --detect false `
# --open false `
# --org $backend_org `
# --project $backend_project

# Use this to initialize the 'Standard' repo which is created with the project

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
    --n $backend_RepoNameUpd ` ## Using --n/--name $repoName to update the name

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

Start-Sleep -Seconds 5

Write-Host "Creating Azure DevOps service endpoint..." -ForegroundColor Yellow
az devops service-endpoint azurerm create `
    --azure-rm-service-principal-id $backend_SPNappId `
    --azure-rm-subscription-id $backend_SUBid `
    --azure-rm-subscription-name $backend_SUBName `
    --azure-rm-tenant-id $backend_TNTid `
    --name $backend_AZDOSrvConnName `
    --org $backend_org `
    --p $backend_project

Start-Sleep -Seconds 5

Write-Host "Creating the variable group..." -ForegroundColor Yellow
az pipelines variable-group create `
    --organization $backend_org `
    --project $backend_project `
    --name $backend_VBGroup `
    --description $description `
    --variables foo=bar `
    --authorize true

$backend_VBGroupID = $(az pipelines variable-group list `
        --organization $backend_org `
        --p $backend_project `
        --query "[?name=='$backend_VBGroup'].id" -o tsv)

az pipelines variable-group update `
    --id $backend_VBGroupID `
    --org $backend_org `
    --p $backend_project `
    --authorize true

Start-Sleep -Seconds 5

Write-Host "Creating pipeline for tfazlab project..." -ForegroundColor Yellow
az pipelines create `
    --name $backend_PipeBuild_Name `
    --description $backend_PipeDesc `
    --detect false `
    --repository $backend_RepoNameUpd `
    --branch $PipeBranch `
    --yml-path $backend_tfaz_build_yml `
    --repository-type $PipeRepositoryType `
    --skip-first-run $PipeSkipFirstRun
    
Start-Sleep -Seconds 10

Write-Host "Create TF Destroy pipeline for tfazlab project" -ForegroundColor Yellow
az pipelines create `
    --name $backend_PipeDest_Name `
    --description $backend_PipeDesc `
    --detect false `
    --repository $backend_RepoNameUpd `
    --branch $PipeBranch `
    --yml-path $backend_tfdest_yml `
    --repository-type $PipeRepositoryType `
    --skip-first-run $PipeSkipFirstRun

Start-Sleep -Seconds 10

Write-Host "Retrieve the correct project ID To Be Used By Azure DevOps Service Endpoint..." -ForegroundColor Yellow
$backend_proj_Id = (az devops project show `
        --p $backend_project `
        --org $backend_org `
        --q 'id' -o tsv)

Write-Host "Allowing AZDO ACCESS..." -ForegroundColor Yellow
$backend_EndPid = (az devops service-endpoint list `
        --query "[?name=='$backend_AZDOSrvConnName'].id" -o tsv)

Start-Sleep -Seconds 5

az devops service-endpoint update `
    --detect false `
    --id $backend_EndPid `
    --org $backend_org `
    --p $backend_proj_Id `
    --enable-for-all true `
    --debug

Write-Host "Done!" -ForegroundColor Green