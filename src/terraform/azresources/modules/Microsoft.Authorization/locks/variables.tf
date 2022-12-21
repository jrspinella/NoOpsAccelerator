variable "scope_id" {
  description = "(Required) Fully qualified Azure resource identifier for the lock"
  type        = string
}

variable "lock_level" {
  description = "(Required) Specifies the Level to be used for this Lock. Possible values are CanNotDelete and ReadOnly."
  type        = string
}
