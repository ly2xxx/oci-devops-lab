# Exercise 2: Environment-Specific Configurations

**Time:** 30 minutes  
**Difficulty:** Intermediate  
**Goal:** Master multi-environment config management

---

## 📚 Concepts Covered

- Environment separation (dev/staging/prod)
- Config inheritance
- Override patterns
- Best practices for deployment

---

## 🎯 Exercise Tasks

### Task 1: Create Environment Schema (10 min)

**Create a comprehensive app schema with environment-aware defaults:**

```bash
cd ~/workspace/configu-exercises/exercise-2-environments

# Create schema
cat > web-app.cfgu.json << 'EOF'
{
  "APP_NAME": {
    "type": "String",
    "required": true,
    "description": "Application name"
  },
  "ENVIRONMENT": {
    "type": "String",
    "required": true,
    "pattern": "^(development|staging|production)$",
    "description": "Deployment environment"
  },
  "DATABASE_HOST": {
    "type": "String",
    "required": true,
    "description": "Database server hostname"
  },
  "DATABASE_PORT": {
    "type": "Number",
    "default": 5432,
    "description": "Database server port"
  },
  "DATABASE_NAME": {
    "type": "String",
    "required": true,
    "description": "Database name"
  },
  "DATABASE_USER": {
    "type": "String",
    "required": true,
    "description": "Database username"
  },
  "DATABASE_PASSWORD": {
    "type": "String",
    "required": true,
    "description": "Database password (use secrets management)"
  },
  "REDIS_URL": {
    "type": "String",
    "default": "redis://localhost:6379",
    "description": "Redis connection URL"
  },
  "LOG_LEVEL": {
    "type": "String",
    "default": "INFO",
    "pattern": "^(DEBUG|INFO|WARNING|ERROR|CRITICAL)$",
    "description": "Application log level"
  },
  "DEBUG_MODE": {
    "type": "Boolean",
    "default": false,
    "description": "Enable debug mode"
  },
  "MAX_WORKERS": {
    "type": "Number",
    "default": 4,
    "description": "Number of worker processes"
  },
  "FEATURE_FLAG_NEW_UI": {
    "type": "Boolean",
    "default": false,
    "description": "Enable new UI"
  },
  "API_BASE_URL": {
    "type": "String",
    "required": true,
    "description": "External API base URL"
  }
}
EOF

# Validate schema
cat web-app.cfgu.json | jq .
```

**✅ Checkpoint:** Schema created with environment-aware fields.

---

### Task 2: Configure Development Environment (10 min)

**Set up development configs:**

```bash
# Create stores directory
mkdir -p stores

# Configure .configu for this exercise
cat > .configu << 'EOF'
{
  "stores": [
    {
      "type": "json-file",
      "configuration": {
        "path": "./stores/environments.json"
      }
    }
  ]
}
EOF

# Set development configs
configu upsert \
  --store ./stores/environments.json \
  --set "webapp/development" \
  --schema ./web-app.cfgu.json \
  -c "APP_NAME=MyWebApp" \
  -c "ENVIRONMENT=development" \
  -c "DATABASE_HOST=localhost" \
  -c "DATABASE_NAME=webapp_dev" \
  -c "DATABASE_USER=dev_user" \
  -c "DATABASE_PASSWORD=dev_password_123" \
  -c "LOG_LEVEL=DEBUG" \
  -c "DEBUG_MODE=true" \
  -c "MAX_WORKERS=2" \
  -c "FEATURE_FLAG_NEW_UI=true" \
  -c "API_BASE_URL=http://localhost:3000"

# Verify development configs
echo "=== Development Configuration ==="
configu export \
  --store ./stores/environments.json \
  --set "webapp/development" \
  --schema ./web-app.cfgu.json \
  --format "Dotenv"
```

**✅ Checkpoint:** Development configs stored.

---

### Task 3: Configure Staging Environment (5 min)

**Set up staging configs (more production-like):**

```bash
configu upsert \
  --store ./stores/environments.json \
  --set "webapp/staging" \
  --schema ./web-app.cfgu.json \
  -c "APP_NAME=MyWebApp" \
  -c "ENVIRONMENT=staging" \
  -c "DATABASE_HOST=staging-db.internal" \
  -c "DATABASE_NAME=webapp_staging" \
  -c "DATABASE_USER=staging_user" \
  -c "DATABASE_PASSWORD=staging_password_xyz" \
  -c "REDIS_URL=redis://staging-redis.internal:6379" \
  -c "LOG_LEVEL=INFO" \
  -c "DEBUG_MODE=false" \
  -c "MAX_WORKERS=4" \
  -c "FEATURE_FLAG_NEW_UI=true" \
  -c "API_BASE_URL=https://api-staging.example.com"

# Verify staging configs
echo "=== Staging Configuration ==="
configu export \
  --store ./stores/environments.json \
  --set "webapp/staging" \
  --schema ./web-app.cfgu.json \
  --format "Dotenv"
```

**✅ Checkpoint:** Staging configs differ from dev (production-like settings).

---

### Task 4: Configure Production Environment (5 min)

**Set up production configs (secure and optimized):**

```bash
configu upsert \
  --store ./stores/environments.json \
  --set "webapp/production" \
  --schema ./web-app.cfgu.json \
  -c "APP_NAME=MyWebApp" \
  -c "ENVIRONMENT=production" \
  -c "DATABASE_HOST=prod-db-master.aws.internal" \
  -c "DATABASE_NAME=webapp_prod" \
  -c "DATABASE_USER=prod_user" \
  -c "DATABASE_PASSWORD=SUPER_SECURE_PROD_PASSWORD" \
  -c "REDIS_URL=redis://prod-redis-cluster.aws.internal:6379" \
  -c "LOG_LEVEL=WARNING" \
  -c "DEBUG_MODE=false" \
  -c "MAX_WORKERS=8" \
  -c "FEATURE_FLAG_NEW_UI=false" \
  -c "API_BASE_URL=https://api.example.com"

# Verify production configs
echo "=== Production Configuration ==="
configu export \
  --store ./stores/environments.json \
  --set "webapp/production" \
  --schema ./web-app.cfgu.json \
  --format "Dotenv"
```

**✅ Checkpoint:** Three environments configured with appropriate settings.

---

### Task 5: Compare Environments (5 min)

**Analyze differences between environments:**

```bash
# Export all to JSON for comparison
echo "=== Development ==="
configu export \
  --store ./stores/environments.json \
  --set "webapp/development" \
  --schema ./web-app.cfgu.json \
  --format "JSON" | jq .

echo -e "\n=== Staging ==="
configu export \
  --store ./stores/environments.json \
  --set "webapp/staging" \
  --schema ./web-app.cfgu.json \
  --format "JSON" | jq .

echo -e "\n=== Production ==="
configu export \
  --store ./stores/environments.json \
  --set "webapp/production" \
  --schema ./web-app.cfgu.json \
  --format "JSON" | jq .

# Create comparison table
cat > environment-comparison.md << 'EOF'
# Environment Configuration Comparison

| Config Key | Development | Staging | Production |
|------------|-------------|---------|------------|
| LOG_LEVEL | DEBUG | INFO | WARNING |
| DEBUG_MODE | true | false | false |
| MAX_WORKERS | 2 | 4 | 8 |
| DATABASE_HOST | localhost | staging-db.internal | prod-db-master.aws.internal |
| FEATURE_FLAG_NEW_UI | true | true | false |

## Key Differences

**Development:**
- Debug mode ON
- Fewer workers (laptop-friendly)
- Local database
- New features enabled for testing

**Staging:**
- Production-like settings
- Internal hostnames
- Testing ground for new features
- Moderate logging

**Production:**
- Maximum security
- Optimized workers
- AWS infrastructure
- Conservative feature flags
- Minimal logging
EOF

cat environment-comparison.md
```

**✅ Checkpoint:** Understand environment-specific patterns.

---

## 🎓 What You Learned

- ✅ Created environment-specific configurations
- ✅ Used naming convention: `app/environment`
- ✅ Configured dev/staging/prod appropriately
- ✅ Compared configs across environments
- ✅ Understood deployment best practices

---

## 🧪 Challenge Tasks

**Try these:**

1. **Add QA Environment**
   - Create `webapp/qa` set
   - Between staging and dev in strictness

2. **Create Deployment Script**
   ```bash
   #!/bin/bash
   # deploy.sh
   ENV=$1
   configu export \
     --store ./stores/environments.json \
     --set "webapp/$ENV" \
     --schema ./web-app.cfgu.json \
     --format "Dotenv" > .env.$ENV
   ```

3. **Feature Flag Rollout**
   - Enable `FEATURE_FLAG_NEW_UI` in all environments
   - Document the rollout plan

---

## 📖 Best Practices

### Environment Naming
```
app/development    # Local dev
app/qa             # QA testing
app/staging        # Pre-production
app/production     # Live
```

### Config Hierarchy
1. **Defaults** in schema (shared across all envs)
2. **Environment-specific** overrides
3. **Secrets** never in version control

### Security Levels
- **Dev:** Relaxed (debug on, local services)
- **Staging:** Production-like (test deploy process)
- **Production:** Locked down (no debug, monitoring on)

### Deployment Pattern
```bash
# 1. Export config for target environment
configu export --set "app/$ENV" > .env

# 2. Load into application
source .env

# 3. Validate before starting app
if [ "$ENVIRONMENT" != "$ENV" ]; then
  echo "Config mismatch!"; exit 1
fi
```

---

## 🚨 Common Mistakes

❌ **Mixing environments** - Never use prod DB in dev  
❌ **Hardcoded secrets** - Use secrets management (Exercise 3)  
❌ **No validation** - Always validate before deploy  
❌ **Copy-paste configs** - Use defaults + overrides  

---

## 🚀 Next Steps

✅ **Exercise 2 Complete!**

**Move to Exercise 3:** Secrets management

```bash
cd ../exercise-3-secrets
cat README.md
```

**What's next:**
- Secure credential storage
- Environment variable integration
- Secret rotation strategies
