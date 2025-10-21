variable "settings" {
  description = "A map of all settings for Auth0 Email Templates."

  type = object({
    manage    = optional(bool, false)
    templates = optional(map(object({
      template                  = string
      body                      = string
      from                      = string
      subject                   = string
      syntax                    = string
      enabled                   = bool
      include_email_in_redirect = optional(bool)
      result_url                = optional(string)
      url_lifetime_in_seconds   = optional(number)
    })), {}) # Defaults to an empty map of templates
  })
  
  default = {}
}