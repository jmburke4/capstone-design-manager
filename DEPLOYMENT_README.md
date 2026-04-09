# 🚀 Deployment Package
## Capstone Design Manager - Google Cloud Platform

This directory contains everything needed to deploy your application to Google Cloud Platform.

---

## 📦 What's Included

### Deployment Files (`deployment/`)
- `Dockerfile.production` - Production Docker image configuration
- `gunicorn.conf.py` - Gunicorn WSGI server configuration
- `entrypoint-production.sh` - Container startup script
- `.dockerignore` - Files to exclude from Docker build

### Scripts (`scripts/`)
- `00-setup-gcp-project.sh` - GCP project setup & API enablement
- `01-setup-cloud-sql.sh` - Cloud SQL database creation
- `02-setup-secrets.sh` - Secret Manager setup (interactive)
- `03-setup-artifact-registry.sh` - Docker registry setup
- `10-build-and-push.sh` - Build and push Docker images
- `20-deploy-staging.sh` - Deploy to staging environment
- `30-deploy-production.sh` - Deploy to production
- `40-setup-custom-domain.sh` - Custom domain configuration
- `deploy.sh` - Main deployment orchestrator

### Configuration (`config/` & `backend/core/`)
- `backend/core/settings_production.py` - Production Django settings
- `backend/core/health.py` - Health check endpoint
- `backend/core/spa.py` - Vue.js SPA serving view

### Documentation (`docs/`)
- `QUICKSTART.md` - Fast deployment guide (30 minutes)
- `DEPLOYMENT_GUIDE.md` - Complete deployment guide
- `MANUAL_STEPS.md` - All manual steps checklist
- `AUTH0_SETUP.md` - Auth0 configuration guide
- `TROUBLESHOOTING.md` - Common issues and solutions

---

## 🎯 Quick Start

### Step 1: Prerequisites (5 minutes)

```bash
# Verify tools
gcloud --version
docker --version

# Authenticate
gcloud auth login
gcloud auth application-default login
```

### Step 2: Manual GCP Setup (5 minutes)

1. Create GCP project at: https://console.cloud.google.com/projectcreate
   - Project ID: `capstone-design-manager-prod`
2. Enable billing: https://console.cloud.google.com/billing

### Step 3: Run Infrastructure Scripts (20 minutes)

```bash
cd /path/to/capstone-design-manager

# 1. Enable APIs
./scripts/00-setup-gcp-project.sh

# 2. Create Docker registry
./scripts/03-setup-artifact-registry.sh

# 3. Create database (takes 8-10 min)
./scripts/01-setup-cloud-sql.sh

# 4. Setup secrets (will prompt for Auth0 credentials)
./scripts/02-setup-secrets.sh
```

### Step 4: Deploy to Staging (15 minutes)

```bash
# Build and deploy
./scripts/deploy.sh staging
```

### Step 5: Configure Auth0 (5 minutes)

1. Get staging URL from deployment output
2. Go to: https://manage.auth0.com/
3. Add staging URL to:
   - Allowed Callback URLs
   - Allowed Logout URLs
   - Allowed Web Origins
4. Save changes

### Step 6: Test Staging

Open staging URL and test:
- [ ] Login with Auth0
- [ ] Dashboard loads
- [ ] API works
- [ ] Admin panel accessible (with admin role)

---

## 📚 Documentation Guide

### For First-Time Deployment

Read in this order:

1. **QUICKSTART.md** - Fast deployment (if you're impatient)
2. **MANUAL_STEPS.md** - Checklist of all manual actions
3. **DEPLOYMENT_GUIDE.md** - Detailed explanations
4. **AUTH0_SETUP.md** - Auth0 configuration

### For Production

After staging is validated:

1. **DEPLOYMENT_GUIDE.md** - Section: "Phase 5: Production"
2. **Instructions for custom domain setup**
3. **Update Auth0 with production URLs**

### When Things Go Wrong

1. **TROUBLESHOOTING.md** - Common issues and fixes
2. Check application logs:
   ```bash
   gcloud run services logs tail SERVICE_NAME --region=us-central1
   ```

---

## 🏗️ Architecture

### Production Stack

```
┌─────────────────────────────────────────┐
│   Browser (HTTPS)                       │
└────────────┬────────────────────────────┘
             │
┌────────────▼────────────────────────────┐
│   Cloud Load Balancer + SSL             │
└────────────┬────────────────────────────┘
             │
┌────────────▼────────────────────────────┐
│   Cloud Run (Unified Service)           │
│   ┌─────────────────────────────────┐   │
│   │  Django (Gunicorn)              │   │
│   │  • Serves Vue.js SPA            │   │
│   │  • REST API (/api/v1/*)         │   │
│   │  • Admin Panel (/admin/)        │   │
│   │  • Static Files (/static/)      │   │
│   └─────────────┬───────────────────┘   │
└─────────────────┼───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│   Cloud SQL PostgreSQL                  │
│   • Managed service                     │
│   • Automatic backups                   │
│   • Private connection                  │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│   Secret Manager                        │
│   • Auth0 credentials                   │
│   • Django secret key                   │
│   • Database password                   │
└─────────────────────────────────────────┘
```

### Key Features

- ✅ **Serverless**: Auto-scaling Cloud Run
- ✅ **Managed Database**: Cloud SQL with automatic backups
- ✅ **Secure Secrets**: Google Secret Manager
- ✅ **HTTPS**: Automatic SSL certificates
- ✅ **Rootless**: Containers run as non-root user
- ✅ **Monitoring**: Cloud Logging & Monitoring included

---

## 💰 Cost Estimate

With minimum 1 instance running:

| Service | Monthly Cost |
|---------|--------------|
| Cloud Run (1 instance, 1GB RAM) | $15-25 |
| Cloud SQL (db-f1-micro) | $10-20 |
| Networking & Storage | $5-10 |
| **Total** | **$30-55/month** |

Your $300 free credits cover **6-10 months**.

### Cost Optimization

**For staging** (when not actively testing):
```bash
# Scale to zero
gcloud run services update capstone-manager-staging \
    --region=us-central1 \
    --min-instances=0

# Delete when not needed
gcloud run services delete capstone-manager-staging \
    --region=us-central1
```

---

## 🔐 Security

### Container Security
- ✅ Non-root user (appuser, UID 1000)
- ✅ Minimal base image (python:3.11-slim)
- ✅ No secrets in image or environment variables
- ✅ Secrets loaded from Secret Manager at runtime

### Network Security
- ✅ HTTPS enforced
- ✅ Cloud SQL private IP
- ✅ CORS configured
- ✅ CSRF protection
- ✅ HSTS headers

### Auth Security
- ✅ Auth0 JWT validation
- ✅ Role-based access control
- ✅ Admin panel protected
- ✅ Secure session cookies

---

## 📊 Monitoring

### Quick Health Check

```bash
# Check if service is healthy
curl https://YOUR-SERVICE-URL/api/v1/health/

# Expected: {"status":"healthy","database":"connected"}
```

### View Metrics

**Console**: https://console.cloud.google.com/run?project=capstone-design-manager-prod

**Metrics**:
- Request count & latency
- Error rate
- Container instances
- CPU & memory usage

### View Logs

```bash
# Real-time logs
gcloud run services logs tail capstone-manager-production --region=us-central1

# Recent errors
gcloud run services logs read capstone-manager-production \
    --region=us-central1 \
    --log-filter='severity>=ERROR' \
    --limit=50
```

---

## 🆘 Emergency Procedures

### Service is Down

1. **Check service status**:
   ```bash
   gcloud run services describe capstone-manager-production \
       --region=us-central1
   ```

2. **Check logs**:
   ```bash
   gcloud run services logs read capstone-manager-production \
       --region=us-central1 \
       --limit=100
   ```

3. **Rollback if needed**:
   ```bash
   # See TROUBLESHOOTING.md - Rollback Procedures
   ```

### Database Issues

1. **Verify Cloud SQL is running**:
   ```bash
   gcloud sql instances describe capstone-db-prod \
       --format='value(state)'
   ```

2. **Check connection**:
   ```bash
   gcloud sql connect capstone-db-prod --user=capstone_user
   ```

3. **Contact GCP Support** if database is down

---

## 📞 Support Resources

- **Full Deployment Guide**: `docs/DEPLOYMENT_GUIDE.md`
- **Troubleshooting**: `docs/TROUBLESHOOTING.md`
- **Auth0 Setup**: `docs/AUTH0_SETUP.md`
- **GCP Console**: https://console.cloud.google.com/
- **Auth0 Dashboard**: https://manage.auth0.com/

---

## ✅ Deployment Checklist

Use `docs/MANUAL_STEPS.md` for a complete checklist.

**Quick checklist**:
- [ ] GCP project created
- [ ] Billing enabled
- [ ] Infrastructure scripts run
- [ ] Secrets configured
- [ ] Staging deployed
- [ ] Auth0 configured
- [ ] Staging tested
- [ ] Production deployed (when ready)
- [ ] Custom domain configured (when ready)

---

## 🎓 Learning Resources

- **Django Production**: https://docs.djangoproject.com/en/stable/howto/deployment/
- **Cloud Run Best Practices**: https://cloud.google.com/run/docs/tips/general
- **Auth0 Documentation**: https://auth0.com/docs

---

**Version**: 1.0.0  
**Last Updated**: April 2026  
**Project**: Capstone Design Manager
