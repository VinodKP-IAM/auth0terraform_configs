terraform {
  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = "~> 1.0"
    }
  }
}

resource "auth0_attack_protection" "this" {
  # The "on/off" toggle
  count = var.settings.manage ? 1 : 0

  # --- Suspicious IP Throttling ---

  dynamic "suspicious_ip_throttling" {

    for_each = var.settings.suspicious_ip_throttling == null ? [] : [var.settings.suspicious_ip_throttling]
    
    content {
      enabled   = suspicious_ip_throttling.value.enabled
      allowlist = suspicious_ip_throttling.value.allowlist
      shields   = suspicious_ip_throttling.value.shields

      # --- Nested Dynamic Block for pre_login ---
      dynamic "pre_login" {
        for_each = suspicious_ip_throttling.value.pre_login == null ? [] : [suspicious_ip_throttling.value.pre_login]
        content {
          max_attempts = pre_login.value.max_attempts
          rate         = pre_login.value.rate
        }
      }

      # --- Nested Dynamic Block for pre_user_registration ---
      dynamic "pre_user_registration" {
        for_each = suspicious_ip_throttling.value.pre_user_registration == null ? [] : [suspicious_ip_throttling.value.pre_user_registration]
        content {
          max_attempts = pre_user_registration.value.max_attempts
          rate         = pre_user_registration.value.rate
        }
      }
    }
  }

  # --- Brute Force Protection ---
  dynamic "brute_force_protection" {
    for_each = var.settings.brute_force_protection == null ? [] : [var.settings.brute_force_protection]
    content {
      enabled      = brute_force_protection.value.enabled
      allowlist    = brute_force_protection.value.allowlist
      max_attempts = brute_force_protection.value.max_attempts
      mode         = brute_force_protection.value.mode
      shields      = brute_force_protection.value.shields
    }
  }

  # --- Breached Password Detection ---
  dynamic "breached_password_detection" {
    for_each = var.settings.breached_password_detection == null ? [] : [var.settings.breached_password_detection]
    content {
      enabled                      = breached_password_detection.value.enabled
      admin_notification_frequency = breached_password_detection.value.admin_notification_frequency
      method                       = breached_password_detection.value.method
      shields                      = breached_password_detection.value.shields

      # --- Nested Dynamic Block for pre_change_password ---
      dynamic "pre_change_password" {
        for_each = breached_password_detection.value.pre_change_password == null ? [] : [breached_password_detection.value.pre_change_password]
        content {
          shields = pre_change_password.value.shields
        }
      }

      # --- Nested Dynamic Block for pre_user_registration ---
      dynamic "pre_user_registration" {
        for_each = breached_password_detection.value.pre_user_registration == null ? [] : [breached_password_detection.value.pre_user_registration]
        content {
          shields = pre_user_registration.value.shields
        }
      }
    }
  }

  # --- Add Logical Validation ---
  lifecycle {
    precondition {
      # Check that 'mode' has a valid value if it's provided
      condition     = var.settings.brute_force_protection == null ? true : (var.settings.brute_force_protection.mode == null ? true : contains(["count_per_identifier_and_ip", "count_per_identifier"], var.settings.brute_force_protection.mode))
      error_message = "Invalid value for brute_force_protection.mode. Must be 'count_per_identifier_and_ip' or 'count_per_identifier'."
    }
    precondition {
      # Check that 'method' has a valid value if it's provided
      condition     = var.settings.breached_password_detection == null ? true : (var.settings.breached_password_detection.method == null ? true : contains(["standard", "enhanced"], var.settings.breached_password_detection.method))
      error_message = "Invalid value for breached_password_detection.method. Must be 'standard' or 'enhanced'."
    }
  }
}