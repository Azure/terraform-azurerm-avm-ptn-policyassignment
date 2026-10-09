terraform {
  required_version = "~> 1.8"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.12"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.74"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azapi" {}

provider "azurerm" {
  features {}
}

data "azapi_client_config" "current" {}

resource "random_string" "suffix" {
  length  = 6
  lower   = true
  numeric = true
  special = false
  upper   = false
}

resource "azapi_resource" "resource_group" {
  location  = "eastus"
  name      = "rg-policy-${random_string.suffix.result}"
  parent_id = "/subscriptions/${data.azapi_client_config.current.subscription_id}"
  type      = "Microsoft.Resources/resourceGroups@2025-04-01"
}

resource "azapi_resource" "user_assigned_identity" {
  location  = azapi_resource.resource_group.location
  name      = "uami-policy-${random_string.suffix.result}"
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31"
}

module "assign_policy_with_user_assigned_identity" {
  source = "../../"

  location             = azapi_resource.resource_group.location
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/d8cf8476-a2ec-4916-896e-992351803c44"
  scope                = "/subscriptions/${data.azapi_client_config.current.subscription_id}"
  description          = "Keys should have a rotation policy ensuring that their rotation is scheduled within the specified number of days after creation."
  display_name         = "Keys should have a rotation policy ensuring that their rotation is scheduled within the specified number of days after creation."
  enable_telemetry     = var.enable_telemetry
  enforce              = "Default"
  identity = {
    type = "UserAssigned"
    userAssignedIdentities = {
      (azapi_resource.user_assigned_identity.id) = {}
    }
  }
  name = "Enforce-GR-Keyvault"
  parameters = {
    maximumDaysToRotate = {
      value = 90
    }
  }
}
