# ❄️ Snowflake Terraform Infrastructure

> Complete setup guide for managing Snowflake resources with Terraform

---

## 📋 Prerequisites

Before you begin, ensure you have:

- ✅ **Terraform** >= 1.0
- ✅ **Snowflake account** with appropriate permissions
- ✅ **AWS account** for S3 backend (state management)
- ✅ **Snowflake user** with JWT authentication configured

---

## 🚀 Getting Started

### **Step 1️⃣: Provision AWS S3 Backend**

#### 🔑 **AWS_ACCESS_KEY_ID**

AWS Access Key ID for S3 backend access.

**How to get:**
1. Go to **AWS Console** → **IAM** → **Users**
2. Select your user or create new user for Terraform
3. **Security credentials** → **Access keys** → **Create access key**
4. Use case: **CLI**
5. Copy the **Access Key ID**

**Required IAM permissions:**

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::terraform-project-1gj449d",
        "arn:aws:s3:::terraform-project-1gj449d/*"
      ]
    }
  ]
}
```

**Example value:** `AKIAIOSFODNN7EXAMPLE`

---

#### 🔐 **AWS_SECRET_ACCESS_KEY**

AWS Secret Access Key for S3 backend access.

**How to get:**
- Obtained at the same time as `AWS_ACCESS_KEY_ID`
- ⚠️ Only shown **once** during creation
- If lost, must create new access key

**Example value:** `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY`

---

### **Step 2️⃣: Generate Snowflake Key Pair**

Generate RSA key pair for Snowflake JWT authentication:

```bash
# Generate private key
ssh-keygen -t rsa -b 2048 -m pkcs8 -f snowflake_tf_key.p8

# Generate public key
ssh-keygen -e -f ./snowflake_tf_key.p8 -m pkcs8 > snowflake_tf_key.pub
```

**Result:** Two files created:
- 🔒 `snowflake_tf_key.p8` (private key - keep secure!)
- 🔓 `snowflake_tf_key.pub` (public key - upload to Snowflake)

---

### **Step 3️⃣: Configure Snowflake User & Roles**

Create Terraform user in Snowflake with necessary permissions:

```sql
-- Create Terraform user
CREATE USER IF NOT EXISTS TERRAFORM_USER;

-- Grant system roles
GRANT ROLE ACCOUNTADMIN TO USER TERRAFORM_USER;
GRANT ROLE SECURITYADMIN TO USER TERRAFORM_USER;
GRANT ROLE SYSADMIN TO USER TERRAFORM_USER;

-- Create custom infrastructure role
CREATE ROLE IF NOT EXISTS INFRA_ROLE;
GRANT CREATE ROLE ON ACCOUNT TO ROLE INFRA_ROLE;
GRANT MANAGE GRANTS ON ACCOUNT TO ROLE INFRA_ROLE;
GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE INFRA_ROLE;
GRANT MANAGE WAREHOUSES ON ACCOUNT TO ROLE INFRA_ROLE;

-- Assign custom role to user
CREATE USER IF NOT EXISTS TERRAFORM_USER DEFAULT_ROLE = INFRA_ROLE;
GRANT ROLE INFRA_ROLE TO USER TERRAFORM_USER;

-- Attach public key to user
ALTER USER TERRAFORM_USER
SET RSA_PUBLIC_KEY = '<contents of snowflake_tf_key.pub>';
```

> 💡 **Tip:** Copy the entire content of `snowflake_tf_key.pub` (excluding BEGIN/END lines)

---

### **Step 4️⃣: Setup Repository Structure**

Your repository should follow this structure:

```
snowflake-terraform-infra/
├── 📁 .github/
│   └── workflows/          # GitHub Actions workflows
│       ├── plan.yaml       # Terraform plan
│       ├── deploy.yaml     # Terraform apply
│       └── destroy.yaml    # Terraform destroy
├── 📁 backends/            # Backend configurations
│   ├── backend-dev.tfvars
│   └── backend-prod.tfvars
├── 📁 config/              # YAML resource definitions
│   ├── roles.yml
│   ├── databases.yml
│   └── warehouses.yml
├── 📁 environments/        # Environment variables
│   ├── dev.tfvars
│   └── prod.tfvars
├── 📄 backend.tf           # S3 backend configuration
├── 📄 providers.tf         # Provider configuration
├── 📄 variables.tf         # Variable definitions
├── 📄 locals.tf            # Local values & YAML parsing
├── 📄 roles.tf             # Snowflake roles
├── 📄 databases.tf         # Snowflake databases
├── 📄 warehouses.tf        # Snowflake warehouses
└── 📄 grants.tf            # Permission grants
```

---

### **Step 5️⃣: Configure Backend & Environments**

#### 1. **Configure S3 Backend**

Update `backends/backend-dev.tfvars`:

```hcl
bucket  = "terraform-project-1gj449d"
key     = "dev/snowflake-infrastructure.tfstate"
region  = "us-east-1"
encrypt = "true"
```

#### 2. **Configure Environment Variables**

Update `environments/dev.tfvars` with your Snowflake connection details:

```hcl
project           = "tb"
environment       = "dev"
region            = "us-east-1"
snowflake_role    = "SYSADMIN"
snowflake_account = "your_account"  # ← Get from query below
snowflake_org     = "your_org"      # ← Get from query below
snowflake_user    = "TERRAFORM_USER"
config_dir        = "./config"
```

**Find your Snowflake account & org:**

```sql
SELECT 
  LOWER(current_organization_name()) as your_org_name, 
  LOWER(current_account_name()) as your_account_name;
```

#### 3. **Configure YAML Resources**

Define your resources in `config/*.yml` files:

**Example `config/databases.yml`:**

```yaml
databases:
  raw:
    grants:
      - role: data_engineer
        privileges: [OWNERSHIP]
```

#### 4. **Add Core Terraform Files**

Ensure these files exist:
- ✅ `locals.tf` - Local values and YAML parsing
- ✅ `providers.tf` - Snowflake & AWS provider configuration
- ✅ `variables.tf` - Variable definitions

#### 5. **Add Resource Files**

Add `.tf` files for each resource type:
- ✅ `roles.tf` - Snowflake account roles
- ✅ `databases.tf` - Snowflake databases & grants
- ✅ `warehouses.tf` - Snowflake warehouses & grants
- ✅ `schemas.tf` - Snowflake schemas (optional)
- ✅ `grants.tf` - Role hierarchy grants

---

### **Step 6️⃣: Setup GitHub Actions Workflows**

#### 1. **Create Workflow Files**

Three workflows for complete automation:

| Workflow | Purpose | Trigger |
|----------|---------|---------|
| `plan.yaml` | 🔍 Preview changes | Manual |
| `deploy.yaml` | 🚀 Apply changes | Manual |
| `destroy.yaml` | 🗑️ Destroy infrastructure | Manual |

#### 2. **Add GitHub Secrets**

Go to **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Add these secrets:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `SNOWFLAKE_PRIVATE_KEY` | Private key content | Include `-----BEGIN/END PRIVATE KEY-----` |
| `AWS_ACCESS_KEY_ID` | AWS access key | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | `wJalrXUtnFEMI/K7MDENG/...` |

#### 3. **Create GitHub Environments**

Go to **Settings** → **Environments** → **New environment**

Create two environments:
- 🟢 **dev** - Development (no approvers)
- 🔴 **prod** - Production (recommended: add required reviewers)

#### 4. **Test Your Workflow**

```
1. Go to Actions tab
2. Select "Plan Snowflake Infra"
3. Click "Run workflow"
4. Configure:
   - Branch: main
   - Environment: dev
   - Always Apply Grants: false
   - Log Debug: OFF
5. Click "Run workflow"
6. ✅ Should complete successfully (green checkmark)
```

---

## ⚙️ Local Development Setup

### **Initialize Terraform Locally**

1. **Export AWS credentials:**

```bash
export AWS_ACCESS_KEY_ID="your_access_key"
export AWS_SECRET_ACCESS_KEY="your_secret_key"
```

2. **Export Snowflake private key:**

```bash
export SNOWFLAKE_PRIVATE_KEY_PATH="/path/to/snowflake_tf_key.p8"
```

3. **Initialize Terraform:**

```bash
terraform init -backend-config=backends/backend-dev.tfvars
```

4. **Plan changes:**

```bash
terraform plan -var-file=environments/dev.tfvars
```

5. **Apply changes:**

```bash
terraform apply -var-file=environments/dev.tfvars
```

---

## 🔧 Additional Configuration (Optional)

### **Environment-Specific Secrets**

If dev/prod use different credentials:

1. Go to **Settings** → **Environments** → Select `dev` or `prod`
2. Add **environment secrets** (these override repository secrets)
3. Use same names: `SNOWFLAKE_PRIVATE_KEY`, `AWS_ACCESS_KEY_ID`, etc.

> 💡 **Use case:** Different AWS accounts or Snowflake users per environment

---

### **DynamoDB State Locking** (Highly Recommended)

Prevent concurrent Terraform runs from corrupting state:

#### **Step 1: Create DynamoDB Table**

```bash
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

#### **Step 2: Update `backend.tf`**

```hcl
terraform {
  backend "s3" {
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

#### **Step 3: Update `backends/backend-dev.tfvars`**

```hcl
bucket         = "terraform-project-1gj449d"
key            = "dev/snowflake-infrastructure.tfstate"
region         = "us-east-1"
encrypt        = "true"
dynamodb_table = "terraform-state-lock"
```

**Benefits:**
- ✅ Prevents concurrent state modifications
- ✅ Protects against race conditions
- ✅ Shows who has the lock if blocked
- ✅ Free tier covers most use cases

---

## 🎯 Quick Reference

### **Useful Commands**

```bash
# Initialize
terraform init -backend-config=backends/backend-dev.tfvars

# Format code
terraform fmt -recursive

# Validate configuration
terraform validate

# Plan changes
terraform plan -var-file=environments/dev.tfvars

# Apply changes
terraform apply -var-file=environments/dev.tfvars

# Destroy all resources
terraform destroy -var-file=environments/dev.tfvars

# Check workspace
terraform workspace show

# List all resources
terraform state list
```

---

### **Helpful Links**

- 📚 [Snowflake Terraform Guide](https://www.snowflake.com/en/developers/guides/terraforming-snowflake/#create-a-new-repository)
