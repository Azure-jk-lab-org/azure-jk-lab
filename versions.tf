terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
    }
    azuread = {
      source = "hashicorp/azuread"
    }
  }
}


provider "azurerm" {
  subscription_id = "7b8f281b-f143-4123-8b55-97ae745df6fa"
  features {}
}
