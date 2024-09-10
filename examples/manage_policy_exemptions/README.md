<!-- BEGIN_TF_DOCS -->
# Define exemptions for a policy assignment

This example demonstrates how to create one or more exemption. It is possible to exempt a resource, resource group, subscription or management group from a policy assignment. The exemption category can be set to "Mitigated" or "Waiver".

```hcl
exemptions = [
  {
    resource_id : data.azurerm_virtual_network.test.id
    exemption_category : "Mitigated"
  },
  {
    resource_group_id : data.azurerm_resource_group.test.id
    exemption_category : "Mitigated"
  },
  {
    subscription_id : data.azurerm_client_config.current.subscription_id
    exemption_category : "Mitigated"
  },
  {
    management_group_id = data.azurerm_management_group.root.id
    exemption_category  = "Waiver"
  }
]

```

```hcl
terraform {
  required_version = ">= v1.8"
  required_providers {
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

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}


## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/regions/azurerm"
  version = "~> 0.3"
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(module.regions.regions) - 1
  min = 0
}
## End of section to provide a random Azure region for the resource group

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
}

resource "azurerm_management_group" "root" {
  name = "test-root"
}


module "manage_policy_exemptions" {
  source = "../../"
  # source = "Azure/terraform-azurerm-avm-ptn-policyassignment"
  enable_telemetry = var.enable_telemetry # see variables.tf

  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/d8cf8476-a2ec-4916-896e-992351803c44"
  scope                = azurerm_management_group.root.id
  name                 = "Enforce-GR-Keyvault"
  display_name         = "Keys should have a rotation policy ensuring that their rotation is scheduled within the specified number of days after creation."
  description          = "Keys should have a rotation policy ensuring that their rotation is scheduled within the specified number of days after creation."
  enforce              = "Default"
  location             = module.regions.regions[random_integer.region_index.result].name
  identity             = { "type" = "SystemAssigned" }

  role_assignments = {
    contrib = {
      "role_definition_id_or_name" : "Contributor"
      principal_id : "ignored"
    }
  }
  exemptions = [
    {
      resource_id        = azurerm_management_group.root.id
      exemption_category = "Waiver"
    }
  ]

  parameters = {
    maximumDaysToRotate = {
      value = 90
    }
  }
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= v1.8)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.74)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.5)

## Resources

The following resources are used by this module:

- [azurerm_management_group.root](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group) (resource)
- [random_integer.region_index](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

## Outputs

No outputs.

## Modules

The following Modules are called:

### <a name="module_manage_policy_exemptions"></a> [manage\_policy\_exemptions](#module\_manage\_policy\_exemptions)

Source: ../../

Version:

### <a name="module_naming"></a> [naming](#module\_naming)

Source: Azure/naming/azurerm

Version: ~> 0.3

### <a name="module_regions"></a> [regions](#module\_regions)

Source: Azure/regions/azurerm

Version: ~> 0.3

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->