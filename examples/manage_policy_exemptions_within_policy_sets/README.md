<!-- BEGIN_TF_DOCS -->
# Define exemptions for a policy within an initiative

Often, policies are grouped into initiatives. To assign an exemption only for one policy within an initative, we can set the parameter policy\_definition\_reference\_ids.
This example demonstrates how to create one exemption. It is possible to exempt a resource, resource group, subscription or management group from a policy assignment. The exemption category can be set to "Mitigated" or "Waiver". The resource will be exempted for all policies which are named in the policy\_definition\_reference\_ids.

```hcl
exemptions = [
  {
    resource_id : data.azurerm_client_config.current.subscription_id
    exemption_category : "Waived"
    policy_definition_reference_ids : ["AddUserAssignedManagedIdentity_VMSS"]
  }
]

```

```hcl
terraform {
  required_version = "~> v1.8.0"
  # required_version = "~> v1.9.0-alpha20240501"
  # required_version = "~> v1.9.0"
  # experiments      = [template_string_func]
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
  features {}
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

data "azurerm_management_group" "root" {
  name = "root"
}

data "azurerm_client_config" "current" {}

module "test_management_group" {
  source = "../../"
  # source             = "Azure/avm-<res/ptn>-<name>/azurerm"
  default_location = module.regions.regions[random_integer.region_index.result].name

  enable_telemetry = var.enable_telemetry # see variables.tf

  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/f5bf694c-cca7-4033-b883-3a23327d5485"
  management_group_ids = [data.azurerm_management_group.root.id]
  name                 = "Azure-Monitor-AMA"
  display_name         = "Enable Azure Monitor for VMSS with Azure Monitoring Agent(AMA)"
  description          = "Enable Azure Monitor for the virtual machines scale set (VMSS) with AMA."
  enforce              = "Default"
  location             = module.regions.regions[random_integer.region_index.result].name
  identity             = { "type" = "SystemAssigned" }

  exemptions = [
    {
      resource_id : "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
      exemption_category : "Waiver"
      policy_definition_reference_ids : ["AddUserAssignedManagedIdentity_VMSS"]
    }
  ]
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> v1.8.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.74)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.5)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 3.74)

- <a name="provider_random"></a> [random](#provider\_random) (~> 3.5)

## Resources

The following resources are used by this module:

- [random_integer.region_index](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) (resource)
- [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [azurerm_management_group.root](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/management_group) (data source)

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

### <a name="module_naming"></a> [naming](#module\_naming)

Source: Azure/naming/azurerm

Version: ~> 0.3

### <a name="module_regions"></a> [regions](#module\_regions)

Source: Azure/regions/azurerm

Version: ~> 0.3

### <a name="module_test_management_group"></a> [test\_management\_group](#module\_test\_management\_group)

Source: ../../

Version:

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->