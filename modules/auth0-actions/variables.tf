variable "settings" {
  description = "A map of all settings for Auth0 Actions."

  type = object({
    manage = optional(bool, false)
    
    # 'actions' is a map where each key is a logical name (e.g., "login_action")
    actions = optional(map(object({
      # --- Required ---
      name = string
      code = string
      supported_triggers = object({ # Max: 1, so a single object is simplest
        id      = string
        version = string
      })

      # --- Optional ---
      deploy  = optional(bool)
      runtime = optional(string)
      
      dependencies = optional(list(object({
        name    = string
        version = string
      })))
      
      secrets = optional(list(object({
        name  = string
        value = string
      })))
    })), {})
  })
  
  default = {}
}