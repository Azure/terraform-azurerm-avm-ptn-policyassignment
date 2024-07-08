resource "random_id" "telem" {
  count = var.enable_telemetry ? 1 : 0

  byte_length = 4
}

# # This is the module telemetry deployment that is only created if telemetry is enabled.
# this works for subscription but now for resource group
resource "azapi_resource" "telemetry" {
  count = var.enable_telemetry ? 1 : 0

  type = "Microsoft.Resources/deployments@2024-03-01"
  body = jsonencode({
    properties = {
      mode       = "Incremental"
      parameters = {}
      template   = jsondecode(local.telem_arm_template_content)
    }
  })
  # location  = var.location # not allowed if scope is resource group
  location  = var.location
  name      = local.telem_arm_deployment_name
  parent_id = var.scope
  tags      = null
}

# resource "azurerm_management_group_template_deployment" "telemetry_mg" {
#   for_each = tomap({
#     for vi, v in var.management_group_ids :
#     vi => v if var.enable_telemetry
#   })

#   location            = var.location
#   management_group_id = each.value
#   name                = local.telem_arm_deployment_name
#   tags                = null
#   template_content    = local.telem_arm_template_content
# }


# resource "azurerm_subscription_template_deployment" "telemetry_sub" {
#   for_each = tomap({
#     for vi, v in var.subscription_ids :
#     vi => v if var.enable_telemetry
#   })

#   location         = var.location
#   name             = local.telem_arm_deployment_name
#   tags             = null
#   template_content = local.telem_arm_template_content
# }

# resource "azurerm_resource_group_template_deployment" "telemetry_rg" {
#   for_each = tomap({
#     for vi, v in var.resource_group_ids :
#     vi => v if var.enable_telemetry
#   })

#   deployment_mode     = "Incremental"
#   name                = local.telem_arm_deployment_name
#   resource_group_name = split("/", each.value)[4]
#   tags                = null
#   template_content    = local.telem_arm_template_content
# }

# resource "azurerm_resource_group_template_deployment" "telemetry_resource" {
#   for_each = tomap({
#     for vi, v in var.resource_ids :
#     vi => v if var.enable_telemetry
#   })

#   deployment_mode     = "Incremental"
#   name                = local.telem_arm_deployment_name
#   resource_group_name = split("/", each.value)[4]
#   tags                = null
#   template_content    = local.telem_arm_template_content
# }
