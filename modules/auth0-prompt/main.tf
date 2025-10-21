# This block is required in every module
terraform {
  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = "~> 1.0"
    }
  }
}

resource "auth0_prompt" "this" {
  # The "on/off" toggle
  count = var.settings.manage ? 1 : 0

  universal_login_experience     = var.settings.universal_login_experience
  identifier_first               = var.settings.identifier_first
  webauthn_platform_first_factor = var.settings.webauthn_platform_first_factor
}