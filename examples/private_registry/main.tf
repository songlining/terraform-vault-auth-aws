# Basic example of using the Vault AWS authentication module
terraform {
  cloud {}
}
module "vault-agent-auth-role" {
  source  = "app.terraform.io/lab-larry/vault-agent-auth-role/aws"
  #source = "git@github.com:songlining/terraform-aws-vault-agent-auth-role.git"
  version = "1.0.6"
}

output "vault_server_private_ip" {
  value = module.vault-agent-auth-role.vault_server_private_ip
  description = "Private IP address of the Vault server"
}

output "vault_agent_public_ip" {
  value = module.vault-agent-auth-role.vault_agent_public_ip
  description = "Public IP address of the Vault agent"
}