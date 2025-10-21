variable "settings" {
  description = "A map of all settings for the Auth0 prompts."

  type = object({
    manage                       = optional(bool, false)
    universal_login_experience = optional(string, "new")
    identifier_first           = optional(bool, true)
    webauthn_platform_first_factor = optional(bool, false)
  })

  default = {}

  # --- Add Logical Validation ---
  validation {
    # Check that universal_login_experience is one of the allowed values
    condition     = var.settings.universal_login_experience == null ? true : contains(["classic", "new"], var.settings.universal_login_experience)
    error_message = "universal_login_experience must be 'classic' or 'new'."
  }
}