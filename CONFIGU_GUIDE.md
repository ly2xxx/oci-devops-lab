# Configu Configuration Management - Complete Guide

**Added:** 2026-02-19  
**Purpose:** Learn modern configuration management with Configu  
**Time:** 2-3 hours for all exercises

---

## 🎯 What is Configu?

Configu is a modern, open-source configuration management tool that brings:
- **Type Safety** - Schemas validate configs (prevent typos/wrong types)
- **Environment Separation** - Clean dev/staging/prod configs
- **Secrets Management** - Secure credential handling
- **Multi-Store Support** - Files, databases, vaults
- **Developer-Friendly** - CLI + SDK for any language

---

## 🚀 Quick Start

### Prerequisites
- Vagrant VMs running (`vagrant up`)
- Ansible configured
- SSH access to VM1 (`vagrant ssh vm1-control`)

### Installation (5 minutes)

```bash
# From your Windows host
cd C:\code\oci-devops-lab
vagrant ssh vm1-control

# Inside VM1
cd ~/workspace/ansible
ansible-playbook playbooks/install-configu.yml

# Verify installation
configu --version
cd ~/workspace/configu-exercises
ls -la
```

**Expected output:**
```
✅ Configu CLI installed successfully!
📁 Exercises located at: /home/vagrant/workspace/configu-exercises
```

---

## 📚 Exercises Overview

### Exercise 1: Basics (30 min)
**Location:** `exercise-1-basics/`

**What you'll learn:**
- Creating config schemas (.cfgu.json files)
- Storing and retrieving configs
- Type validation
- JSON file store

**Hands-on tasks:**
1. Create your first schema
2. Set configuration values
3. Export to different formats
4. Test type validation

**Key takeaway:** Configu schemas prevent configuration errors.

---

### Exercise 2: Environments (30 min)
**Location:** `exercise-2-environments/`

**What you'll learn:**
- Multi-environment configs
- Config inheritance
- Environment-specific overrides
- Deployment patterns

**Hands-on tasks:**
1. Create development environment configs
2. Set up staging environment
3. Configure production (secure settings)
4. Compare configurations
5. Understand override patterns

**Key takeaway:** Same schema, different values per environment.

---

### Exercise 3: Secrets (30 min)
**Location:** `exercise-3-secrets/`

**What you'll learn:**
- Identifying secrets vs regular config
- Environment variable pattern
- Secret rotation
- Production secrets management

**Hands-on tasks:**
1. Audit configs for secrets
2. Separate secrets from configs
3. Use environment variables
4. Simulate secret rotation
5. Production secrets workflow

**Key takeaway:** Never commit secrets; use vault/env vars.

---

### Exercise 4: Flask Integration (45 min)
**Location:** `exercise-4-flask-app/`

**What you'll learn:**
- Loading configs in Python apps
- Database connection management
- Feature flags
- Multi-environment deployment
- Real-world patterns

**Hands-on tasks:**
1. Create Flask app schema
2. Configure dev/staging/prod
3. Build Flask app with Configu
4. Implement feature flags
5. Test multi-environment deployment

**Key takeaway:** Configu integrates seamlessly with real applications.

---

## 🏗️ Integration with Existing Lab

### How Configu Fits

```
┌─────────────────────────────────────────────┐
│         DevOps Lab Stack                     │
├─────────────────────────────────────────────┤
│ Infrastructure:  Vagrant + VirtualBox       │
│ Provisioning:    Terraform (planned)        │
│ Config Mgmt:     Ansible                    │
│ App Config:      Configu ← NEW!             │
│ Deployment:      Octopus Deploy (planned)   │
│ Application:     Flask + Nginx              │
└─────────────────────────────────────────────┘
```

**Where Configu helps:**
- **Ansible** manages server state (packages, services)
- **Configu** manages application configuration (database URLs, feature flags)
- **Together:** Complete infrastructure + app config management

---

## 📖 Real-World Usage Patterns

### Pattern 1: Development Workflow

```bash
# Developer working locally
cd ~/project
configu export \
  --set "myapp/development" \
  --schema ./config.cfgu.json \
  --format "Dotenv" > .env

# Run app
python app.py
```

### Pattern 2: CI/CD Deployment

```bash
# In deployment pipeline
ENV=$1  # development, staging, or production

# Export configs for target environment
configu export \
  --set "myapp/$ENV" \
  --schema ./config.cfgu.json \
  --format "Dotenv" > .env.$ENV

# Deploy app with correct config
docker run --env-file .env.$ENV myapp:latest
```

### Pattern 3: Secrets from Vault

```bash
# Load secrets from vault, configs from file
export DATABASE_PASSWORD=$(vault kv get -field=password secret/myapp/prod)

# Merge with Configu configs
configu export \
  --set "myapp/production" \
  --schema ./config.cfgu.json
```

---

## 🎓 Learning Path

### Week 1: Foundations
- Day 1: Complete Exercise 1 (Basics)
- Day 2: Complete Exercise 2 (Environments)
- Day 3: Understand schema design patterns

### Week 2: Production Skills
- Day 4: Complete Exercise 3 (Secrets)
- Day 5: Complete Exercise 4 (Flask Integration)
- Day 6-7: Apply to your own projects

### Week 3: Advanced
- Multi-store setup (File + Vault)
- Config versioning strategies
- CI/CD integration
- Team workflows

---

## 💡 Best Practices

### DO ✅
- Always use schemas (type safety)
- Separate secrets from configs
- Version control schemas in Git
- Use environment-specific sets
- Document configs with descriptions
- Validate before deploying
- Use sensible defaults

### DON'T ❌
- Commit secrets to Git
- Mix dev and prod configs
- Skip schema validation
- Hard-code configuration
- Use same config across environments
- Store passwords in plain text

---

## 🔗 Resources

### Official
- **Documentation:** https://docs.configu.com
- **GitHub:** https://github.com/configu/configu
- **Examples:** https://github.com/configu/configu/tree/main/examples

### Community
- **Discord:** https://discord.gg/cjSBxnB9z8
- **Blog:** https://configu.com/blog
- **Tutorials:** https://docs.configu.com/tutorials

### This Lab
- Exercise Files: `~/workspace/configu-exercises/`
- Ansible Playbook: `~/workspace/ansible/playbooks/install-configu.yml`
- Schemas: `~/workspace/configu-exercises/schemas/`

---

## 🐛 Troubleshooting

### Configu CLI not found
```bash
# Verify installation
npm list -g @configu/cli

# Reinstall
sudo npm install -g @configu/cli

# Check PATH
which configu
```

### Schema validation errors
```bash
# Validate schema syntax
cat schema.cfgu.json | jq .

# Check for typos in type names
# Valid types: String, Number, Boolean

# Verify pattern regex
# Use https://regex101.com for testing
```

### Store connection errors
```bash
# Check store file exists
ls -la stores/

# Verify .configu file
cat .configu | jq .

# Create store directory if missing
mkdir -p stores
```

### Permission errors
```bash
# Fix ownership
sudo chown -R vagrant:vagrant ~/workspace/configu-exercises

# Fix permissions
chmod 644 schemas/*.json
chmod 755 exercise-*
```

---

## 📊 Success Metrics

After completing all exercises, you should be able to:

- [ ] Create type-safe config schemas
- [ ] Manage multi-environment configs
- [ ] Handle secrets securely
- [ ] Integrate with Python/Flask apps
- [ ] Deploy with correct configs per environment
- [ ] Use Configu CLI fluently
- [ ] Design production-ready config workflows
- [ ] Explain benefits over hard-coded configs

---

## 🚀 Next Steps After Completion

1. **Apply to Your Projects**
   - Replace hard-coded configs
   - Add environment separation
   - Implement feature flags

2. **Integrate with CI/CD**
   - GitHub Actions
   - GitLab CI
   - Jenkins

3. **Advanced Topics**
   - HashiCorp Vault integration
   - Kubernetes ConfigMaps
   - Multi-region deployments

4. **Share Knowledge**
   - Write a blog post
   - Teach your team
   - Contribute examples

---

## 📝 Change Log

**2026-02-19:**
- Initial Configu integration
- Created 4 comprehensive exercises
- Added Ansible installation playbook
- Integrated with existing lab

---

**Ready to master configuration management?** 🎓

```bash
vagrant ssh vm1-control
cd ~/workspace/ansible
ansible-playbook playbooks/install-configu.yml
cd ~/workspace/configu-exercises
cat README.md
```

**Happy learning!** 🚀
