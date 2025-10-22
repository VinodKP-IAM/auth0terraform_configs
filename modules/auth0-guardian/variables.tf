variable "settings" {
  description = "A map of all settings for Auth0 Guardian MFA."
  type = object({
    manage = optional(bool, false)
    # --- Required ---
    policy = optional(string) # Required only when manage = true

    # --- Optional Toggles ---
    email         = optional(bool)
    otp           = optional(bool)
    recovery_code = optional(bool)

    # --- Optional MFA Factor Blocks ---
    duo = optional(object({
      enabled         = bool # Required if block is present
      integration_key = optional(string)
      secret_key      = optional(string)
      hostname        = optional(string)
    }))

    phone = optional(object({
      enabled       = bool # Required if block is present
      provider      = optional(string)
      message_types = optional(list(string))
      options = optional(object({
        # Twilio specific
        from                  = optional(string)
        messaging_service_sid = optional(string)
        sid                   = optional(string)
        auth_token            = optional(string)
        # Auth0 specific / General
        enrollment_message   = optional(string)
        verification_message = optional(string)
      }))
    }))

    push = optional(object({
      enabled  = bool # Required if block is present
      provider = optional(string)
      
      amazon_sns = optional(object({
        aws_access_key_id                 = string # Required if block present
        aws_region                        = string # Required if block present
        aws_secret_access_key             = string # Required if block present
        sns_apns_platform_application_arn = string # Required if block present
        sns_gcm_platform_application_arn  = string # Required if block present
      }))
      
      custom_app = optional(object({
        app_name        = optional(string)
        apple_app_link  = optional(string)
        google_app_link = optional(string)
      }))
      
      direct_apns = optional(object({
         bundle_id = string # Required if block present
         p12       = string # Required if block present
         sandbox   = bool   # Required if block present
         enabled   = optional(bool)
      }))

      direct_fcm = optional(object({
        server_key = string # Required if block present
      }))
    }))

    webauthn_platform = optional(object({
      enabled                  = bool # Required if block is present
      override_relying_party = optional(bool)
      relying_party_identifier = optional(string)
    }))

    webauthn_roaming = optional(object({
      enabled                  = bool # Required if block is present
      user_verification        = optional(string)
      override_relying_party = optional(bool)
      relying_party_identifier = optional(string)
    }))
  })
  default = {}
}