variable "settings" {
  description = "A map of all settings for Auth0 Attack Protection."
  type = object({
    manage = optional(bool, false)

    suspicious_ip_throttling = optional(object({
      enabled = bool
      allowlist = optional(list(string))
      shields = optional(list(string))
      pre_login = optional(object({
        max_attempts = optional(number)
        rate         = optional(number)
      }))
      pre_user_registration = optional(object({
        max_attempts = optional(number)
        rate         = optional(number)
      }))
    }))

    brute_force_protection = optional(object({
      enabled      = bool
      allowlist    = optional(list(string))
      max_attempts = optional(number)
      mode         = optional(string)
      shields      = optional(list(string))
    }))

    breached_password_detection = optional(object({
      enabled                      = bool
      admin_notification_frequency = optional(list(string))
      method                       = optional(string)
      shields                      = optional(list(string))
      pre_change_password = optional(object({
        shields = optional(list(string))
      }))
      pre_user_registration = optional(object({
        shields = optional(list(string))
      }))
    }))
  })
  default = {}
}