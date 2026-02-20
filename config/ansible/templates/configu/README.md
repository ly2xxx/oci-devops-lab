# Configu Exercises - Configuration Management Mastery

**Learning Objectives:**
- Understand modern configuration management
- Type-safe configs with schemas
- Environment-specific configurations
- Secrets management
- Integration with real applications

---

## 🎯 What is Configu?

Configu is a modern configuration management tool that provides:
- **Type safety** - schemas validate your configs
- **Environment separation** - dev/staging/prod configs
- **Secret management** - secure credential handling
- **Version control** - config changes tracked in git
- **Multi-store** - file, database, vault support

**Why learn Configu?**
- Prevents config errors in production
- Centralizes configuration management
- Works with any language/framework
- Cloud-native and DevOps-friendly

---

## 📚 Exercises

### Exercise 1: Basics (30 minutes)
**Location:** `exercise-1-basics/`

Learn:
- Configu CLI basics
- Creating config schemas
- Setting and getting values
- JSON file store

### Exercise 2: Environments (30 minutes)
**Location:** `exercise-2-environments/`

Learn:
- Environment-specific configs
- Config inheritance
- Override patterns
- Best practices

### Exercise 3: Secrets (30 minutes)
**Location:** `exercise-3-secrets/`

Learn:
- Secure secret storage
- Environment variables
- Encryption
- Secret rotation

### Exercise 4: Flask App Integration (45 minutes)
**Location:** `exercise-4-flask-app/`

Learn:
- Real-world application
- Database connection strings
- Feature flags
- Deployment configurations

---

## 🚀 Quick Start

```bash
# Verify Configu is installed
configu --version

# Start with Exercise 1
cd exercise-1-basics
cat README.md

# Follow instructions in each exercise README
```

---

## 📖 Reference

### Configu CLI Commands

```bash
# Upsert (set) a config value
configu upsert --store <store> --set <set> --schema <schema> -c <key>=<value>

# Export configs to environment
configu export --store <store> --set <set> --schema <schema>

# Validate configs against schema
configu eval --store <store> --set <set> --schema <schema>

# List all configs
configu eval --store <store> --set <set> --schema <schema> --format json

# Delete a config
configu delete --store <store> --set <set> --schema <schema> --key <key>
```

### Schema Format (.cfgu.json)

```json
{
  "APP_NAME": {
    "type": "String",
    "description": "Application name",
    "required": true
  },
  "PORT": {
    "type": "Number",
    "default": 5000,
    "description": "HTTP port"
  },
  "DEBUG": {
    "type": "Boolean",
    "default": false
  }
}
```

---

## 🎓 Learning Path

**Week 1: Foundations**
1. Complete Exercise 1 (Basics)
2. Complete Exercise 2 (Environments)
3. Understand schema design

**Week 2: Production Skills**
4. Complete Exercise 3 (Secrets)
5. Complete Exercise 4 (Flask Integration)
6. Deploy with real configs

**Week 3: Advanced**
7. Multi-store setup (JSON + Vault)
8. Config versioning strategies
9. CI/CD integration

---

## 💡 Best Practices

1. **Always use schemas** - Type safety prevents errors
2. **Separate environments** - Never mix dev/prod
3. **Encrypt secrets** - Use vault or encrypted stores
4. **Version control schemas** - Track changes in git
5. **Document configs** - Use description fields
6. **Validate before deploy** - Run `configu eval`
7. **Use defaults wisely** - Sensible fallbacks
8. **Audit config access** - Log who changed what

---

## 🔗 Resources

- **Official Docs:** https://docs.configu.com
- **GitHub:** https://github.com/configu/configu
- **Examples:** https://github.com/configu/configu/tree/main/examples
- **Discord:** https://discord.gg/cjSBxnB9z8

---

## 🐛 Troubleshooting

**Command not found: configu**
```bash
# Verify installation
npm list -g @configu/cli

# Reinstall
sudo npm install -g @configu/cli
```

**Schema validation errors**
```bash
# Check schema syntax
cat schemas/app.cfgu.json | jq .

# Validate with verbose output
configu eval --store ./stores/dev.json --schema ./schemas/app.cfgu.json --set dev --format json
```

**Store connection errors**
```bash
# Check store file exists
ls -la stores/

# Verify .configu file
cat .configu | jq .
```

---

**Ready to master configuration management?** 🚀

Start with `cd exercise-1-basics && cat README.md`
