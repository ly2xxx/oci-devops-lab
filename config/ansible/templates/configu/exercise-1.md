# Exercise 1: Configu Basics

**Time:** 30 minutes  
**Difficulty:** Beginner  
**Goal:** Learn fundamental Configu operations

---

## 📚 Concepts Covered

- Config schemas (.cfgu.json files)
- Storing and retrieving configs
- JSON file store
- Type validation

---

## 🎯 Exercise Tasks

### Task 1: Create Your First Schema (10 min)

**Create a simple app schema:**

```bash
cd ~/workspace/configu-exercises/exercise-1-basics

# Create schema file
cat > app.cfgu.json << 'EOF'
{
  "APP_NAME": {
    "type": "String",
    "description": "Application name",
    "required": true
  },
  "VERSION": {
    "type": "String",
    "default": "1.0.0",
    "description": "Application version"
  },
  "PORT": {
    "type": "Number",
    "default": 5000,
    "description": "HTTP server port"
  },
  "DEBUG": {
    "type": "Boolean",
    "default": false,
    "description": "Enable debug mode"
  },
  "LOG_LEVEL": {
    "type": "String",
    "default": "INFO",
    "description": "Logging level",
    "pattern": "^(DEBUG|INFO|WARNING|ERROR)$"
  }
}
EOF

# Validate schema syntax
cat app.cfgu.json | jq .
```

**✅ Checkpoint:** You should see formatted JSON output.

---

### Task 2: Initialize Config Store (5 min)

**Create a JSON file store:**

```bash
# Create stores directory
mkdir -p stores

# Create .configu configuration
cat > .configu << 'EOF'
{
  "stores": [
    {
      "type": "json-file",
      "configuration": {
        "path": "./stores/config.json"
      }
    }
  ]
}
EOF

# Verify configuration
cat .configu | jq .
```

**✅ Checkpoint:** `.configu` file exists and is valid JSON.

---

### Task 3: Set Configuration Values (10 min)

**Upsert configs using Configu CLI:**

```bash
# Set required APP_NAME
configu upsert \
  --store ./stores/config.json \
  --set "myapp" \
  --schema ./app.cfgu.json \
  -c "APP_NAME=HelloWorld"

# Set optional values (overriding defaults)
configu upsert \
  --store ./stores/config.json \
  --set "myapp" \
  --schema ./app.cfgu.json \
  -c "PORT=8080" \
  -c "DEBUG=true" \
  -c "LOG_LEVEL=DEBUG"

# Verify values were stored
cat stores/config.json | jq .
```

**Expected output:**
```json
{
  "myapp": {
    "APP_NAME": "HelloWorld",
    "PORT": "8080",
    "DEBUG": "true",
    "LOG_LEVEL": "DEBUG"
  }
}
```

**✅ Checkpoint:** Values stored in `stores/config.json`.

---

### Task 4: Retrieve Configuration (5 min)

**Export configs to environment variables:**

```bash
# Export to .env format
configu export \
  --store ./stores/config.json \
  --set "myapp" \
  --schema ./app.cfgu.json \
  --format "Dotenv" > .env

# View generated .env file
cat .env

# Export as JSON
configu export \
  --store ./stores/config.json \
  --set "myapp" \
  --schema ./app.cfgu.json \
  --format "JSON" | jq .

# Export to shell environment
eval $(configu export \
  --store ./stores/config.json \
  --set "myapp" \
  --schema ./app.cfgu.json \
  --format "Dotenv")

# Verify environment variables
echo "APP_NAME: $APP_NAME"
echo "PORT: $PORT"
echo "DEBUG: $DEBUG"
```

**✅ Checkpoint:** Environment variables are set.

---

### Task 5: Type Validation (5 min)

**Test schema validation:**

```bash
# Try invalid port (string instead of number)
configu upsert \
  --store ./stores/config.json \
  --set "myapp" \
  --schema ./app.cfgu.json \
  -c "PORT=not-a-number"

# Expected: Error - type mismatch

# Try invalid LOG_LEVEL (doesn't match pattern)
configu upsert \
  --store ./stores/config.json \
  --set "myapp" \
  --schema ./app.cfgu.json \
  -c "LOG_LEVEL=TRACE"

# Expected: Error - pattern validation failed

# Try valid values
configu upsert \
  --store ./stores/config.json \
  --set "myapp" \
  --schema ./app.cfgu.json \
  -c "PORT=3000" \
  -c "LOG_LEVEL=WARNING"

# Expected: Success
```

**✅ Checkpoint:** Invalid values are rejected, valid ones accepted.

---

## 🎓 What You Learned

- ✅ Created a Configu schema with types
- ✅ Initialized a JSON file store
- ✅ Set and retrieved configuration values
- ✅ Exported configs to different formats
- ✅ Validated types and patterns

---

## 🧪 Challenge Tasks

**Try these on your own:**

1. Add a new config key `MAX_CONNECTIONS` (type: Number, default: 100)
2. Create a second set called "test" with different values
3. Export configs to CSV format
4. Delete a config key and verify it's removed

**Hints:**
```bash
# Add to schema, then upsert
configu upsert --store ./stores/config.json --set "test" ...

# Export formats: Dotenv, JSON, CSV, XML, YAML
configu export --format CSV ...

# Delete a key
configu delete --store ./stores/config.json --set "myapp" --schema ./app.cfgu.json --key "DEBUG"
```

---

## 📖 Key Concepts

### Config Schema
A JSON file defining:
- **Keys** - config variable names
- **Types** - String, Number, Boolean
- **Validation** - patterns, required fields
- **Defaults** - fallback values

### Config Set
A named collection of configs (e.g., "myapp", "test")
- Allows multiple apps in one store
- Isolates configurations

### Store
Where configs are persisted:
- JSON file (this exercise)
- Database (PostgreSQL, MongoDB)
- Vault (HashiCorp Vault)
- Cloud (AWS Secrets Manager)

---

## 🚀 Next Steps

✅ **Exercise 1 Complete!**

**Move to Exercise 2:** Environment-specific configurations

```bash
cd ../exercise-2-environments
cat README.md
```

**What's next:**
- Dev/staging/prod environments
- Config inheritance
- Override patterns
