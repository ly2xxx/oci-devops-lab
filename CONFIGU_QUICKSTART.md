# Configu Quick Start - 10 Minutes to Running

**Goal:** Get Configu installed and complete first exercise in 10 minutes.

---

## Step 1: Install (3 minutes)

```powershell
# From Windows host
cd C:\code\oci-devops-lab

# SSH to VM1
vagrant ssh vm1-control

# Inside VM1, run Ansible playbook
cd ~/workspace/ansible
ansible-playbook playbooks/install-configu.yml
```

**Expected output:**
```
✅ Configu CLI installed successfully!
📁 Exercises located at: /home/vagrant/workspace/configu-exercises
```

---

## Step 2: Verify Installation (1 minute)

```bash
# Check Configu version
configu --version

# Navigate to exercises
cd ~/workspace/configu-exercises
ls -la

# Read main README
cat README.md
```

**Expected:** Four exercise directories + README

---

## Step 3: Quick Example (5 minutes)

**Create a simple config in 5 minutes:**

```bash
# Go to exercise 1
cd exercise-1-basics

# Create schema
cat > test.cfgu.json << 'EOF'
{
  "APP_NAME": {
    "type": "String",
    "required": true
  },
  "PORT": {
    "type": "Number",
    "default": 5000
  }
}
EOF

# Set values
mkdir -p stores

configu upsert \
  --store ./stores/test.json \
  --set "myapp" \
  --schema ./test.cfgu.json \
  -c "APP_NAME=HelloConfigu" \
  -c "PORT=3000"

# Export configs
configu export \
  --store ./stores/test.json \
  --set "myapp" \
  --schema ./test.cfgu.json \
  --format "Dotenv"

# Expected output:
# APP_NAME="HelloConfigu"
# PORT="3000"
```

**✅ Success!** You just:
1. Created a config schema
2. Stored configuration values
3. Retrieved configs in .env format

---

## Step 4: Continue Learning (1 minute)

**Now complete the full exercises:**

```bash
# Read Exercise 1 README
cat exercise-1-basics/README.md

# Follow the instructions
cd exercise-1-basics
# Complete all tasks (30 min)

# Move to Exercise 2
cd ../exercise-2-environments
cat README.md
# Continue...
```

---

## 🎯 What's Next

**Completed quickstart?** Continue with:

1. **Exercise 1** (30 min) - Basics & schemas
2. **Exercise 2** (30 min) - Multi-environment
3. **Exercise 3** (30 min) - Secrets management
4. **Exercise 4** (45 min) - Flask integration

**Total learning time:** ~2-3 hours

---

## 📖 Resources

- **Full Guide:** `cat ../CONFIGU_GUIDE.md`
- **Exercise README:** `cat README.md`
- **Configu Docs:** https://docs.configu.com
- **Getting Help:** Exercise READMEs have troubleshooting sections

---

## 🐛 Quick Troubleshooting

**Command not found: configu**
```bash
sudo npm install -g @configu/cli
```

**Permission errors**
```bash
sudo chown -R vagrant:vagrant ~/workspace/configu-exercises
```

**Schema errors**
```bash
cat schema.cfgu.json | jq .  # Validate JSON
```

---

**Ready? Let's go!** 🚀

```bash
cd ~/workspace/configu-exercises/exercise-1-basics
cat README.md
```
