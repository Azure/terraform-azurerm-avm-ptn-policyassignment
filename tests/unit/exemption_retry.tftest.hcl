mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/policyAssignments/retry-test"
    }
  }
}
mock_provider "azurerm" {}
mock_provider "modtm" {}
mock_provider "random" {}
mock_provider "time" {}

variables {
  enable_telemetry     = false
  location             = "eastus"
  name                 = "policy-exemption-retry-test"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/d8cf8476-a2ec-4916-896e-992351803c44"
  scope                = "/subscriptions/00000000-0000-0000-0000-000000000000"
  exemptions = [{
    resource_id        = "/subscriptions/00000000-0000-0000-0000-000000000000"
    exemption_category = "Waiver"
  }]
}

run "retries_only_the_exemption_token_error" {
  command = apply

  assert {
    condition = (
      length(azapi_resource.policy_exemption["0"].retry.error_message_regex) == 1 &&
      alltrue([
        for message in [
          "RESPONSE 409: Conflict\nERROR CODE: CheckAccessPrincipalTokenInvalid\nThe application principal token could not be retrieved or is not valid.",
          "RESPONSE 409: Conflict\r\nERROR CODE: CheckAccessPrincipalTokenInvalid\r\nPlease try again later in 1 minute.",
          "ERROR CODE: CheckAccessPrincipalTokenInvalid",
          ] : anytrue([
            for pattern in azapi_resource.policy_exemption["0"].retry.error_message_regex :
            length(regexall(pattern, message)) > 0
        ])
      ])
    )
    error_message = "The exemption retry rule must match the exact service-token error in Azure's error-code line."
  }

  assert {
    condition = alltrue(flatten([
      for message in [
        "RESPONSE 403: Forbidden\nERROR CODE: AuthorizationFailed\nAccess denied.",
        "RESPONSE 401: Unauthorized\nERROR CODE: InvalidAuthenticationToken",
        "RESPONSE 403: Forbidden\nERROR CODE: Forbidden",
        "RESPONSE 400: Bad Request\nERROR CODE: InvalidRequestContent",
        "RESPONSE 409: Conflict\nERROR CODE: OtherConflict",
        "RESPONSE 409: Conflict\nERROR CODE: CheckAccessPrincipalTokenInvalidAdditional",
        "RESPONSE 403: Forbidden\nERROR CODE: AuthorizationFailed\nThe message mentions CheckAccessPrincipalTokenInvalid.",
        ] : [
        for pattern in azapi_resource.policy_exemption["0"].retry.error_message_regex :
        length(regexall(pattern, message)) == 0
      ]
    ]))
    error_message = "The exemption retry rule must not match unrelated authorization, invalid-input, or conflict errors."
  }

  assert {
    condition = (
      azapi_resource.policy_exemption["0"].retry.interval_seconds == 75 &&
      azapi_resource.policy_exemption["0"].retry.max_interval_seconds == 75 &&
      azapi_resource.policy_exemption["0"].retry.interval_seconds * 0.8 >= 60 &&
      azapi_resource.policy_exemption["0"].timeouts.create == "5m" &&
      azapi_resource.policy_exemption["0"].timeouts.update == "5m" &&
      azapi_resource.policy_exemption["0"].timeouts.read == null &&
      azapi_resource.policy_exemption["0"].timeouts.delete == null
    )
    error_message = "Exemption retries must respect the one-minute delay despite SDK jitter and have finite create/update timeouts."
  }

  assert {
    condition     = azapi_resource.policy_assignment.retry == null && azapi_resource.policy_assignment.timeouts == null
    error_message = "The targeted exemption defaults must not change policy-assignment retry or timeout behavior."
  }
}

run "honors_consumer_retry_and_timeout_overrides" {
  command = apply

  variables {
    retry = {
      error_message_regex  = ["(?m)^ERROR CODE: ScopeLocked\\r?$"]
      interval_seconds     = 90
      max_interval_seconds = 120
    }
    timeouts = {
      create = "6m"
      read   = "1m"
      update = "7m"
      delete = "2m"
    }
  }

  assert {
    condition = alltrue([
      for resource in [azapi_resource.policy_assignment, azapi_resource.policy_exemption["0"]] : (
        jsonencode(resource.retry.error_message_regex) == jsonencode(var.retry.error_message_regex) &&
        resource.retry.interval_seconds == var.retry.interval_seconds &&
        resource.retry.max_interval_seconds == var.retry.max_interval_seconds &&
        resource.timeouts.create == var.timeouts.create &&
        resource.timeouts.read == var.timeouts.read &&
        resource.timeouts.update == var.timeouts.update &&
        resource.timeouts.delete == var.timeouts.delete
      )
    ])
    error_message = "Consumer retry and timeout overrides must reach both AzAPI resource types."
  }
}

run "allows_replacing_the_default_retry_rule" {
  command = apply

  variables {
    retry = {
      error_message_regex = ["^$"]
    }
  }

  assert {
    condition = alltrue([
      for pattern in azapi_resource.policy_exemption["0"].retry.error_message_regex :
      length(regexall(pattern, "ERROR CODE: CheckAccessPrincipalTokenInvalid")) == 0
    ])
    error_message = "An explicit consumer retry rule must replace, not append to, the default exemption-token rule."
  }
}
