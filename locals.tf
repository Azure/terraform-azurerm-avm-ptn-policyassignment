locals {
  policy_exemption_retry = {
    error_message_regex  = ["(?m)^ERROR CODE: CheckAccessPrincipalTokenInvalid\\r?$"]
    interval_seconds     = 75
    max_interval_seconds = 75
  }
  policy_exemption_timeouts = {
    create = "5m"
    read   = null
    update = "5m"
    delete = null
  }
  role_definition_resource_substring = "providers/Microsoft.Authorization/roleDefinitions"
}
