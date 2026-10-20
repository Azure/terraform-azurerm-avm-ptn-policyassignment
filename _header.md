# Terraform Verified Module for applying Azure Poliecs

This module is designed to simplify the assignment of policies.

## AzureRM v4

This module and its examples require AzureRM v4. When upgrading from v3, update the caller's provider requirement and reinitialize the provider dependencies. Configure the subscription using the provider's `subscription_id` argument or `ARM_SUBSCRIPTION_ID`; v4 no longer selects it implicitly from Azure CLI. Resource addresses and module inputs are unchanged.

## Policy exemption retries

Policy exemptions add a retry rule for `CheckAccessPrincipalTokenInvalid`, with a 75-second base interval/cap and five-minute create/update timeouts. The SDK's calculated retry delay is at least one minute; provider-native `Retry-After` handling still applies. Other authorization, invalid-input, and conflict errors do not match this rule, and persistent failures remain errors. The `retry` and `timeouts` inputs override these defaults. Policy assignments retain provider defaults unless overridden.
