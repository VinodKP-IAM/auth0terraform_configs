terraform {
  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = "~> 1.0"
    }
  }
}

resource "auth0_branding" "this" {
  # The "on/off" toggle
  count = var.settings.manage ? 1 : 0

  # --- Top-level settings ---

  logo_url    = var.settings.logo_url
  favicon_url = var.settings.favicon_url

  # --- Nested 'colors' block ---
  dynamic "colors" {

    for_each = var.settings.colors == null ? [] : [var.settings.colors]
    content {
      primary         = colors.value.primary
      page_background = colors.value.page_background
    }
  }

  # --- Nested 'font' block ---
  dynamic "font" {
    for_each = var.settings.font == null ? [] : [var.settings.font]
    content {
      url = font.value.url
    }
  }

  # --- Nested 'universal_login' block ---
  dynamic "universal_login" {
    for_each = var.settings.universal_login == null ? [] : [var.settings.universal_login]
    content {
      body = universal_login.value.body
    }
  }
}