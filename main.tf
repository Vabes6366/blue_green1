terraform {
  required_version = ">=1.3.7"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~>3.5.1"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.37.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstate2207"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}

  subscription_id = "4c0e37c0-6ce9-4f7a-b165-37ef3b6c5bfd"
}

resource "random_pet" "rg_name" {
    length = 2
    separator = "-"
}
  


resource "azurerm_resource_group" "rg" {
  name     = "${random_pet.rg_name.id}-rg"
  location = "centralindia"
}

resource "azurerm_app_service_plan" "asp" {
  name                = "example-appserviceplan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "App"

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "as" {
  name                ="${random_pet.rg_name.id}-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.asp.id


}

resource "azurerm_app_service_slot" "slot" {
  name                = "${random_pet.rg_name.id}-slot"
  app_service_name    = azurerm_app_service.as.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.asp.id
}

resource "azurerm_app_service_source_control" "scm" {
  app_id   = azurerm_app_service.as.id
  repo_url = "https://github.com/Vabes6366/blue_green"
  branch   = "master"
}

resource "azurerm_app_service_source_control_slot" "scm1" {
  slot_id = azurerm_app_service_slot.slot.id
  repo_url = "https://github.com/Vabes6366/blue_green"
  branch   = "appServiceSlot_Working_DO_NOT_MERGE"
}
