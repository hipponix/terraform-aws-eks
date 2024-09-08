variable "eks_version" {
  description = "Version of EKS"
  type        = string
}

variable "public_access" {
  description = "Enable / Disable public access to the cluster"
  type        = bool
  default     = "false"
}

variable "private_access" {
  description = "Enable / Disable private access to the cluster"
  type        = bool
  default     = "false"
}

variable "vpc" {
  description = "__todo__"
  type        = string
}

variable "eks_subnets" {
  description = "__todo__"
  type        = list(any)
}

variable "ami_subnet" {
  description = "__todo__"
  type        = string
}

variable "key_name" {
  description = "__todo__"
  type        = string
}

variable "addons" {
  type = list(object({
    name    = string
    version = string
  }))
}
