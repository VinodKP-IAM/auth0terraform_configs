terraform {
  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = "~> 1.0"
    }
  }
}

# Local values for dependency management
locals {
  # Determine if we need to create the action - credentials can be empty for custom providers
  create_action = (
    var.settings.manage && 
    var.settings.name == "custom" && 
    var.settings.custom_action != null
  )

  # Track action ID when it exists
  action_dependency = local.create_action ? auth0_action.custom_email_provider_action[0].id : null

  # Custom provider requires special handling for credentials
  is_custom_provider = var.settings.name == "custom"
}

# Custom email provider action (required for custom email providers)
resource "auth0_action" "custom_email_provider_action" {
  # Only create if we determined we need the action
  count = local.create_action ? 1 : 0

  name    = var.settings.custom_action.name
  runtime = var.settings.custom_action.runtime
  deploy  = var.settings.custom_action.deploy
  code    = var.settings.custom_action.code

  supported_triggers {
    id      = "custom-email-provider"
    version = "v1"
  }

  lifecycle {
    precondition {
      condition     = var.settings.name == "custom" ? var.settings.custom_action != null : true
      error_message = "When 'name' is 'custom', the 'custom_action' configuration is required."
    }
  }
}

resource "auth0_email_provider" "this" {
  # The "on/off" toggle
  count = var.settings.manage ? 1 : 0

  # These are required by the resource, so we pass them directly.
  # The precondition below will ensure they are not null.
  name                 = var.settings.name
  default_from_address = var.settings.default_from_address
  enabled              = var.settings.enabled

  # Always depend on the action resource - it's safe because the action uses count
  # If count=0, the dependency is still valid but the resource won't exist
  depends_on = [auth0_action.custom_email_provider_action]

  # 'credentials' is a required block (Min: 1)
  dynamic "credentials" {
    # If 'credentials' is null, this creates an empty list.
    # The precondition will catch this and report a clear error.
    for_each = var.settings.credentials == null ? [] : [var.settings.credentials]
    content {
      access_key_id     = credentials.value.access_key_id
      secret_access_key = credentials.value.secret_access_key
      region            = credentials.value.region
      api_key           = credentials.value.api_key
      azure_cs_connection_string = credentials.value.azure_cs_connection_string
      domain            = credentials.value.domain
      ms365_client_id     = credentials.value.ms365_client_id
      ms365_client_secret = credentials.value.ms365_client_secret
      ms365_tenant_id     = credentials.value.ms365_tenant_id
      smtp_host         = credentials.value.smtp_host
      smtp_port         = credentials.value.smtp_port
      smtp_user         = credentials.value.smtp_user
      smtp_pass         = credentials.value.smtp_pass
    }
  }

  # 'settings' is an optional block
  dynamic "settings" {
    for_each = var.settings.provider_settings == null ? [] : [var.settings.provider_settings]
    content {
      dynamic "headers" {
        for_each = settings.value.headers == null ? [] : [settings.value.headers]
        content {
          x_mc_view_content_link  = headers.value.x_mc_view_content_link
          x_ses_configuration_set = headers.value.x_ses_configuration_set
        }
      }
      dynamic "message" {
        for_each = settings.value.message == null ? [] : [settings.value.message]
        content {
          configuration_set_name = message.value.configuration_set_name
          view_content_link      = message.value.view_content_link
        }
      }
    }
  }

  # --- Logical Validation ---
  lifecycle {
    precondition {
      condition     = var.settings.name != null
      error_message = "When 'manage' is true, the 'name' attribute is required (e.g., 'smtp', 'ses', 'sendgrid')."
    }
    precondition {
      condition     = var.settings.default_from_address != null
      error_message = "When 'manage' is true, the 'default_from_address' attribute is required."
    }
    precondition {
      # Credentials are required except for custom providers
      condition     = !var.settings.manage || local.is_custom_provider || var.settings.credentials != null
      error_message = "When 'manage' is true and not using a custom provider, the 'credentials' object block is required."
    }
    precondition {
      # Check that 'name' has a valid value
      condition     = var.settings.name == null ? true : contains(["azure_cs", "custom", "mailgun", "mandrill", "ms365", "sendgrid", "ses", "smtp", "sparkpost"], var.settings.name)
      error_message = "Invalid 'name'. Must be one of: azure_cs, custom, mailgun, mandrill, ms365, sendgrid, ses, smtp, sparkpost."
    }
    precondition {
      # For custom providers, ensure the action exists and is properly configured
      condition     = var.settings.name != "custom" || (var.settings.custom_action != null && local.action_dependency != null)
      error_message = "Custom email provider requires the action to be created first. Check that custom_action is properly configured."
    }
  }
}