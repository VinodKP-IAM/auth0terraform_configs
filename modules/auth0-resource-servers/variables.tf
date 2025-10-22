variable "settings" {
  description = "A map of all settings for Auth0 Resource Servers."
  type = object({
    manage = optional(bool, false)
    servers = optional(map(object({
      # --- Required ---
      identifier = string

      # --- Optional Top-Level ---
      name                                            = optional(string)
      allow_offline_access                            = optional(bool)
      consent_policy                                  = optional(string)
      enforce_policies                                = optional(bool)
      signing_alg                                     = optional(string)
      signing_secret                                  = optional(string)
      skip_consent_for_verifiable_first_party_clients = optional(bool)
      token_dialect                                   = optional(string)
      token_lifetime                                  = optional(number)
      token_lifetime_for_web                          = optional(number)
      verification_location                           = optional(string)

      # --- Optional Nested Blocks ---
      authorization_details = optional(list(object({
        disable = optional(bool)
        type    = optional(string)
      })))

      proof_of_possession = optional(object({
        disable   = optional(bool)
        mechanism = optional(string)
        required  = optional(bool)
      }))

      subject_type_authorization = optional(object({
        client = optional(object({
          policy = optional(string)
        }))
        user = optional(object({
          policy = optional(string)
        }))
      }))

      token_encryption = optional(object({
        disable = optional(bool)
        format  = optional(string)
        encryption_key = optional(object({
          algorithm = string # Required if block is present
          pem       = string # Required if block is present
          kid       = optional(string)
          name      = optional(string)
        }))
      }))
    })), {})
  })
  default = {}
}