# This block is required in every module
terraform {
  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = "~> 1.0"
    }
  }
}


resource "auth0_tenant" "this" {
  # The toggle is now just a direct attribute
  count = var.settings.manage ? 1 : 0

  # We access the attributes directly.
  # If an optional attribute (like 'picture_url') isn't provided,
  # its value is 'null', and Terraform resource arguments
  # automatically ignore 'null' values. This is perfect.
  friendly_name       = var.settings.friendly_name
  support_email       = var.settings.support_email
  session_lifetime    = var.settings.session_lifetime
  picture_url         = var.settings.picture_url
  allowed_logout_urls = var.settings.allowed_logout_urls

  # --- Here is where we add your LOGICAL validation ---
  lifecycle {
    precondition {
      # This checks the value, not just the type.
      condition     = var.settings.session_lifetime == null ? true : var.settings.session_lifetime > 0
      error_message = "session_lifetime must be a positive number."
    }
    
    precondition {
      # This checks for a valid email format.
      condition     = var.settings.support_email == null ? true : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.settings.support_email))
      error_message = "support_email must be a valid email address."
    }
  }
}