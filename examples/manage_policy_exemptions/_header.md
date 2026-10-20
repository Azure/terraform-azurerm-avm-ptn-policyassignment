# Define exemptions for a policy assignment

This example demonstrates how to create one or more exemption. It is possible to exempt a resource, resource group, subscription or management group from a policy assignment. The exemption category can be set to "Mitigated" or "Waiver".

The example creates a uniquely named child management group beneath the existing `avm-test` management group. Set `parent_management_group_id` to the full resource ID of another existing parent. The deployment identity needs permission to create child management groups and manage policy assignments, exemptions, and role assignments beneath that parent.

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
