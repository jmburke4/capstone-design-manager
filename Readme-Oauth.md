# OAuth Setup Guide

## Overview
This project uses Auth0 for OAuth authentication with role-based access control. Users log in through role-specific buttons (Student or Sponsor), create their profile on first login, and are redirected to their respective dashboards.

## Prerequisites
- Docker & Docker Compose installed
- Access to shared Auth0 tenant (see below) OR your own Auth0 account

---

## Choose Your Setup Method

**Most developers should use Option A (Shared Tenant)** unless you need an isolated environment.

### Option A: Use Shared Development Tenant (Recommended for Team)
- **Setup Time:** 5 minutes
- **Auth0 Tenant:** `dev-qjyd077ykn3qqq7v.us.auth0.com`
- **Client ID:** `WMPr5zJLNFI0j9A8iUymDfAsP2mUXsn3`
- **API Identifier:** `https://backend-api-capstone/`
- ✅ Fastest setup (pre-configured)
- ✅ Consistent with team environment
- ✅ No Auth0 account needed
- ⚠️ Shared credentials (all developers use same tenant)

👉 **[Jump to Option A Instructions](#option-a-quick-setup-with-shared-tenant)**

### Option B: Use Your Own Auth0 Tenant (For Independent Development)
- **Setup Time:** 15-20 minutes
- **Your Own Credentials:** Create your own Auth0 account
- ✅ Isolated development environment
- ✅ Full control over Auth0 configuration
- ✅ No interference with other developers
- ✅ Learn Auth0 setup process
- ⚠️ Requires Auth0 account creation
- ⚠️ Must update code with your API identifier

👉 **[Jump to Option B Instructions](#option-b-setup-with-your-own-auth0-tenant)**

---

## Quick Decision Guide

**Choose Option A if:**
- You want to start coding immediately
- You're working closely with the team
- You don't need to experiment with Auth0 settings
- You're new to Auth0

**Choose Option B if:**
- You want isolated testing environment
- You need to experiment with Auth0 configuration
- You're experiencing issues with the shared tenant
- You want to learn Auth0 setup

---

## OPTION A: Quick Setup with Shared Tenant

### Step 1: Clone and Setup Repository
```bash
git clone <repository-url>
cd capstone-design-manager
git checkout <oauth-branch-name>
```

### Step 2: Copy Environment Templates

#### Frontend Environment
```bash
cp frontend/.env.local.example frontend/.env.local
```

Edit `frontend/.env.local`:
```
VITE_AUTH0_DOMAIN=dev-qjyd077ykn3qqq7v.us.auth0.com
VITE_AUTH0_CLIENT_ID=WMPr5zJLNFI0j9A8iUymDfAsP2mUXsn3
VITE_AUTH0_AUDIENCE=https://backend-api-capstone/
```

#### Backend Environment
```bash
cp env.dev.example env.dev
```

Edit `env.dev` and add these Auth0 settings:
```
AUTH0_DOMAIN=dev-qjyd077ykn3qqq7v.us.auth0.com
AUTH0_CLIENT_ID=WMPr5zJLNFI0j9A8iUymDfAsP2mUXsn3
AUTH0_AUDIENCE=https://backend-api-capstone/
```

### Step 3: Build and Start Containers
```bash
docker-compose -f docker-compose.dev.yml build
docker-compose -f docker-compose.dev.yml up
```

**You're done!** Skip to the "Testing the Setup" section.

---

## OPTION B: Setup with Your Own Auth0 Tenant

### Step 1: Create Auth0 Account
1. Go to https://auth0.com/signup
2. Sign up for a free account
3. Create a new tenant (e.g., `yourname-capstone-dev.auth0.com`)

### Step 2: Create an Auth0 Application

1. Go to **Applications → Applications** in Auth0 Dashboard
2. Click **Create Application**
3. Enter:
   - **Name:** Capstone Design Manager
   - **Application Type:** Single Page Application
4. Click **Create**
5. Go to the **Settings** tab
6. Configure **Application URIs:**
   - **Allowed Callback URLs:** `http://localhost:5173/`
   - **Allowed Logout URLs:** `http://localhost:5173/`
   - **Allowed Web Origins:** `http://localhost:5173`
   - **Allowed Origins (CORS):** `http://localhost:5173`
7. Scroll to **Advanced Settings → Grant Types**
8. Ensure these are checked:
   - ✅ Authorization Code
   - ✅ Refresh Token
9. **Save Changes**
10. **Copy your Domain and Client ID** - you'll need these

### Step 3: Create an API in Auth0

1. Go to **Applications → APIs** in Auth0 Dashboard
2. Click **Create API**
3. Enter:
   - **Name:** Capstone Backend API
   - **Identifier:** `https://your-username-capstone-api/` (use your own identifier)
   - **Signing Algorithm:** RS256
4. Click **Create**
5. **Copy the Identifier** - you'll need this

### Step 4: Create Roles

1. Go to **User Management → Roles**
2. Create two roles:
   - **Name:** `student`, **Description:** Student user
   - **Name:** `sponsor`, **Description:** Sponsor/Faculty user

### Step 5: Create Login Action

1. Go to **Actions → Flows → Login**
2. Click **Create Action** → Select **Custom**
3. Name it "Assign Roles and Email"
4. Replace the code with:

```javascript
exports.onExecutePostLogin = async (event, api) => {
  // IMPORTANT: Replace this with YOUR API identifier from Step 3
  const namespace = 'https://your-username-capstone-api/';
  
  // Get existing roles
  const existingRoles = event.authorization?.roles || [];
  
  // Always add email to access token (needed for API authentication)
  if (event.user.email) {
    api.accessToken.setCustomClaim(`${namespace}email`, event.user.email);
    api.idToken.setCustomClaim(`${namespace}email`, event.user.email);
  }
  
  // If user already has a role, keep it (don't overwrite on login)
  if (existingRoles.length > 0) {
    api.idToken.setCustomClaim(`${namespace}roles`, existingRoles);
    api.accessToken.setCustomClaim(`${namespace}roles`, existingRoles);
    return;
  }
  
  // First login (signup) - assign role based on login button clicked
  const roleHint = event.request.query?.role;
  
  let assignedRole = null;
  
  if (roleHint === 'sponsor') {
    assignedRole = 'sponsor';
  }
  
  if (roleHint === 'student') {
    assignedRole = 'student';
  }
  
  // Assign role if we have one
  if (assignedRole) {
    api.idToken.setCustomClaim(`${namespace}roles`, [assignedRole]);
    api.accessToken.setCustomClaim(`${namespace}roles`, [assignedRole]);
  }
};
```

5. Click **Deploy**
6. Go back to **Actions → Flows → Login**
7. Drag your action from the right panel into the flow (between Start and Complete)
8. Click **Apply**

### Step 6: Configure Your Environment Files

#### Frontend Environment
```bash
cp frontend/.env.local.example frontend/.env.local
```

Edit `frontend/.env.local` with YOUR credentials:
```
VITE_AUTH0_DOMAIN=your-tenant.auth0.com
VITE_AUTH0_CLIENT_ID=your-client-id-from-step-2
VITE_AUTH0_AUDIENCE=https://your-username-capstone-api/
```

#### Backend Environment
```bash
cp env.dev.example env.dev
```

Edit `env.dev` with YOUR credentials:
```
DEBUG=1
SECRET_KEY=foo
DJANGO_ALLOWED_HOSTS=localhost 127.0.0.1 [::1] backend

AUTH0_DOMAIN=your-tenant.auth0.com
AUTH0_CLIENT_ID=your-client-id-from-step-2
AUTH0_AUDIENCE=https://your-username-capstone-api/

SQL_ENGINE=django.db.backends.postgresql
SQL_DATABASE=capstone_projects_dev
SQL_USER=user123
SQL_PASSWORD=user123
SQL_HOST=db
SQL_PORT=5432
DATABASE=postgres
```

#### Update Router Configuration

Edit `frontend/src/router/index.js` line 14:
```javascript
const ROLE_KEY = 'https://your-username-capstone-api/roles';
```

Edit `frontend/src/components/ProfileCreate.vue` line 16:
```javascript
const ROLE_KEY = 'https://your-username-capstone-api/roles';
```

Edit `frontend/src/App.vue` line 10:
```javascript
const ROLE_KEY = 'https://your-username-capstone-api/roles';
```

### Step 7: Build and Start Containers
```bash
docker-compose -f docker-compose.dev.yml build
docker-compose -f docker-compose.dev.yml up
```

---

## Common Setup Steps (Both Options)

### Verify Services are Running

After starting your containers, open your browser and check:
- **Frontend:** http://localhost:5173 (should show login page)
- **Backend API:** http://localhost:8000/admin (should show Django admin)
- **Database:** Running on port 5432 (internal to Docker)

### First Time Container Cleanup (If Needed)

If you've run the containers before and encounter issues:
```bash
# Clean up old volumes
docker volume rm capstone-design-manager_frontend_node_modules
docker volume rm capstone-design-manager_postgres_data

# Rebuild and start
docker-compose -f docker-compose.dev.yml build
docker-compose -f docker-compose.dev.yml up
```

---

## How the System Works

### Authentication Flow

1. **User clicks login button** (Student or Sponsor)
   - Frontend calls `loginWithRedirect()` with role parameter
   - Example: `?role=student`

2. **Auth0 Universal Login**
   - User authenticates via Auth0
   - Can sign up with email/password or social providers

3. **Login Action executes**
   - Checks if user already has a role
   - If first login, assigns role based on button clicked
   - Adds email to access token
   - Adds roles to both ID token and access token

4. **Redirect back to app**
   - User lands on appropriate dashboard based on role
   - If no profile exists, redirected to profile creation

5. **Profile Creation (First Login Only)**
   - User fills out role-specific profile form
   - Email is auto-populated from Auth0 token
   - Backend saves profile with authenticated user's email

6. **Subsequent Logins**
   - User automatically redirected to dashboard
   - Profile already exists
   - Role persists across sessions

### Token Structure

#### ID Token (used by frontend)
```json
{
  "email": "user@example.com",
  "sub": "auth0|123456",
  "https://backend-api-capstone/email": "user@example.com",
  "https://backend-api-capstone/roles": ["student"]
}
```

#### Access Token (used by backend)
```json
{
  "sub": "auth0|123456",
  "aud": "https://backend-api-capstone/",
  "https://backend-api-capstone/email": "user@example.com",
  "https://backend-api-capstone/roles": ["student"]
}
```

---

## User Features

### Profile Management
- **Create Profile:** After first login, users must complete their profile
- **Edit Profile:** Available via "Edit Profile" link in sidebar (bottom)
- **Email Display:** Email shown as read-only (cannot be changed)

### Role-Specific Forms

**Student Profile Fields:**
- First Name (required)
- Last Name (required)
- Middle Name (optional)
- Preferred Name (optional)
- CWID (required, 8 digits)
- Class Code (optional)
- Major Code (optional)

**Sponsor Profile Fields:**
- First Name (required)
- Last Name (required)
- Organization (optional)
- Phone Number (optional)

---

## Route Access Control

| Route | Accessible By | Description |
|-------|---------------|-------------|
| `/` | Everyone | Login page |
| `/student` | Students only | Student dashboard |
| `/sponsor` | Sponsors only | Sponsor dashboard |
| `/student/projects` | Students only | Browse projects |
| `/student/submit` | Students only | Submit rankings |
| `/sponsor/submit` | Sponsors only | Submit project |
| `/sponsor/feedback` | Sponsors only | Submit feedback |
| `/projects/:id` | Authenticated users | View project details |
| `/profile/create` | Authenticated users | Create profile (first login) |
| `/profile/edit` | Authenticated users | Edit profile |

---

## Development Commands

### Start Services
```bash
docker-compose -f docker-compose.dev.yml up
```

### Stop Services
```bash
docker-compose -f docker-compose.dev.yml down
```

### Rebuild After Code Changes
```bash
# Rebuild backend only
docker-compose -f docker-compose.dev.yml build backend
docker-compose -f docker-compose.dev.yml up -d backend

# Rebuild frontend only
docker-compose -f docker-compose.dev.yml build frontend
docker-compose -f docker-compose.dev.yml up -d frontend

# Rebuild all
docker-compose -f docker-compose.dev.yml build
docker-compose -f docker-compose.dev.yml up -d
```

### View Logs
```bash
# All services
docker-compose -f docker-compose.dev.yml logs -f

# Backend only
docker logs capstone-design-manager-backend-1 -f

# Frontend only
docker logs capstone-design-manager-frontend-1 -f
```

### Access Django Admin
```bash
# Create superuser (first time)
docker exec -it capstone-design-manager-backend-1 python manage.py createsuperuser

# Visit http://localhost:8000/admin
```

### Database Migrations
```bash
# Run migrations
docker exec -it capstone-design-manager-backend-1 python manage.py migrate

# Create new migrations
docker exec -it capstone-design-manager-backend-1 python manage.py makemigrations
```

---

## Troubleshooting

### "Callback URL mismatch" error
**Problem:** Auth0 rejects the callback after login.

**Solution:**
1. Go to Auth0 Dashboard → Applications → Your App
2. Verify **Allowed Callback URLs** contains: `http://localhost:5173/`
3. Save and try again

### "Service not found" or "access_denied" error
**Problem:** Auth0 API audience is incorrect or missing.

**Solution:**
1. Verify `frontend/.env.local` has: `VITE_AUTH0_AUDIENCE=https://backend-api-capstone/`
2. Verify `env.dev` has: `AUTH0_AUDIENCE=https://backend-api-capstone/`
3. Restart containers: `docker-compose -f docker-compose.dev.yml restart`

### "Email field is required" error
**Problem:** Login Action isn't adding email to access token.

**Solution:**
1. Go to Auth0 Dashboard → Actions → Flows → Login
2. Verify your action includes the email claim code (see Step 4 above)
3. Ensure action is **Deployed** (not just saved)
4. Ensure action is **in the flow** (dragged between Start and Complete)
5. Log out completely and log in again

### Email shows as API key or "auth0|123456"
**Problem:** Email claim not found in access token.

**Solution:**
1. Verify Login Action is adding email (see above)
2. Clear browser cache and cookies
3. Log out and log in again (fresh tokens needed)
4. Check backend logs: `docker logs capstone-design-manager-backend-1 --tail 50`
   - Look for `[DEBUG] Token payload:` to see what's in the token

### Wrong profile form appears (Student sees Sponsor form)
**Problem:** Role namespace mismatch.

**Solution:**
1. Verify Login Action uses namespace: `https://backend-api-capstone/`
2. Verify `frontend/src/router/index.js` line 14 uses: `const ROLE_KEY = 'https://backend-api-capstone/roles';`
3. Verify `frontend/src/components/ProfileCreate.vue` line 16 uses same namespace
4. Restart frontend: `docker-compose -f docker-compose.dev.yml restart frontend`

### "Token validation failed: Signature verification failed"
**Problem:** JWT algorithm mismatch or wrong keys.

**Solution:**
1. This should be fixed. If you still see this:
2. Verify API exists in Auth0 with identifier `https://backend-api-capstone/`
3. Verify `audience` is set in `frontend/src/main.js` (line 14)
4. Check JWKS endpoint is accessible: https://dev-qjyd077ykn3qqq7v.us.auth0.com/.well-known/jwks.json

### "DisallowedHost" error (backend:8000)
**Problem:** Django doesn't allow the hostname in requests.

**Solution:**
1. Open `env.dev` in project root
2. Verify it contains: `DJANGO_ALLOWED_HOSTS=localhost 127.0.0.1 [::1] backend`
3. Restart backend: `docker-compose -f docker-compose.dev.yml restart backend`

### Database connection errors
**Problem:** Backend can't connect to PostgreSQL.

**Solution:**
1. Ensure database container is running: `docker ps`
2. Check database logs: `docker logs capstone-design-manager-db-1`
3. Restart all containers: `docker-compose -f docker-compose.dev.yml restart`

### Port already in use
**Problem:** Port 5173 (frontend) or 8000 (backend) already in use.

**Solution:**
```bash
# Find what's using the port (Mac/Linux)
lsof -i :5173
lsof -i :8000

# Kill the process or stop the conflicting service
# Then restart containers
docker-compose -f docker-compose.dev.yml up
```

---

## Testing the Setup

### Test 1: Student Login and Profile Creation
1. Visit http://localhost:5173
2. Click "I am a Student"
3. Sign up or log in with test credentials
4. Should be redirected to profile creation
5. Email should display at top of form
6. Fill in student fields (First Name, Last Name, CWID)
7. Submit - should redirect to `/student` dashboard
8. Click "Edit Profile" in sidebar - should show profile with read-only email

### Test 2: Sponsor Login and Profile Creation
1. Log out
2. Click "I am a Sponsor"
3. Sign up or log in with different test credentials
4. Should be redirected to profile creation
5. Email should display at top
6. Fill in sponsor fields (First Name, Last Name, Organization)
7. Submit - should redirect to `/sponsor` dashboard

### Test 3: Role Persistence
1. Log out
2. Log in again as same user
3. Should skip profile creation and go directly to dashboard
4. Role should persist (student sees student dashboard, sponsor sees sponsor dashboard)

### Test 4: Token Debugging
1. After logging in, click "DEBUG" button (bottom right of screen)
2. Verify the debug overlay shows:
   - ✅ Authenticated: Yes
   - ✅ User Email: (your email)
   - ✅ Roles: student or sponsor
   - ✅ Full User Object contains `https://backend-api-capstone/roles` and `https://backend-api-capstone/email`

---

## Additional Notes

### Security Considerations
- **Never commit `.env.local` files to git** (already in `.gitignore`)
- Auth0 Client Secret is not needed for SPA (Single Page Application)
- Access tokens expire after 24 hours by default
- Refresh tokens allow seamless re-authentication

### Production Deployment
When deploying to production:
1. Update `VITE_AUTH0_AUDIENCE` to production API URL
2. Update Auth0 Application URLs to production domain
3. Update Login Action namespace to production URL
4. Use environment-specific `.env` files
5. Enable HTTPS/SSL certificates
6. Configure proper CORS settings

### Known Limitations
- Email cannot be changed after profile creation
- Users can only have one role (Student OR Sponsor, not both)
- Role switching requires manual Auth0 dashboard intervention
- Profile must be completed before accessing any features

---

## Getting Help

If you encounter issues not covered here:
1. Check backend logs: `docker logs capstone-design-manager-backend-1 --tail 100`
2. Check frontend console in browser dev tools (F12)
3. Check Auth0 logs: Auth0 Dashboard → Monitoring → Logs
4. Review the `problem.md` file for historical debugging context
5. Contact the team lead or check project documentation

---

## Useful Resources

- **Auth0 Documentation:** https://auth0.com/docs
- **Auth0 Vue SDK:** https://github.com/auth0/auth0-vue
- **Django REST Framework:** https://www.django-rest-framework.org/
- **Docker Compose:** https://docs.docker.com/compose/

---

## Summary Checklist for New Developers

- [ ] Repository cloned and on correct branch
- [ ] Docker and Docker Compose installed
- [ ] `.env.local` exists in `frontend/` directory
- [ ] `env.dev` exists in project root
- [ ] Containers built: `docker-compose -f docker-compose.dev.yml build`
- [ ] Containers started: `docker-compose -f docker-compose.dev.yml up`
- [ ] Frontend accessible at http://localhost:5173
- [ ] Backend accessible at http://localhost:8000
- [ ] Can log in as Student
- [ ] Can log in as Sponsor
- [ ] Profile creation works
- [ ] "Edit Profile" appears in sidebar
- [ ] Email displays correctly (not API key)
