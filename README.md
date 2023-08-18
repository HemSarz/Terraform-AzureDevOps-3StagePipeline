# Terraform-AzureDevOps-3StagePipeline
![Azure DevOps](https://img.shields.io/badge/Azure%20DevOps-%E2%9C%93-blue)
![Terraform](https://img.shields.io/badge/Terraform-IaaC-blue?logo=checkmarx)
![Azure](https://img.shields.io/badge/Azure-%E2%9C%93-blue)
![PowerShell](https://img.shields.io/badge/PowerShell-%E2%9C%93-blue)

### Terraform Infrastructure Deployment and Azure DevOps Integration

This repository contains the Terraform configuration files and scripts required for deploying the infrastructure components on Azure. The infrastructure is created using Terraform and provisioned using Azure DevOps pipeline for automating the deployment process.

## Table of Contents
- [Terraform Infrastructure Deployment and Azure DevOps Integration](#terraform-infrastructure-deployment-and-azure-devops-integration)
- [Project Structure](#project-structure)
- [Deployment Process](#deployment-process)
  - [Prerequisites](#prerequisites)
  - [Backend Configuration](#backend-configuration)
      - [Link the Variable Group to the Azure Key Vault](#link-the-variable-group-to-the-azure-key-vault)
  - [Deploy Azure infrastructure](#deploy-azure-infrastructure)
      - [Verify Provisioned Azure Resources](#verify-provisioned-azure-resources)
- [Resource Cleanup](#resource-cleanup)
    - [Execute The Destroy Pipeline](#execute-the-destroy-pipeline)
    - [Azure DevOps Cleanup](#azure-devops-cleanup)
    - [Verify Provisioned Azure Resources](#verify-provisioned-azure-resources)


## Project Structure

The repository has the following folder structure:

```
. Terraform-AzureDevOps-3StagePipeline [=WorkingDirectory]
├── .gitignore
│   # Gitignore file to specify which files and directories to ignore in version control.
│
├── 3stagedeploy.yml
│   # Terraform deployment YAML file for the 3-stage pipeline.
│
├── admin_user.tf
│   # Terraform code for creating the admin user.
│
├── All.tfs_in_a_single_file.tf.txt
│   # Text file containing all Terraform configurations in a single file (example file).
│
├── data.tf
│   # Terraform code for defining data sources.
│
├── DLpreconfigres.ps1
│   # PowerShell script for destroying preconfig resources.
│
├── gitpushcmds.ps1
│   # PowerShell script with Git push commands.
│
├── key_vault_secrets.tf
│   # Terraform code for creating the secrets in the Azure Key Vault.
│
├── key_vault.tf
│   # Terraform code for creating the Azure Key Vault.
│
├── network_interface_security_group_association.tf
│   # Terraform code for associating the Network Security Group with the network interface.
│
├── network_interface.tf
│   # Terraform code for creating the network interface.
│
├── network_security_group.tf
│   # Terraform code for creating the Network Security Group.
│
├── preconfigres.ps1
│   # PowerShell script for setting up the backend [to store terraform state file remotely]
│
├── provider.tf
│   # Terraform provider configuration file.
│
├── public_ip.tf
│   # Terraform code for creating the public IP address.
│
├── resource_group.tf
│   # Terraform code for creating the Azure Resource Group.
│
├── storage_account.tf
│   # Terraform code for creating the Azure Storage Account.
│
├── storage_container.tf
│   # Terraform code for creating the Azure Storage Container.
│
├── tfaz_destroy_without_artifact.yml
│   # Terraform destroy YAML file without using artifact.
│
├── tfaz_destroy.yml
│   # Terraform destroy YAML file[3Stages]
│
├── variables.tf
│   # This file defines the input variables used in the Terraform configuration.
│
├── virtual_machine.tf
│   # Terraform code for creating the Azure Virtual Machine.
│
├── virtual_network_subnet.tf
│   # Terraform code for creating the subnets within the Azure Virtual Network.
│
├── virtual_network.tf
    # Terraform code for creating the Azure Virtual Network
```
# Deployment Process
### Prerequisites:

- Clone the repo to the IDE of your choice or create the files manually.

### Backend Configuration

Before deploying the infrastructure, you need to set up the backend configuration and create the required Azure resources.

Use the `preconfigres.ps1` script to automate this process. 

The script will:
1. Create a `service principal` with the required permissions.
2. Create an `Azure Resource Group` and `Storage Account` for the Terraform backend.
3. Create a `Key Vault` and sets access policies for the service principal.
4. Create and stores the `Azure DevOps Service Connection` details and other required secrets in the Key Vault.
5. Create an grant for the `Azure DevOps Service Connection` to access Azure using the `SPN`.
6. Create an `Project` to deploy the infrastructure.
7. Create an `Repository` which stores all the files needed to create the Azure infrastructure.
6. Create two `Pipelines` which will be used to create and destroy the infrastructure.
7. Create and updates a `Variable group` to store `Key Vault secrets` to be used by the pipeline.

##### Link the `variable group` to the Azure Key Vault
   1. In the Azure DevOps project > `Pipelines` > `Library`.
   2. Click on `Variable Group`.
   3. In the Variable Group settings, click on `Link secrets from an Azure key vault as variables`.
   4. Select the the Azure DevOps `Service-Connection` and the `Key Vault` that holds the secrets you want to retrieve.
   5. Select the secrets.
   6. Save the settings in the Variable Group.

### Deploy Azure infrastructure 

The pipeline `TFAZ-Build-Pipe` includes the following main stages:

- `Trigger Configuration`: Triggers pipeline on changes to specific files in the main branch.
- `Variables Definition`: Defines variables for Terraform, Azure DevOps, and working directories.
- `Parameters Definition`: Customizes the pipeline with environment and action selections.
- `Publish Plan Stage`: Validates and publishes the Terraform plan.
- `Build Artifact Plan Stage`: Create artifact for the Terraform plan.
- `Deploy Stage`: Applies the Terraform plan to deploy infrastructure.

#### Execute the pipeline:

1. Navigate to the Azure DevOps project > `Pipelines` > `All` > `TFAZ-Build-Pipe`.
3. Click the `Run pipeline` button on the top-right.
5. Click `Run` to start the pipeline manually.
6. During the pipeline execution, you will be prompted to approve the deployment to `dev`.

### Verify Provisioned Azure Resources

After successfully running the deployment pipeline, you can verify that the Azure resources were created based on the instructions provided in the sections above.

1. Navigate to the `Azure portal` > `Resource Group` to ensure all resources have been provisioned correctly.
3. Check for the existence of the following Azure resources:
   - Azure Storage Account
   - Storage Container
   - Azure Key Vault
   - Virtual Network
   - Subnets
   - Network Security Group
   - Network Interface
   - Public IP
   - Virtual Machine

# Resource Cleanup

#### Azure Resources to be Destroyed [ `tfaz_destroy.yml` ]

When the destroy pipeline is manually triggered and approved, the following Azure resources will be destroyed:

1. `Resource Group`: The entire resource group along with all the resources contained within it will be deleted.
2. `Azure Storage Account`: The specified storage account and all its associated data will be permanently removed.
3. `Storage Container`: Any containers present within the storage account will be deleted.
4. `Azure Key Vault`: The Azure Key Vault and all its stored secrets will be permanently destroyed.
5. `Virtual Network`: The defined virtual network and all its associated subnets will be deleted.
6. `Virtual Machine (Windows-based)`: The specified virtual machine instance will be permanently removed, including its OS disk.
7. `Public IP`: The public IP address associated with the virtual machine will be released.
8. `Network Security Group`: The network security group and its associated rules will be deleted.
9. `Network Interface`: The network interface attached to the virtual machine will be removed.
10. `Remaining Resource Groups`: Any remaining resource groups (if any) and their associated resources will be permanently deleted.
11. `Active Directory (AD) User`: The AD User will be removed.

## Execute The Destroy Pipeline

To manually trigger the `Destroy pipeline` in Azure DevOps:

1. Navigate to project's "Pipelines" section.
2. Choose `All` > Click on the `TFAZ-Destroy-Pipe` pipeline.
3. Click the `Run pipeline` button on the top-right.
5. Click `Run` to start the pipeline manually.

## Azure DevOps Cleanup

Clean up Azure DevOps resources using the script `DLpreconfigres.ps1`. 

This script will perform the following actions:

1. Delete the `Azure AD user`.
2. Delete the `Azure Resource Group` and all resources provisioned within it.
3. Delete the `Azure AD application` & `Service Principal`
4. Delete Azure DevOps `Project`  including: `service connection`, `variable group`, `repo` and `pipelines`.

##### Acknowledgement

The pipeline yml is based on a template created by [Arindam Mitra](https://dev.to/arindam0310018). The original template can be found [here](https://dev.to/arindam0310018/terraform-plan-in-devops-gui-52fp).