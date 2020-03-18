###########################
## Azure Provider - Main ##
###########################

# Define Terraform provider
terraform {
  required_version = ">= 0.12"
}

# Configure the Azure provider
provider "azurerm" { 
  version = ">= 2.0"
  features {}
  environment     = "public"
}
