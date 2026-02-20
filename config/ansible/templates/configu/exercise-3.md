# Exercise 3: Secrets Management

**Time:** 30 minutes  
**Difficulty:** Intermediate  
**Goal:** Securely manage sensitive configurations

---

## 📚 Concepts Covered

- Separating secrets from configs
- Environment variables for secrets
- In-memory vs persistent stores
- Secret rotation patterns

---

## 🎯 Exercise Tasks

### Task 1: Identify Secrets in Your Config (5 min)

**Review what should be treated as secrets:**

```bash
cd ~/workspace/configu-exercises/exercise-3-secrets

# Create analysis doc
cat > secrets-audit.md << 'EOF'
# Secrets Audit

## ❌ Never Store in Plain Text
- Database passwords
- API keys
- JWT secrets
- Encryption keys
- OAuth tokens
- Private keys
- Cloud credentials

## ✅ OK to Store in Config
- Feature flags
- Timeouts
- Port numbers
- Log levels
- Public URLs
- Environment names

## 🔐 Secrets in Our App
From Exercise 2:
- DATABASE_PASSWORD ← Secret
- REDIS_URL (if contains password) ← Secret
- API keys (if added) ← Secret

## 📝 Regular Config
- APP_NAME
- ENVIRONMENT
- DATABASE_HOST (hostname only)
- LOG_LEVEL
- MAX_WORKERS
EOF

cat secrets-audit.md
```

**✅ Checkpoint:** Understand what qualifies as a secret.

---

### Task 2: Separate Secrets from Config (10 min)

**Create schema with secrets marked:**

```bash
cat > app-with-secrets.cfgu.json << 'EOF'
{
  "APP_NAME": {
    "type": "String",
    "required": true
  },
  "DATABASE_HOST": {
    "type": "String",
    "required": true
  },
  "DATABASE_USER": {
    "type": "String",
    "required": true
  },
  "DATABASE_PASSWORD": {
    "type": "String",
    "required": true,
    "description": "Database password - NEVER commit this value"
  },
  "API_KEY": {
    "type": "String",
    "required": true,
    "description": "External API key - store in vault"
  },
  "JWT_SECRET": {
    "type": "String",
    "required": true,
    "description": "JWT signing secret - rotate regularly"
  },
  "ENCRYPTION_KEY": {
    "type": "String",
    "required": true,
    "description": "Data encryption key - must be 32 bytes"
  }
}
EOF

# Create .gitignore for secrets
cat > .gitignore << 'EOF'
# Never commit these
*.env
.env.*
secrets/
stores/*secrets*.json

# OK to commit
schemas/
.configu
EOF
```

**✅ Checkpoint:** Schema created, secrets identified.

---

### Task 3: Environment Variable Pattern (10 min)

**Use environment variables for secrets:**

```bash
# Method 1: Export manually (for testing)
export DATABASE_PASSWORD="my_secret_password"
export API_KEY="sk_live_12345abcdef"
export JWT_SECRET="very_long_random_string_here"
export ENCRYPTION_KEY="32_byte_encryption_key_12345678"

# Method 2: Create secure .env file (NOT committed)
mkdir -p secrets

cat > secrets/.env.production << 'EOF'
DATABASE_PASSWORD=prod_super_secret_password_xyz
API_KEY=sk_prod_abcd1234efgh5678
JWT_SECRET=production_jwt_signing_secret_random_string
ENCRYPTION_KEY=prod_encryption_key_32_bytes_long
EOF

chmod 600 secrets/.env.production

# Method 3: Set via Configu CLI with environment variable source
configu upsert \
  --store in-memory \
  --set "production" \
  --schema ./app-with-secrets.cfgu.json \
  -c "APP_NAME=MyApp" \
  -c "DATABASE_HOST=prod-db.internal" \
  -c "DATABASE_USER=prod_user" \
  -c "DATABASE_PASSWORD=\${DATABASE_PASSWORD}" \
  -c "API_KEY=\${API_KEY}" \
  -c "JWT_SECRET=\${JWT_SECRET}" \
  -c "ENCRYPTION_KEY=\${ENCRYPTION_KEY}"

# Export configs (secrets from environment)
source secrets/.env.production

configu export \
  --store in-memory \
  --set "production" \
  --schema ./app-with-secrets.cfgu.json \
  --format "Dotenv"
```

**✅ Checkpoint:** Secrets sourced from environment, not stored in config files.

---

### Task 4: Secret Rotation Simulation (10 min)

**Practice rotating a secret:**

```bash
# Step 1: Current production secret
echo "OLD_DATABASE_PASSWORD=old_password_123" > secrets/.env.old

# Step 2: Generate new secret
NEW_PASSWORD=$(openssl rand -base64 32)
echo "Generated new password: $NEW_PASSWORD"

# Step 3: Update config with new secret
cat > secrets/.env.production << EOF
DATABASE_PASSWORD=$NEW_PASSWORD
API_KEY=sk_prod_abcd1234efgh5678
JWT_SECRET=production_jwt_signing_secret_random_string
ENCRYPTION_KEY=prod_encryption_key_32_bytes_long
EOF

# Step 4: Deployment process
cat > rotate-secret.sh << 'EOF'
#!/bin/bash
# rotate-secret.sh - Secret rotation script

set -e

echo "🔄 Secret Rotation Process"
echo "=========================="

# 1. Load old secrets
echo "📂 Loading old secrets..."
source secrets/.env.old

# 2. Verify app still works
echo "✅ Verifying app connectivity..."
# In real scenario: test database connection with old password

# 3. Update database with new password
echo "🔐 Updating database password..."
# In real scenario: ALTER USER statement

# 4. Load new secrets
echo "📂 Loading new secrets..."
source secrets/.env.production

# 5. Deploy app with new config
echo "🚀 Deploying with new secrets..."
# In real scenario: restart application

# 6. Verify new connection works
echo "✅ Verifying new credentials..."
# In real scenario: test with new password

# 7. Archive old secrets (for rollback)
echo "💾 Archiving old secrets..."
mv secrets/.env.old secrets/.env.old.$(date +%Y%m%d_%H%M%S)

echo "✅ Rotation complete!"
EOF

chmod +x rotate-secret.sh

# Run rotation (dry run)
./rotate-secret.sh
```

**✅ Checkpoint:** Understand secret rotation workflow.

---

## 🎓 What You Learned

- ✅ Identified what qualifies as a secret
- ✅ Separated secrets from regular config
- ✅ Used environment variables for secrets
- ✅ Created secure .env files (not committed)
- ✅ Simulated secret rotation

---

## 🧪 Challenge Tasks

**Try these:**

1. **Implement Secret Validation**
   ```bash
   # Check password strength
   if [ ${#DATABASE_PASSWORD} -lt 16 ]; then
     echo "Password too short!"; exit 1
   fi
   ```

2. **Create Multi-Environment Secrets**
   - `secrets/.env.development` (weak passwords OK)
   - `secrets/.env.staging` (moderate)
   - `secrets/.env.production` (strong)

3. **Automate Secret Generation**
   ```bash
   generate-secrets.sh:
   - DATABASE_PASSWORD (32 chars)
   - JWT_SECRET (64 chars)
   - ENCRYPTION_KEY (exactly 32 bytes)
   ```

---

## 📖 Best Practices

### Storage
- ✅ Environment variables (runtime)
- ✅ Vault (HashiCorp, AWS Secrets Manager)
- ✅ Encrypted files (age, sops)
- ❌ Never in Git
- ❌ Never in logs
- ❌ Never in error messages

### Access Control
```bash
# Restrict secret file permissions
chmod 600 secrets/.env.production

# Audit secret access
echo "$(date) - $(whoami) - accessed secrets" >> /var/log/secret-access.log
```

### Rotation Schedule
- **API Keys:** Every 90 days
- **Database Passwords:** Every 180 days
- **JWT Secrets:** Never (stateless)
- **Encryption Keys:** Rarely (requires data re-encryption)

### Emergency Rotation
If secret is compromised:
1. Generate new secret immediately
2. Deploy to all environments
3. Revoke old secret
4. Audit who had access
5. Document incident

---

## 🔐 Production Secrets Management

### Option 1: HashiCorp Vault
```bash
# Install Vault CLI
# Store secret
vault kv put secret/myapp/prod \
  database_password="..." \
  api_key="..."

# Retrieve in deployment
export DATABASE_PASSWORD=$(vault kv get -field=database_password secret/myapp/prod)
```

### Option 2: AWS Secrets Manager
```bash
# Store secret
aws secretsmanager create-secret \
  --name myapp/prod/database \
  --secret-string '{"password":"..."}'

# Retrieve in app
aws secretsmanager get-secret-value \
  --secret-id myapp/prod/database
```

### Option 3: SOPS (Secrets OPerationS)
```bash
# Encrypt .env file
sops -e secrets/.env.production > secrets/.env.production.enc

# Commit encrypted file to Git
git add secrets/.env.production.enc

# Decrypt at deploy time
sops -d secrets/.env.production.enc > .env
```

---

## 🚨 Security Checklist

Before deploying:
- [ ] No secrets in Git history
- [ ] `.gitignore` includes secret paths
- [ ] Secret files have 600 permissions
- [ ] Secrets use environment variables
- [ ] Rotation schedule documented
- [ ] Access audit trail exists
- [ ] Secrets encrypted at rest
- [ ] Secrets encrypted in transit

---

## 🚀 Next Steps

✅ **Exercise 3 Complete!**

**Move to Exercise 4:** Flask app integration

```bash
cd ../exercise-4-flask-app
cat README.md
```

**What's next:**
- Real-world application
- Database connection with secrets
- Feature flags
- Production deployment
