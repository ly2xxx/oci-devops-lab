# Troubleshooting: 404-NotAuthorizedOrNotFound

## Error Details
```
Error: 404-NotAuthorizedOrNotFound, Authorization failed or requested resource not found.
Suggestion: Either the resource has been deleted or service Core Instance need policy to access this resource.
```

## Root Causes & Solutions

### 1. Missing IAM Permissions ⚠️ (Most Common)

**Problem:** Your user lacks permission to create compute instances

**Check:**
1. Go to OCI Console → Identity & Security → Users
2. Click your username
3. Check **Groups** tab - are you in "Administrators"?

**Solution:**

**If you're an Administrator:**
```
Go to: Identity & Security → Policies
Create Policy:
  Name: allow-compute-instances
  Compartment: (root)
  Statement:
    Allow group Administrators to manage instance-family in tenancy
    Allow group Administrators to manage virtual-network-family in tenancy
```

**If you're NOT an Administrator:**
```
Ask your OCI admin to add this policy:
  Allow group <YOUR_GROUP_NAME> to manage instance-family in tenancy
  Allow group <YOUR_GROUP_NAME> to use virtual-network-family in tenancy
  Allow group <YOUR_GROUP_NAME> to use keys in tenancy
```

**Verify your groups:**
```powershell
# Check user details in OCI Console
# Identity & Security → Users → Your User → Groups
```

---

### 2. Free Tier Limits Exhausted 🚫

**Problem:** Already have 2 Always Free instances running

**Check:**
```
OCI Console → Compute → Instances
Count instances with shape: VM.Standard.E2.1.Micro
```

**Always Free Limits:**
- Max 2x VM.Standard.E2.1.Micro instances
- If you have 2 running, you MUST delete one to create another

**Solution:**
1. Go to Compute → Instances
2. **Terminate** any unused instances
3. Wait 5 minutes for cleanup
4. Re-run `terraform apply`

---

### 3. Availability Domain Capacity Issue 🌍

**Problem:** AD-1 might be full in your region

**Check current setting:**
```
# In terraform.tfvars:
availability_domain = 1
```

**Solution:**
```
Try different ADs:
availability_domain = 2  # or 3
```

Then re-plan and apply:
```powershell
terraform plan -out=tfplan
terraform apply tfplan
```

---

### 4. Compartment Access Issue 🔒

**Problem:** Using wrong compartment or don't have access

**Check:**
```
# In terraform.tfvars:
compartment_ocid = "ocid1.tenancy.oc1..aaaaaaaajlhf74wxnbofmq44rxqkami4qsslxjgg4spqsz65mr5ni3eh2abq"
```

**Verify:**
1. Go to OCI Console → Identity & Security → Compartments
2. Confirm compartment exists and you have access
3. For free tier, typically use **root compartment** (tenancy OCID)

**Solution:**
If using a sub-compartment, ensure you have this policy:
```
Allow group <YOUR_GROUP> to manage instance-family in compartment <COMPARTMENT_NAME>
```

---

### 5. API Key Issues 🔑

**Problem:** Invalid API key or fingerprint mismatch

**Check:**
```powershell
# Verify API key exists
Get-Content C:\Users\vl\.oci\oci_api_key.pem

# Check fingerprint in OCI Console
# Identity & Security → Users → Your User → API Keys
# Should match: eb:44:c6:9d:e0:1f:30:38:44:c3:0a:0a:56:6a:e5:3f
```

**Solution:**
If fingerprint doesn't match, regenerate:
```powershell
# Generate new key pair
ssh-keygen -t rsa -b 4096 -f C:\Users\vl\.oci\oci_api_key.pem -N ""

# Upload public key to OCI
# Go to: Identity & Security → Users → Your User → API Keys → Add API Key
# Copy fingerprint and update terraform.tfvars
```

---

## Step-by-Step Fix Process

### Step 1: Verify Authentication
```powershell
cd C:\code\oci-devops-lab\infra\terraform
terraform init
terraform plan
```

If plan succeeds, authentication is OK.

### Step 2: Check OCI Console

1. **Login:** https://cloud.oracle.com/
2. **Compute → Instances:** Count existing Always Free instances
3. **Identity → Policies:** Check if compute policies exist
4. **Identity → Users → Your User → Groups:** Verify membership

### Step 3: Add Missing Policy (if needed)

```
Navigate: Identity & Security → Policies
Click: Create Policy
Fill in:
  Name: allow-user-compute
  Description: Allow compute instance creation
  Compartment: (root)
  Policy Builder: Show manual editor
  Statement:
    Allow group Administrators to manage all-resources in tenancy
```

**Or more restrictive:**
```
Allow group Administrators to manage instance-family in tenancy
Allow group Administrators to use virtual-network-family in tenancy
Allow group Administrators to use volume-family in tenancy
```

### Step 4: Clean Up & Retry

```powershell
# Destroy partial infrastructure
terraform destroy -auto-approve

# Wait 2 minutes

# Re-apply
terraform plan -out=tfplan
terraform apply tfplan
```

### Step 5: If Still Failing - Try Minimal Instance

Edit `compute.tf` to create just ONE instance first:

```hcl
# Comment out VM2 temporarily
# resource "oci_core_instance" "vm2_app" {
#   ...
# }
```

Then:
```powershell
terraform plan -out=tfplan
terraform apply tfplan
```

If VM1 creates successfully → policy is OK, likely hitting free tier limit
If VM1 FAILS → policy issue, needs admin help

---

## Quick Checklist

- [ ] I'm in "Administrators" group in OCI
- [ ] Policy "allow-compute-instances" exists
- [ ] I have < 2 Always Free instances running
- [ ] API key fingerprint matches OCI console
- [ ] Using correct compartment OCID
- [ ] Tried different availability_domain (1, 2, or 3)

---

## Still Stuck?

**Get detailed error:**
```powershell
$env:TF_LOG="DEBUG"
terraform apply tfplan 2>&1 | Tee-Object -FilePath terraform-debug.log
```

**Check OCI service health:**
https://ocistatus.oraclecloud.com/

**Contact OCI Support:**
If you're on free tier and can't create instances, open a support ticket:
https://support.oracle.com/

---

## Common Solutions Summary

| Error Symptom | Most Likely Cause | Quick Fix |
|---------------|-------------------|-----------|
| VCN creates, instances fail | Missing IAM policy | Add compute policy |
| "shape not available" | Wrong region/AD | Change `availability_domain` |
| "limit exceeded" | 2 instances already exist | Terminate old instances |
| "authentication failed" | Wrong API key | Re-upload API key |
| "compartment not found" | Wrong compartment OCID | Use tenancy OCID |

---

**Next:** After fixing, run:
```powershell
cd C:\code\oci-devops-lab\infra\terraform
terraform destroy -auto-approve  # Clean up
terraform plan -out=tfplan        # Replan
terraform apply tfplan            # Apply
```
