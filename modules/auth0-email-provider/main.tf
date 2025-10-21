terraform {
  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = "~> 1.0"
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
      condition     = var.settings.credentials != null
      error_message = "When 'manage' is true, the 'credentials' object block is required."
    }
    precondition {
      # Check that 'name' has a valid value
      condition     = var.settings.name == null ? true : contains(["azure_cs", "custom", "mailgun", "mandrill", "ms365", "sendgrid", "ses", "smtp", "sparkpost"], var.settings.name)
      error_message = "Invalid 'name'. Must be one of: azure_cs, custom, mailgun, mandrill, ms365, sendgrid, ses, smtp, sparkpost."
    }
  }
}