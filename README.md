# Vault AWS IAM Authentication Demo Module

This terraform module is for demonstration purpose.  It showcases how vault agent authenticates to vault server with AWS IAM, as documented in https://developer.hashicorp.com/vault/docs/auth/aws .

## Architecture

This module deploys the following resources in AWS:

- A VPC with a public subnet, internet gateway, and route table
- Two EC2 instances (ARM-based Amazon Linux 2):
  - Server A: Runs HashiCorp Vault server
  - Server B: Runs Vault Agent configured to authenticate using AWS IAM
- Security groups for both instances
- IAM roles and policies for AWS authentication
- SSH key pairs for secure access to the instances

## Prerequisites

- Tested on Terraform 1.10.5, no reason why earlier versions should not work
- AWS account with appropriate permissions

## Usage

```hcl
module "vault_aws_auth" {
  source = "github.com/songlining/terraform-vault-auth-aws"
  
  # Optional: customize with variables
  aws_region   = "us-west-2"
}
```

## Vault Server Setup

The Vault server is configured with:
- TCP listener on port 8200 (TLS disabled for demonstration)
- Automatic initialization and unsealing
- Enabled audit logging
- Configured AWS IAM authentication method, with pre-configured roles/policies
- database, pki and ssh secrets engines enabled
- kv access policy enabled for the agent role for testing purpose
- systemd service enabled

## Vault Agent Setup

The Vault Agent is configured to:
- Authenticate to the Vault server using an IAM role
- VAULT_ADDR and VAULT_TOKEN environment variables are set in root's .bashrc
- systemd service enabled

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws_region | AWS region to deploy resources | string | "ap-southeast-2" | no |
| arm_ami_id | AMI ID for ARM-based instances | string | "ami-0bc8d8ff75a022b42" | no |
| key_name | Name of the SSH key pair | string | "vault" | no |
| vault_version | Version of HashiCorp Vault to install | string | "1.19.3" | no |

## Outputs

| Name | Description |
|------|-------------|
| vault_server_public_ip | Public IP address of the Vault server |
| vault_server_private_ip | Private IP address of the Vault server |
| vault_agent_public_ip | Public IP address of the Vault agent |
| server_a_key_name | Name of the key pair for server-a |
| server_b_key_name | Name of the key pair for server-b |
| server_a_key_file | Path to the private key file for server-a |
| server_b_key_file | Path to the private key file for server-b |

## Testing

Sample code of using this module is under examples folder.

After deployment, you can test the setup using the following steps:
1. SSH into the Vault agent instance (server-b) using the key pair or from aws console
2. `sudo su root`
3. Run `vault token capabilities $VAULT_TOKEN secret/*`, you should see the following output:

   `create, delete, list, read, update`

## Security Considerations

- This module disables TLS for demonstration purposes. In production, enable TLS.
- The Vault initialization data including unseal keys is stored on the server. In production, secure these separately.
- Consider using AWS KMS for auto-unsealing in production environments.

## License

This module is licensed under the Mozilla Public License 2.0.