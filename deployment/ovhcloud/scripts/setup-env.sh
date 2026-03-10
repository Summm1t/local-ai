#!/bin/bash

# Script to setup .env file with random passwords for Local AI deployment

# Get the root directory of the project (assuming this script is in deployment/ovhcloud/scripts)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

ENV_EXAMPLE="$PROJECT_ROOT/.env.example"
ENV_FILE="$PROJECT_ROOT/.env"

if [ ! -f "$ENV_EXAMPLE" ]; then
    echo "Error: .env.example not found at $ENV_EXAMPLE"
    exit 1
fi

echo "Creating .env from .env.example..."
cp "$ENV_EXAMPLE" "$ENV_FILE"

generate_password() {
    openssl rand -base64 24 | tr -d '/+=' | cut -c1-20
}

generate_hex() {
    openssl rand -hex 32
}

echo "Generating random passwords and keys..."

# n8n
N8N_ENC=$(generate_hex)
N8N_JWT=$(generate_hex)

# Supabase
POSTGRES_PWD=$(generate_password)
JWT_SECRET=$(generate_hex)
DASHBOARD_PWD=$(generate_password)
POOLER_ID="pooler-$(generate_password)"

# Neo4j
NEO4J_PWD=$(generate_password)

# Langfuse
CLICKHOUSE_PWD=$(generate_password)
MINIO_PWD=$(generate_password)
LF_SALT=$(generate_hex)
NEXT_AUTH=$(generate_hex)
ENC_KEY=$(generate_hex)

# Replacements using sed
# Note: Using | as delimiter for sed to avoid issues with / in values (though we stripped / in generate_password)

sed -i.bak "s|N8N_ENCRYPTION_KEY=super-secret-key|N8N_ENCRYPTION_KEY=$N8N_ENC|" "$ENV_FILE"
sed -i.bak "s|N8N_USER_MANAGEMENT_JWT_SECRET=even-more-secret|N8N_USER_MANAGEMENT_JWT_SECRET=$N8N_JWT|" "$ENV_FILE"

sed -i.bak "s|POSTGRES_PASSWORD=your-super-secret-and-long-postgres-password|POSTGRES_PASSWORD=$POSTGRES_PWD|" "$ENV_FILE"
sed -i.bak "s|JWT_SECRET=your-super-secret-jwt-token-with-at-least-32-characters-long|JWT_SECRET=$JWT_SECRET|" "$ENV_FILE"
sed -i.bak "s|DASHBOARD_PASSWORD=this_password_is_insecure_and_should_be_updated|DASHBOARD_PASSWORD=$DASHBOARD_PWD|" "$ENV_FILE"
sed -i.bak "s|POOLER_TENANT_ID=your-tenant-id|POOLER_TENANT_ID=$POOLER_ID|" "$ENV_FILE"

sed -i.bak "s|NEO4J_AUTH=neo4j/password|NEO4J_AUTH=neo4j/$NEO4J_PWD|" "$ENV_FILE"

sed -i.bak "s|CLICKHOUSE_PASSWORD=super-secret-key-1|CLICKHOUSE_PASSWORD=$CLICKHOUSE_PWD|" "$ENV_FILE"
sed -i.bak "s|MINIO_ROOT_PASSWORD=super-secret-key-2|MINIO_ROOT_PASSWORD=$MINIO_PWD|" "$ENV_FILE"
sed -i.bak "s|LANGFUSE_SALT=super-secret-key-3|LANGFUSE_SALT=$LF_SALT|" "$ENV_FILE"
sed -i.bak "s|NEXTAUTH_SECRET=super-secret-key-4|NEXTAUTH_SECRET=$NEXT_AUTH|" "$ENV_FILE"
sed -i.bak "s|ENCRYPTION_KEY=generate-with-openssl|ENCRYPTION_KEY=$ENC_KEY|" "$ENV_FILE"

# Clean up sed backup files
rm "$ENV_FILE.bak"

echo ".env file created and populated with random secrets."
echo "Please review .env and update any other necessary variables (like hostnames if not using defaults)."
