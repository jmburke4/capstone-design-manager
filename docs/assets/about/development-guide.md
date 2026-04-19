# Development Guide - Capstone Design Manager

This guide covers the development practices, architecture, and patterns for contributing to the Capstone Design Manager project.

---

## Table of Contents

1. [Project Architecture](#project-architecture)
2. [Technology Stack](#technology-stack)
3. [Code Organization](#code-organization)
4. [Database & Models](#database--models)
5. [Backend Development](#backend-development)
6. [Frontend Development](#frontend-development)
7. [Authentication & Authorization](#authentication--authorization)
8. [Common Development Tasks](#common-development-tasks)

---

## Project Architecture

The Capstone Design Manager is a full-stack web application designed to streamline the assignment of senior design projects to student teams.

### System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     Vue 3 Frontend (Vite)                   │
│  ├─ Components (reusable UI elements)                       │
│  ├─ Pages (route-based views)                               │
│  ├─ Services (API client layer)                             │
│  └─ Stores (Pinia - state management)                       │
└──────────────────────┬──────────────────────────────────────┘
                       │ HTTP/REST API
                       │ Bearer Token Auth
┌──────────────────────▼──────────────────────────────────────┐
│            Django REST API Backend (DRF)                    │
│  ├─ Core (Django settings, URLs, middleware)                │
│  ├─ User Module (Sponsor, Student models & views)           │
│  ├─ Project Module (Project, Preference, Assignment, etc.)  │
│  ├─ Emails Module (email templates & sending)               │
│  └─ Middleware (CORS, Auth0, etc.)                          │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│              PostgreSQL Database                            │
│  ├─ Users (Auth0 integration)                               │
│  ├─ Projects, Preferences, Assignments                      │
│  └─ Attachments (S3 storage references)                     │
└─────────────────────────────────────────────────────────────┘
```

### Authentication Flow

1. **Frontend**: User initiates login via Auth0
2. **Auth0**: Authenticates user and returns ID token + access token
3. **Frontend**: Stores tokens and redirects based on user role
4. **API Requests**: Frontend includes Bearer token in `Authorization` header
5. **Backend**: Validates token and checks user permissions

See `README.md - Auth0 Setup` for configuration details.

---

## Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Frontend** | Vue 3 | UI framework with SFCs (Single File Components) |
| | Vite | Build tool and dev server |
| | Pinia | State management (stores) |
| | FormKit | Form building and validation |
| | Auth0 Vue | Client-side authentication |
| **Backend** | Django | Web framework |
| | Django REST Framework (DRF) | REST API construction |
| | PostgreSQL | Relational database |
| | Auth0 | Identity management |
| | MinIO | File storage |
| | SMTP | Email protocol |

---

## Code Organization

### Backend Structure

```
backend/
├── core/                    # Django project configuration
│   ├── settings.py          # Django settings, database, apps, middleware
│   ├── urls.py              # Root URL routing
│   ├── asgi.py              # ASGI config (production)
│   ├── wsgi.py              # WSGI config (production)
│
├── user/                    # User module (Student, Sponsor models)
│   ├── models.py            # Student, Sponsor models
│   ├── serializers.py       # DRF serializers for user models
│   ├── views.py             # ViewSets for CRUD operations
│   ├── urls.py              # URL routing for user endpoints
│   ├── authentication.py    # Custom Auth0 token validation
│   ├── admin.py             # Django admin customizations
│   └── migrations/          # Database migration scripts
│
├── project/                 # Project module (Project, Assignment, Preference)
│   ├── models.py            # Project, Assignment, Preference, Feedback, Attachment models
│   ├── serializers.py       # DRF serializers
│   ├── views.py             # ViewSets for CRUD operations
│   ├── urls.py              # URL routing
│   ├── storage.py           # S3 storage configuration
│   ├── admin.py             # Django admin and email actions
│   └── migrations/          # Database migration scripts
│
├── emails/                  # Email module
│   ├── views.py             # Email sending logic
│   ├── utils.py             # Email utilities
│   ├── urls.py              # Email endpoints
│   ├── templates/           # Email templates (HTML/TXT)
│   │   ├── sponsor_outreach.html
│   │   ├── project_presentation.html
│   │   └── ...
│   └── migrations/
│
├── manage.py                # Django CLI
├── requirements.txt         # Python dependencies
├── pytest.ini               # Pytest configuration
├── Dockerfile               # Container definition
└── entrypoint.sh            # Container entry script
```

### Frontend Structure

```
frontend/
├── src/
│   ├── main.js              # App initialization (Auth0, Pinia, FormKit, Router)
│   ├── App.vue              # Root component
│   ├── style.css            # Global styles
│   │
│   ├── components/          # Reusable components
│   │   ├── SponsorEditProjectForm.vue
│   │   ├── StudentProjectList.vue
│   │   └── ...
│   │
│   ├── router/              # Vue Router configuration
│   │   └── index.js         # Route definitions
│   │
│   ├── services/            # API and utility services
│   │   └── api.js           # Axios client, API methods
│   │
│   ├── stores/              # Pinia stores (state management)
│   │   └── *.js             # Stores for different domains
│   │
│   └── assets/              # Static assets (images, icons)
│
├── vite.config.js           # Vite configuration
├── index.html               # HTML entry point
├── package.json             # NPM dependencies
└── Dockerfile               # Container definition
```

---

## Database & Models

### ER Diagram

An ER diagram is available at `backend/erd.uxf` (UMLet format).

### Core Models

#### User Module

**Sponsor**
- Represents project sponsors who propose projects for students
- Fields: `first_name`, `last_name`, `email`, `organization`, `phone_number`, `projects_allowed`
- Allows multiple projects (limited by `projects_allowed`)
- Contains admin actions for sending outreach/presentation emails

**Student**
- Represents capstone students who can be assigned to projects
- Fields: `cwid` (unique), `first_name`, `last_name`, `email`, `description`, `class_code`, `major_code`
- CWID must be exactly 8 digits
- Information expected to be imported as .csv via Blackboard by admin

#### Project Module

**Project**
- Represents a senior design project proposed by a sponsor
- Fields: `name`, `description`, `sponsor` (FK), `website`, `status`, `sponsor_availability`
- Status choices: `PENDING`, `IN_PROGRESS`, `COMPLETE`, `CANCELLED`
- Constraint: unique combination of (name, sponsor) - a sponsor cannot have duplicate project names

**Assignment**
- Represents the assignment of a student to a project for a semester
- Fields: `project` (FK), `student` (FK), `semester`, `status`

**Preference**
- Represents a student's preference ranking for projects
- Fields: `student` (FK), `project` (FK), `preference_rank`, `semester`
- Allows tracking of project preferences

**Feedback**
- Represents feedback about a project or assignment
- Fields: `project` (FK), `semester`, `feedback_text`

**Attachment**
- Represents file or link attachments to projects
- Fields: `project` (FK), `file` (S3), `link`, `created_at`
- Supports file uploads to S3 and external links

### Migrations Best Practices

1. **Always run migrations before code changes**: Ensures database is current
   ```bash
   docker-compose -f docker-compose.dev.yml exec backend python manage.py migrate
   ```

2. **When adding/modifying models**:
   ```bash
   # Create migration
   docker-compose -f docker-compose.dev.yml exec backend python manage.py makemigrations
   
   # Review generated migration in migrations/ folder
   
   # Apply migration
   docker-compose -f docker-compose.dev.yml exec backend python manage.py migrate
   ```

3. **Keep migrations in version control**: Migrations are part of the codebase; commit them with your model changes

---

## Backend Development

### Django Apps Structure

The backend uses three main Django apps:

1. **`project`** - Non-user domain objects (projects, assignments, preferences)
2. **`user`** - User models and user-related data (students, sponsors)
3. **`emails`** - Email functionality and templates

### Adding a New Model

#### Step 1: Define the Model

Add to `backend/<app>/models.py`:

```python
from django.db import models
from django.core.validators import MinValueValidator

class SemesterConfig(models.Model):
    """Configuration for a semester (e.g., student count, project count)"""
    
    name = models.CharField(max_length=50)
    start_date = models.DateField()
    end_date = models.DateField()
    max_projects_per_sponsor = models.IntegerField(
        default=3,
        validators=[MinValueValidator(1)]
    )
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-start_date']
    
    def __str__(self):
        return f"{self.name} ({self.start_date.year})"
```

**Guidelines**:
- Document fields with docstrings
- Order fields by importance (required fields first)
- Use `on_delete=models.PROTECT` for critical foreign keys
- Include `created_at` and `updated_at` fields for audit trails
- Add helpful `__str__` representation

#### Step 2: Create Serializer

Add to `backend/<app>/serializers.py`:

```python
from rest_framework import serializers
from .models import SemesterConfig

class SemesterConfigSerializer(serializers.ModelSerializer):
    class Meta:
        model = SemesterConfig
        fields = [
            'id',
            'name',
            'start_date',
            'end_date',
            'max_projects_per_sponsor',
            'created_at',
            'updated_at'
        ]
        read_only_fields = ['created_at', 'updated_at']
```

#### Step 3: Create ViewSet

Add to `backend/<app>/views.py`:

```python
from rest_framework import viewsets, permissions
from .models import SemesterConfig
from .serializers import SemesterConfigSerializer

class SemesterConfigViewSet(viewsets.ModelViewSet):
    """ViewSet for CRUD operations on SemesterConfig"""
    queryset = SemesterConfig.objects.all()
    serializer_class = SemesterConfigSerializer
    permission_classes = [permissions.IsAuthenticated]
```

#### Step 4: Register Routes

Add to `backend/<app>/urls.py`:

```python
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import SemesterConfigViewSet

router = DefaultRouter()
router.register(r'semester-configs', SemesterConfigViewSet, basename='semester-config')

urlpatterns = [
    path('', include(router.urls)),
]
```

#### Step 5: Create and Run Migrations

```bash
docker-compose -f docker-compose.dev.yml exec backend python manage.py makemigrations
docker-compose -f docker-compose.dev.yml exec backend python manage.py migrate
```

#### Step 6: Test

Visit `http://localhost:8000/api/v1/semester-configs/` to test the browsable API.

### API Response Patterns

Standard Django REST Framework response patterns:

**Single Object (GET)**:
```json
{
  "id": 1,
  "name": "Fall 2024",
  "start_date": "2024-08-15",
  "end_date": "2024-12-15",
  "max_projects_per_sponsor": 3,
  "created_at": "2024-01-01T12:00:00Z",
  "updated_at": "2024-01-15T12:00:00Z"
}
```

**List (GET /api/v1/semester-configs/)**:
```json
{
  "count": 5,
  "next": null,
  "previous": null,
  "results": [
    { /* semester config 1 */ },
    { /* semester config 2 */ }
  ]
}
```

**Errors (4xx/5xx)**:
```json
{
  "detail": "Not found."
}
```

or

```json
{
  "field_name": [
    "This field may not be blank."
  ]
}
```

---

## Frontend Development

### Project Structure Conventions

- **Pages**: Route-level components (e.g., `StudentDashboard.vue`, `SponsorEditProjectForm.vue`)
- **Components**: Reusable elements (e.g., `ProjectCard.vue`, `ConfirmationModal.vue`)
- **Services**: API layer (`services/api.js`)
- **Stores**: Pinia state management (e.g., `stores/projectStore.js`)

### Using FormKit for Forms

FormKit is preconfigured in `main.js` with Genesis theme (with some overrides). Use it for form building and validation:

```vue
<script setup>
import { ref } from 'vue';
import { FormKit } from '@formkit/vue';
import apiService from '../services/api';
import { useAuth0 } from '@auth0/auth0-vue';

const { getAccessTokenSilently } = useAuth0();
const formData = ref({
  name: '',
  description: '',
  website: '',
  availability: ''
});

async function handleSubmit(data) {
  try {
    const token = await getAccessTokenSilently();
    apiService.setToken(token);
    
    await apiService.createProject(data);
    alert('Project created successfully!');
  } catch (error) {
    console.error('Error:', error);
    alert(error.message || 'Submission failed');
  }
}
</script>

<template>
  <FormKit
    type="form"
    @submit="handleSubmit"
    submit-label="Submit"
  >
    <FormKit
      type="text"
      name="name"
      label="Project Name"
      validation="required|length:5,100"
    />
    
    <FormKit
      type="textarea"
      name="description"
      label="Description"
      validation="required|length:20,2000"
    />
    
    <FormKit
      type="url"
      name="website"
      label="Website"
      validation="url"
      placeholder="https://..."
    />
    
    <FormKit
      type="textarea"
      name="availability"
      label="Sponsor Availability"
      validation="required"
      help="Days and times available (e.g., Mon-Wed 9AM-12PM)"
    />
  </FormKit>
</template>
```

**FormKit Validation Rules** (common):
- `required` - Field is mandatory
- `email` - Valid email format
- `url` - Valid URL format
- `length:min,max` - String length constraints
- `number` - Must be a number
- `matches:regex` - Regex pattern matching

See [FormKit Docs](https://formkit.com/essentials/validation) for all options.

### Making API Calls

The `ApiService` class (in `services/api.js`) provides a centralized API client:

```javascript
// Get profile of current user
const profile = await apiService.getProfile();

// Get projects by sponsor
const projects = await apiService.getProjectsBySponsor(sponsorId);

// Create a project
const newProject = await apiService.createProject({
  name: 'Web Portal',
  description: '...',
  website: 'https://example.com',
  sponsor: sponsorId,
  sponsor_availability: 'Mon-Fri 9AM-5PM'
});

// Update a project
await apiService.putProject(projectData, projectId);

// Delete a project
await apiService.deleteProject(projectId);
```

### Using Pinia for State Management

Example store in `stores/projectStore.js`:

```javascript
import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import apiService from '../services/api';

export const useProjectStore = defineStore('project', () => {
  const projects = ref([]);
  const loading = ref(false);
  const error = ref(null);
  
  // Computed properties
  const projectCount = computed(() => projects.value.length);
  
  // Actions
  async function fetchProjects(sponsorId) {
    loading.value = true;
    try {
      projects.value = await apiService.getProjectsBySponsor(sponsorId);
      error.value = null;
    } catch (err) {
      error.value = err.message;
    } finally {
      loading.value = false;
    }
  }
  
  function clearProjects() {
    projects.value = [];
  }
  
  return {
    projects,
    loading,
    error,
    projectCount,
    fetchProjects,
    clearProjects
  };
});
```

**Usage in Components**:

```vue
<script setup>
import { useProjectStore } from '../stores/projectStore';

const projectStore = useProjectStore();

// Access state
const { projects, loading } = projectStore;

// Call actions
await projectStore.fetchProjects(sponsorId);
</script>
```

---

## Authentication & Authorization

### Auth0 Integration

Auth0 is configured in both frontend (`main.js`) and backend (`user/authentication.py`).

**Frontend (Vue)**:
- Auth0 Vue SDK handles OAuth flow
- Environmental variables: `VITE_AUTH0_DOMAIN`, `VITE_AUTH0_CLIENT_ID`, `VITE_AUTH0_AUDIENCE`
- Token obtained via `getAccessTokenSilently()` from `useAuth0()`
- Token passed in `Authorization: Bearer <token>` header

**Backend (Django)**:
- Custom authentication in `user/authentication.py` validates Auth0 tokens
- Token verified against Auth0's public key
- User identified via Auth0 `sub` (subject) claim


---

## Common Development Tasks

### Task 1: Add a New Field to a Model

**Example**: Add a `website` field to the Sponsor model

1. **Edit Model** (`backend/user/models.py`):
   ```python
   class Sponsor(models.Model):
       # ... existing fields ...
       website = models.URLField(blank=True, null=True)
       """[Optional] Sponsor's website"""
   ```

2. **Update Serializer** (`backend/user/serializers.py`):
   ```python
   class SponsorSerializer(serializers.ModelSerializer):
       class Meta:
           fields = [
               # ... existing fields ...
               'website'
           ]
   ```

3. **Create & Run Migration**:
   ```bash
   docker-compose -f docker-compose.dev.yml exec backend python manage.py makemigrations
   docker-compose -f docker-compose.dev.yml exec backend python manage.py migrate
   ```

4. **Update Frontend** (if needed in forms):
   ```vue
   <FormKit
     type="url"
     name="website"
     label="Sponsor Website"
     validation="url"
   />
   ```

### Task 2: Create a New API Endpoint

**Example**: Create endpoint to get projects by status

1. **Add Method to Serializer** (if needed):
   ```python
   class ProjectSerializer(serializers.ModelSerializer):
       class Meta:
           model = Project
           fields = ['id', 'name', 'status', 'created_at']
   ```

2. **Add Custom Action to ViewSet** (`backend/project/views.py`):
   ```python
   from rest_framework.decorators import action
   from rest_framework.response import Response
   
   class ProjectViewSet(viewsets.ModelViewSet):
       @action(detail=False, methods=['get'])
       def by_status(self, request):
           status = request.query_params.get('status')
           projects = Project.objects.filter(status=status)
           serializer = self.get_serializer(projects, many=True)
           return Response(serializer.data)
   ```

3. **Access at**: `GET /api/v1/projects/by_status/?status=IN_PROGRESS`

### Task 3: Create a New Frontend Page/Component

**Example**: Create a "Project Details" page

1. **Create Component** (`frontend/src/components/ProjectDetails.vue`):
   ```vue
   <script setup>
   import { ref, onMounted } from 'vue';
   import { useRoute } from 'vue-router';
   import { useAuth0 } from '@auth0/auth0-vue';
   import apiService from '../services/api';

   const route = useRoute();
   const { getAccessTokenSilently } = useAuth0();
   const projectId = route.params.id;
   const project = ref(null);
   const loading = ref(true);

   onMounted(async () => {
     const token = await getAccessTokenSilently();
     apiService.setToken(token);
     project.value = await apiService.getProject(projectId);
     loading.value = false;
   });
   </script>

   <template>
     <div class="container">
       <p v-if="loading">Loading...</p>
       <div v-else>
         <h1>{{ project.name }}</h1>
         <p>{{ project.description }}</p>
         <!-- More content -->
       </div>
     </div>
   </template>
   ```

2. **Add Route** (`frontend/src/router/index.js`):
   ```javascript
   {
     path: '/projects/:id',
     name: 'ProjectDetails',
     component: () => import('../components/ProjectDetails.vue')
   }
   ```

3. **Link from Other Pages**:
   ```vue
   <router-link :to="`/projects/${project.id}`">View Details</router-link>
   ```

---

## Quick Reference: Common Commands

### Docker & Django

```bash
# Build containers
docker-compose -f docker-compose-dev.yml build

# Start containers
docker-compose -f docker-compose.dev.yml up -d

# Run migrations
docker-compose -f docker-compose.dev.yml exec backend python manage.py migrate

# Create new migration
docker-compose -f docker-compose.dev.yml exec backend python manage.py makemigrations

# Django shell (for testing queries)
docker-compose -f docker-compose.dev.yml exec backend python manage.py shell

# Create superuser
docker-compose -f docker-compose.dev.yml exec backend python manage.py createsuperuser

# Stop containers
docker-compose -f docker-compose.dev.yml stop

# Stop containers and remove them, -v removing volumes
docker-compose -f docker-compose.dev.yml down -v

# View logs
docker-compose -f docker-compose.dev.yml logs -f backend
```

---

## Resources

- [Django REST Framework Documentation](https://www.django-rest-framework.org/)
- [Vue 3 Documentation](https://vuejs.org/)
- [FormKit Documentation](https://formkit.com/)
- [Pinia Documentation](https://pinia.vuejs.org/)
- [Auth0 Documentation](https://auth0.com/docs)