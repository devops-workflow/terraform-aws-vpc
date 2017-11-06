
// Standard Variables

variable "name" {
  description = "Name"
}
variable "environment" {
  description = "Environment (ex: dev, qa, stage, prod)"
}
variable "namespaced" {
  description = "Namespace all resources (prefixed with the environment)?"
  default     = true
}
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = "map"
  default     = {}
}

// Module specific Variables

variable "cidr" {
  description = "The CIDR block for the VPC."
}

variable "external_subnets" {
  description = "List of external subnets"
  type        = "list"
}

variable "internal_subnets" {
  description = "List of internal subnets"
  type        = "list"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = "list"
}

/**
 *  Corporate VPN data
**/

variable "corp_customer_gateway_id" {
  description = "Corporate Customer Gateway ID"
}
variable "corp_vpn_cidr" {
  description = "Corporate VPN CIDR"
}

