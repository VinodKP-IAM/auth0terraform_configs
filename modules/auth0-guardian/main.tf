terraform {
  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = "~> 1.0"
    }
  }
}

resource "auth0_guardian" "this" {
  # The "on/off" toggle
  count = var.settings.manage ? 1 : 0

  # --- Required Arguments ---
  # Precondition below ensures this isn't null when manage=true
  policy = var.settings.policy

  # --- Optional Arguments ---
  email         = var.settings.email
  otp           = var.settings.otp
  recovery_code = var.settings.recovery_code

  # --- Optional Dynamic Blocks ---
  dynamic "duo" {
    for_each = var.settings.duo == null ? [] : [var.settings.duo]
    content {
      enabled         = duo.value.enabled
      integration_key = duo.value.integration_key
      secret_key      = duo.value.secret_key
      hostname        = duo.value.hostname
    }
  }

  dynamic "phone" {
    for_each = var.settings.phone == null ? [] : [var.settings.phone]
    content {
      enabled       = phone.value.enabled
      provider      = phone.value.provider
      message_types = phone.value.message_types
      
      dynamic "options" {
        for_each = phone.value.options == null ? [] : [phone.value.options]
        content {
          from                  = options.value.from
          messaging_service_sid = options.value.messaging_service_sid
          sid                   = options.value.sid
          auth_token            = options.value.auth_token
          enrollment_message   = options.value.enrollment_message
          verification_message = options.value.verification_message
        }
      }
    }
  }

  dynamic "push" {
    for_each = var.settings.push == null ? [] : [var.settings.push]
    content {
      enabled  = push.value.enabled
      provider = push.value.provider

      dynamic "amazon_sns" {
        for_each = push.value.amazon_sns == null ? [] : [push.value.amazon_sns]
        content {
          aws_access_key_id                 = amazon_sns.value.aws_access_key_id
          aws_region                        = amazon_sns.value.aws_region
          aws_secret_access_key             = amazon_sns.value.aws_secret_access_key
          sns_apns_platform_application_arn = amazon_sns.value.sns_apns_platform_application_arn
          sns_gcm_platform_application_arn  = amazon_sns.value.sns_gcm_platform_application_arn
        }
      }
      
      dynamic "custom_app" {
         for_each = push.value.custom_app == null ? [] : [push.value.custom_app]
         content {
            app_name = custom_app.value.app_name
            apple_app_link = custom_app.value.apple_app_link
            google_app_link = custom_app.value.google_app_link
         }
      }

      dynamic "direct_apns" {
         for_each = push.value.direct_apns == null ? [] : [push.value.direct_apns]
         content {
            bundle_id = direct_apns.value.bundle_id
            p12 = direct_apns.value.p12
            sandbox = direct_apns.value.sandbox
            enabled = direct_apns.value.enabled
         }
      }

      dynamic "direct_fcm" {
         for_each = push.value.direct_fcm == null ? [] : [push.value.direct_fcm]
         content {
            server_key = direct_fcm.value.server_key
         }
      }
    }
  }

  dynamic "webauthn_platform" {
    for_each = var.settings.webauthn_platform == null ? [] : [var.settings.webauthn_platform]
    content {
      enabled                  = webauthn_platform.value.enabled
      override_relying_party = webauthn_platform.value.override_relying_party
      relying_party_identifier = webauthn_platform.value.relying_party_identifier
    }
  }

  dynamic "webauthn_roaming" {
    for_each = var.settings.webauthn_roaming == null ? [] : [var.settings.webauthn_roaming]
    content {
      enabled                  = webauthn_roaming.value.enabled
      user_verification        = webauthn_roaming.value.user_verification
      override_relying_party = webauthn_roaming.value.override_relying_party
      relying_party_identifier = webauthn_roaming.value.relying_party_identifier
    }
  }

  # --- Logical Validation ---
  lifecycle {
    precondition {
      condition     = var.settings.manage ? var.settings.policy != null : true
      error_message = "When 'manage' is true, the 'policy' attribute is required."
    }
    precondition {
      condition     = var.settings.policy == null ? true : contains(["never", "all-applications", "confidence-score"], var.settings.policy)
      error_message = "Invalid 'policy'. Must be one of: never, all-applications, confidence-score."
    }
    precondition {
      condition     = var.settings.phone == null ? true : (var.settings.phone.provider == null ? true : contains(["auth0", "twilio", "phone-message-hook"], var.settings.phone.provider))
      error_message = "Invalid 'phone.provider'. Must be one of: auth0, twilio, phone-message-hook."
    }
     precondition {
      condition     = var.settings.push == null ? true : (var.settings.push.provider == null ? true : contains(["direct", "guardian", "sns"], var.settings.push.provider))
      error_message = "Invalid 'push.provider'. Must be one of: direct, guardian, sns."
    }
     precondition {
      condition     = var.settings.webauthn_roaming == null ? true : (var.settings.webauthn_roaming.user_verification == null ? true : contains(["discouraged", "preferred", "required"], var.settings.webauthn_roaming.user_verification))
      error_message = "Invalid 'webauthn_roaming.user_verification'. Must be one of: discouraged, preferred, required."
    }
  }
}