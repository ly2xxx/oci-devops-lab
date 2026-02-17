# Octopus Deploy - Deployment Process Configuration

This document describes the Octopus Deploy deployment process for the OCI DevOps Lab.

---

## Project Setup

**Project Name:** OCI DevOps Lab  
**Lifecycle:** Default  
**Project Group:** (Optional) DevOps Labs

---

## Environments

| Environment | Description | Target |
|-------------|-------------|--------|
| **Dev** | Development environment | VM2 (app-server role) |
| **Test** | Testing environment (optional) | VM3 (if created) |

---

## Deployment Targets

### VM1 - Control Node
- **Role:** `control-node`
- **Type:** SSH Target or Tentacle
- **Hostname:** `<VM1_PUBLIC_IP>`
- **Port:** 22
- **Account:** SSH key or Tentacle

### VM2 - App Server
- **Role:** `app-server`
- **Environment:** Dev
- **Type:** SSH Target or Tentacle
- **Hostname:** `<VM2_PRIVATE_IP>` (or public IP)
- **Port:** 22

---

## Deployment Process Steps

### Step 1: Validate Infrastructure (Terraform Plan)

**Step Name:** Terraform Plan  
**Type:** Run a Script  
**Target Role:** `control-node`

**Script:**
```bash
#!/bin/bash
set -e

cd ~/oci-devops-lab/infra/terraform

echo "Running Terraform plan..."
terraform plan -detailed-exitcode

echo "Terraform plan completed successfully"
```

**Notes:**
- Runs on VM1 (control node)
- Validates infrastructure state
- Exit code 0 = no changes, 2 = changes detected

---

### Step 2: Apply Infrastructure (Terraform Apply)

**Step Name:** Terraform Apply  
**Type:** Run a Script  
**Target Role:** `control-node`  
**Run Condition:** Only run when previous step succeeds

**Script:**
```bash
#!/bin/bash
set -e

cd ~/oci-devops-lab/infra/terraform

echo "Applying Terraform configuration..."
terraform apply -auto-approve

echo "Terraform apply completed"
terraform output
```

**Notes:**
- Creates/updates OCI resources
- Outputs VM IPs for verification
- `-auto-approve` for automation (use carefully!)

---

### Step 3: Update Ansible Inventory

**Step Name:** Update Inventory  
**Type:** Run a Script  
**Target Role:** `control-node`

**Script:**
```bash
#!/bin/bash
set -e

cd ~/oci-devops-lab/infra/terraform

# Get IPs from Terraform
VM2_PRIVATE_IP=$(terraform output -raw vm2_private_ip)

cd ~/oci-devops-lab/config/ansible

# Update inventory (or use dynamic inventory in production)
sed -i "s/<VM2_PRIVATE_IP>/$VM2_PRIVATE_IP/g" inventory/hosts.yml

echo "Inventory updated with VM IPs"
```

**Notes:**
- Ensures Ansible has latest IPs
- In production, use Terraform output or dynamic inventory

---

### Step 4: Base Configuration (Ansible)

**Step Name:** Ansible Base Config  
**Type:** Run a Script  
**Target Role:** `control-node`

**Script:**
```bash
#!/bin/bash
set -e

cd ~/oci-devops-lab/config/ansible

echo "Running base configuration playbook..."
ansible-playbook -i inventory/hosts.yml playbooks/base-config.yml

echo "Base configuration completed"
```

**Notes:**
- Hardens OS
- Installs packages (Nginx, Python, etc.)
- Configures firewall
- Creates app user

---

### Step 5: Deploy Application

**Step Name:** Deploy App  
**Type:** Run a Script  
**Target Role:** `control-node`

**Script:**
```bash
#!/bin/bash
set -e

cd ~/oci-devops-lab/config/ansible

echo "Deploying application..."
ansible-playbook -i inventory/hosts.yml playbooks/deploy-app.yml

echo "Application deployed successfully"
```

**Notes:**
- Deploys Flask app to VM2
- Configures Nginx reverse proxy
- Starts app service

---

### Step 6: Health Check

**Step Name:** Verify Deployment  
**Type:** Run a Script  
**Target Role:** `control-node`

**Script:**
```bash
#!/bin/bash
set -e

cd ~/oci-devops-lab/infra/terraform
VM2_PUBLIC_IP=$(terraform output -raw vm2_public_ip)

echo "Testing application health..."
curl -f http://$VM2_PUBLIC_IP/health

echo "Health check passed!"
curl http://$VM2_PUBLIC_IP/api/info
```

**Notes:**
- Verifies app is responding
- Checks health endpoint
- Displays app info

---

## Variables

Define these in Octopus for flexibility:

| Variable Name | Value | Scope |
|---------------|-------|-------|
| `OCI.Region` | `uk-london-1` | All |
| `OCI.TenancyOCID` | `ocid1.tenancy...` | All |
| `App.Version` | `#{Octopus.Release.Number}` | All |
| `App.Environment` | `#{Octopus.Environment.Name}` | Per Environment |

---

## Advanced: Package-Based Deployment

For a more sophisticated approach:

1. **Build Step (CI):**
   - Package app as `.tar.gz` or `.zip`
   - Push to Octopus built-in feed or external feed

2. **Deploy Package Step:**
   - Download package to VM1
   - Extract to `/tmp/app-package`
   - Rsync to VM2 via Ansible

3. **Version Tracking:**
   - Octopus tracks releases and rollbacks
   - Easy to promote Dev → Test → Prod

---

## Rollback Strategy

### Manual Rollback
1. Deploy previous release from Octopus
2. Ansible playbooks are idempotent (safe to re-run)

### Terraform Rollback
- Keep Terraform state in backend (S3, OCI Object Storage)
- Use Terraform workspaces for environments
- Rollback = `terraform apply` with previous code

---

## GitHub Actions Integration

Create `.github/workflows/octopus-deploy.yml`:

```yaml
name: Deploy to OCI

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Create Octopus Release
        uses: OctopusDeploy/create-release-action@v3
        with:
          api_key: ${{ secrets.OCTOPUS_API_KEY }}
          server: https://yangdevops.octopus.app
          project: OCI DevOps Lab
          
      - name: Deploy to Dev
        uses: OctopusDeploy/deploy-release-action@v3
        with:
          api_key: ${{ secrets.OCTOPUS_API_KEY }}
          server: https://yangdevops.octopus.app
          project: OCI DevOps Lab
          environment: Dev
```

---

## Monitoring & Notifications

**Add to Deployment Process:**

1. **Pre-deployment:** Slack/Teams notification
2. **Post-deployment:** Success/failure notification
3. **Health checks:** Continuous monitoring step

**Example Slack Notification:**
```bash
curl -X POST -H 'Content-type: application/json' \
  --data '{"text":"🚀 Deploying OCI DevOps Lab to Dev..."}' \
  $SLACK_WEBHOOK_URL
```

---

## Next Steps

1. Set up Octopus Cloud instance
2. Install Tentacles on VM1 and VM2
3. Create project and configure steps above
4. Test deployment
5. Add GitHub Actions integration
6. Celebrate! 🎉
