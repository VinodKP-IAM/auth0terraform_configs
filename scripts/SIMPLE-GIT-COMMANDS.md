# 🎯 Simple Git Commands - Stakeholder Demo

## 📋 **6 Scenarios - Copy & Paste Commands**

---

### **1️⃣ DEVELOPMENT: Daily Work**
```bash
git checkout development
git pull origin development
###open config/dev.tfvars and make changes as required
git add .
git commit -m "feat: Daily development improvements"
git push origin development
```
**👀 Watch:** GitHub Actions → Development Environment → Dev Tenant

---

### **2️⃣ FEATURE: Team Collaboration**
```bash
git checkout development
git checkout -b "feature/new-auth"
###open config/dev.tfvars and make changes as required
git add .
git commit -m "feat: New authentication system"
git push origin feature/new-auth

# Merge feature (simulates approved PR)
git checkout development
git merge feature/new-auth --no-ff -m "Merge: New auth feature"
git push origin development
git branch -d feature/new-auth #this is for deleting the branch"
```
**👀 Watch:** GitHub Actions → Development Environment → Dev Tenant

---

### **3️⃣ STAGING TAG: Pre-Production**
```bash
git checkout development
###open config/qa.tfvars and make changes as required
git add .
git commit -m "milestone: Staging release preparation"
git tag -a "v12.0-staging" -m "Staging milestone for validation"
git push origin v12.0-staging
```
**👀 Watch:** GitHub Actions → Staging Environment → Staging Tenant

---

### **4️⃣ PRODUCTION TAG: Live Release**
```bash
git checkout master
###open config/prod.tfvars and make changes as required
git add .
git commit -m "release: Production deployment"
git tag -a "v12.1" -m "Production release v12.1"
git push origin v12.1
```
**👀 Watch:** GitHub Actions → Production Environment → Production Tenant

---

### **5️⃣ HOTFIX: Emergency Fix**
```bash
git checkout master
git checkout -b "hotfix/critical-fix"
echo "Critical security fix" > "hotfix.md"
git add .
git commit -m "🚨 HOTFIX: Critical security patch"
git push origin hotfix/critical-fix

# After validation, deploy to production:
git checkout master
git merge hotfix/critical-fix --no-ff -m "Emergency fix"
git push origin master
```
**👀 Watch:** GitHub Actions → Staging (validation) → Production

---

### **6️⃣ REVERT: Rollback**
```bash
# Option A: Revert last commit
git log --oneline -3
git revert HEAD --no-edit
git push origin development

# Option B: Rollback to stable tag
git tag -a "v2.2-rollback" v2.0 -m "Rollback to v2.0"  
git push origin v2.2-rollback
```
**👀 Watch:** GitHub Actions → Previous Working State Restored

---

## 📊 **What Stakeholders Will See in GitHub Actions**

### **Real-Time Deployment Pipeline:**
1. **Workflow Triggered** → "Deploy Auth0 Infrastructure"
2. **Environment Detection** → Development/Staging/Production  
3. **Configuration Loading** → dev.tfvars/qa.tfvars/prod.tfvars
4. **Terraform Execution** → Live infrastructure changes
5. **Success Confirmation** → "Apply complete! Resources deployed"

### **Live Monitoring URL:**
🔗 **https://github.com/KaranGupta05/terraform_auth0/actions**

---

## 🎯 **Stakeholder Key Points**

| **Command** | **Business Value** | **Risk Mitigation** |
|-------------|-------------------|-------------------|
| Development Push | Fast development cycle | Isolated testing environment |
| Feature Merge | Team collaboration | Code review process |
| Staging Tag | Stakeholder validation | Pre-production testing |
| Production Tag | Controlled releases | Milestone-based deployment |
| Hotfix Branch | Emergency response | No disruption to ongoing work |
| Revert/Rollback | Business continuity | Quick recovery from issues |

---

## ✅ **Requirements Coverage**

✅ **Every merge over master → deployment** (Production environment)  
✅ **Version tags mark milestones** (v2.1, v5.0-staging)  
✅ **Staging tags → pre-production** (v5.0-staging → staging tenant)  
✅ **Production tags → production** (v2.1 → production tenant)  
✅ **Hotfixes don't impact other work** (Independent branch flow)  
✅ **Revert capabilities** (Git revert + rollback tags)

---

**Demo Time:** 25 minutes  
**Format:** Live commands with real deployments  
**Audience:** Stakeholders, management, technical teams