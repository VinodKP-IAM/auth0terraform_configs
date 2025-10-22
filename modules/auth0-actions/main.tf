terraform {
  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = "~> 1.0"
    }
  }
}

resource "auth0_action" "this" {
  # If 'manage' is true, loop over the 'actions' map.
  for_each = var.settings.manage ? var.settings.actions : {}

  # --- Required Arguments ---
  name = each.value.name
  code = each.value.code

  # --- Required Block (Max 1) ---
  # We access this directly since we defined it as a single object
  supported_triggers {
    id      = each.value.supported_triggers.id
    version = each.value.supported_triggers.version
  }

  # --- Optional Arguments ---
  deploy  = each.value.deploy
  runtime = each.value.runtime

  # --- Optional 'dependencies' Block Set ---
  dynamic "dependencies" {
    # If the list is null, iterate over [], creating 0 blocks
    for_each = each.value.dependencies == null ? [] : each.value.dependencies
    content {
      name    = dependencies.value.name
      version = dependencies.value.version
    }
  }

  # --- Optional 'secrets' Block Set ---
  dynamic "secrets" {
    for_each = each.value.secrets == null ? [] : each.value.secrets
    content {
      name  = secrets.value.name
      value = secrets.value.value
    }
  }

  # --- Logical Validation ---
  lifecycle {
    precondition {
      # Check for valid runtime values
      condition     = each.value.runtime == null ? true : contains(["node12", "node16", "node18", "node22"], each.value.runtime)
      error_message = "Invalid 'runtime' for action ${each.key}. Must be one of: node12, node16, node18, node22."
    }
  }
}