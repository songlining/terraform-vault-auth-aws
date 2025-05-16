# Custom example of using the Vault AWS authentication module with custom configurations

provider "aws" {
  region = var.aws_region
}

module "vault_aws_auth" {
  source = "../../"
  
  # Custom configurations
  aws_region    = var.aws_region
  vault_version = var.vault_version
  key_name      = var.key_name
}

output "vault_server_ip" {
  value = module.vault_aws_auth.vault_server_public_ip
  description = "Public IP address of the Vault server"
}

output "vault_agent_ip" {
  value = module.vault_aws_auth.vault_agent_public_ip
  description = "Public IP address of the Vault agent"
}

output "ssh_key_files" {
  value = {
    server_a = module.vault_aws_auth.server_a_key_file
    server_b = module.vault_aws_auth.server_b_key_file
  }
  description = "Paths to the SSH private key files"
  sensitive   = true
}