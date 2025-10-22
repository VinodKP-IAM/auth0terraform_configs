variable "settings" {
  description = "A map of all settings for Auth0 Roles."

  type = object({
    manage = optional(bool, false)
    
    # 'roles' is a map where each key is a logical name (e.g., "admin_role")
    # and the value is the object defining that role.
    roles = optional(map(object({
      name        = string
      description = optional(string)
    })), {})
  })
  
  default = {}
}