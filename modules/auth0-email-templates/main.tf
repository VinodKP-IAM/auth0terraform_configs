terraform {
  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = "~> 1.0"
    }
  }
}

resource "auth0_email_template" "this" {
  for_each = var.settings.manage ? var.settings.templates : {}

  # --- Required Arguments ---
  template = each.value.template
  body     = each.value.body
  from     = each.value.from
  subject  = each.value.subject
  syntax   = each.value.syntax
  enabled  = each.value.enabled

  # --- Optional Arguments ---
  include_email_in_redirect = each.value.include_email_in_redirect
  result_url                = each.value.result_url
  url_lifetime_in_seconds   = each.value.url_lifetime_in_seconds

  # --- Logical Validation ---
  lifecycle {
    precondition {
      condition     = contains(["liquid", "text"], each.value.syntax)
      error_message = "Invalid 'syntax' for template ${each.key}. Must be 'liquid' or 'text'."
    }
    precondition {
      condition = contains([
        "verify_email", "verify_email_by_code", "reset_email", "reset_email_by_code",
        "welcome_email", "blocked_account", "stolen_credentials", "enrollment_email",
        "mfa_oob_code", "user_invitation", "change_password", "password_reset", "async_approval"
      ], each.value.template)
      error_message = "Invalid 'template' name for template ${each.key}. See Auth0 documentation for valid names."
    }
  }
}