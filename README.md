# Snowflake Terraform Infrastructure

A minimal Terraform infrastructure setup for managing Snowflake resources. This repository is designed to start small and grow gradually with new modules.

## Prerequisites

- Terraform >= 1.0
- Snowflake account with appropriate permissions
- AWS account for S3 backend (for state management)
- Snowflake user with JWT authentication configured

## Getting Started

### 1. Configure Your Environment

Before initializing, fill in your Snowflake connection details in `environments/dev.tfvars`:
- `snowflake_account`: Your Snowflake account locator
- `snowflake_org`: Your Snowflake organization name

### 2. Configure Backend

Update `backends/backend-dev.tfvars` with your S3 backend configuration:
```hcl
bucket         = "your-terraform-state-bucket"
key            = "snowflake/dev/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "terraform-state-lock"
```

### 3. Initialize Terraform

```bash
terraform init -backend-config=backends/backend-dev.tfvars
```

### 4. Plan and Apply

```bash
terraform plan -var-file=environments/dev.tfvars
terraform apply -var-file=environments/dev.tfvars
```

## Configuration Files

The repository uses YAML files in the `config/` directory to define resources:
- `databases.yml`: Database definitions
- `roles.yml`: Role definitions
- `permissions.yml`: Permission grants
- `warehouses.yml`: Warehouse definitions

## Repository Structure

```
.
├── backend.tf              # S3 backend configuration
├── backends/               # Backend configuration per environment
├── config/                 # YAML configuration files
├── environments/           # Environment-specific variables
├── providers.tf            # Provider configuration
├── variables.tf            # Variable definitions
└── locals.tf              # Local values and YAML parsing
```

## Adding New Modules

As you extend this repository, you can add new `.tf` files for different resource types:
- `roles.tf` - Snowflake roles
- `databases.tf` - Snowflake databases
- `warehouses.tf` - Snowflake warehouses
- `schemas.tf` - Snowflake schemas
- `grants.tf` - Permission grants
- etc.

## Authentication

This setup uses JWT authentication for Snowflake. Ensure your Snowflake user is configured with RSA key pair authentication.
