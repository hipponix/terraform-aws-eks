# EKS
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

variable "capacity_type" {
  description = "Define the EKS capacity type (ON_DEMAND, SPOT)"
  type        = string
  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.capacity_type)
    error_message = "Capacity_type must be either be 'ON_DEMAND' or 'SPOT'"
  }
}

# Bastion host
variable "create_bastion_host" {
  description = "It defines whether to create a bastion host or not"
  type        = bool
  default     = false
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

variable "public_keys" {
  type        = list(any)
  description = "A list of public keys used to connect to the server"
}
