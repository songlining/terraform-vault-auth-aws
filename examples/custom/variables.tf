# Variables for the custom example

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "vault_version" {
  description = "Version of HashiCorp Vault to install"
  type        = string
  default     = "1.19.3"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "my-vault-key"
}