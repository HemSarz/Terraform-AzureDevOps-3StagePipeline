terraform {
  backend "azurerm" {
  }
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">= 0.6.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.65.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.40.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.1"
    }

    azapi = {
      source  = "azure/azapi"
      version = ">= 1.7.0"
    }

    time = {
      source  = "hashicorp/time"
      version = "0.9.1"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}



#provider "azuredevops" {
# org_service_url       = var.AZDO_ORG_SERVICE_URL
#personal_access_token = var.AZDO_PERSONAL_ACCESS_TOKEN
#}