variable "settings" {
  description = "A map of all settings for Auth0 Branding."
  type = object({
    manage      = optional(bool, false)
    logo_url    = optional(string)
    favicon_url = optional(string)
    
    colors = optional(object({
      primary         = optional(string)
      page_background = optional(string)
    }))

    font = optional(object({
      url = string # 'url' is required if 'font' block is provided
    }))

    universal_login = optional(object({
      body = string # 'body' is required if 'universal_login' block is provided
    }))
  })
  default = {}
}