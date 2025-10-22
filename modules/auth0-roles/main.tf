terraform {
  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = "~> 1.0"
    }
  }
}

resource "auth0_role" "this" {
  # If 'manage' is true, loop over the 'roles' map.
  # If 'manage' is false, loop over an empty map.
  for_each = var.settings.manage ? var.settings.roles : {}

  # --- Required Arguments ---
  name = each.value.name

  # --- Optional Arguments ---
  description = each.value.description
}