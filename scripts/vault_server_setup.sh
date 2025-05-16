#!/bin/bash
set -e

# Update system packages
yum update -y

# Install necessary packages
yum install -y jq unzip

# Download and install Vault
VAULT_VERSION="${vault_version}"
curl -O "https://releases.hashicorp.com/vault/$${VAULT_VERSION}/vault_$${VAULT_VERSION}_linux_arm64.zip"
unzip "vault_$${VAULT_VERSION}_linux_arm64.zip"
mv vault /usr/local/bin/
chmod +x /usr/local/bin/vault

# Create Vault directories
mkdir -p /etc/vault.d
mkdir -p /opt/vault/data

# Create Vault server configuration
cat > /etc/vault.d/vault.hcl << EOF
ui = true

storage "file" {
  path = "/opt/vault/data"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = "true"
}

api_addr = "http://0.0.0.0:8200"
cluster_addr = "http://0.0.0.0:8201"
EOF

# Create Vault systemd service
cat > /etc/systemd/system/vault.service << EOF
[Unit]
Description=Vault Service
Requires=network-online.target
After=network-online.target

[Service]
Type=simple
User=root
Group=root
ExecStart=/usr/local/bin/vault server -config=/etc/vault.d/vault.hcl
ExecReload=/bin/kill -HUP \$MAINPID
KillSignal=SIGINT
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
StartLimitInterval=60
StartLimitBurst=3

[Install]
WantedBy=multi-user.target
EOF

# Start and enable Vault service
systemctl daemon-reload
systemctl enable vault
systemctl start vault

# Wait for Vault to start
sleep 10

# Initialize Vault
export VAULT_ADDR=http://127.0.0.1:8200
vault operator init -format=json > /root/vault-init.json

# Unseal Vault
for i in {0..2}; do
  UNSEAL_KEY=$(jq -r ".unseal_keys_b64[$i]" /root/vault-init.json)
  vault operator unseal $UNSEAL_KEY
done

# Set root token for further operations
export VAULT_TOKEN=$(jq -r .root_token /root/vault-init.json)

# Enable audit logging
vault audit enable file file_path=/var/log/vault_audit.log

# Enable required secret engines
vault secrets enable database
vault secrets enable pki
vault secrets enable ssh

# Enable and configure AWS auth method for Vault agent authentication
vault auth enable aws

# Create KV policy
cat > /etc/vault.d/kv-policy.hcl << EOF
path "secret/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
EOF

# Write the policy to Vault
vault policy write kv-access /etc/vault.d/kv-policy.hcl

# Configure AWS auth role for the Vault agent

vault write auth/aws/role/vault-agent \
  auth_type=iam \
  bound_iam_principal_arn="arn:aws:iam::${aws_account_id}:role/vault-agent-role" \
  policies=default,kv-access \
  ttl=24h

echo "Vault server setup complete!"
