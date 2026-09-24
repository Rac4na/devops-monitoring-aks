terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.56.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  resource_provider_registrations = "none"
  features {}
  subscription_id = "e3397c4a-0aab-4d1a-8d2d-68380faf6e56"
}
