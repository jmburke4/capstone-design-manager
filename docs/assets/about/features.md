# Capstone Design Manager - Features

This document outlines all features implemented in the Capstone Design Manager application.

## User Roles

| Role | Description |
|------|-------------|
| **Student** | Enrolled UA CS student who gets assigned to a project |
| **Sponsor** | External professional who submits project ideas |
| **Admin** | Faculty/staff who manages the system |

---

## Authentication Features

- **OAuth Integration** - Users can log in via Google, GitHub, or email/password
- **Role-based Access** - Students, Sponsors, and Admins see different interfaces
- **Session Management** - Auth0 handles authentication securely
- **Profile Management** - Users can update their profile information

---

## Student Features

### Dashboard
- View semester information
- View submission status
- View top 5 rankings
- View project assignment (after deadline)

### Project Gallery
- Browse all available projects
- View project details (description, sponsor, website)
- Search and filter projects

### Submit Rankings
- Rank up to 15 projects
- 5 projects per rank level (Rank 1, 2, 3)
- Edit rankings before deadline
- Clear feedback on ranking requirements

### Profile
- Update personal information
- View CWID, major, class year

---

## Sponsor Features

### Dashboard
- View organization name
- View submitted projects count
- Quick access to all features

### Submit Project
- Submit new project proposals
- Project name, description, website
- Sponsor availability information

### Project Management
- Edit existing projects
- View all submitted projects
- Track project status (Pending, In Progress, Complete, Cancelled)

### Submit Feedback
- Add feedback for assigned students
- Track project progress
- Provide recommendations

### Profile
- Update organization name
- Update phone number
- Update website

---

## Admin Features / Django Admin Panel

### User Management
- Add/Edit/Delete students (CWID, name, email, major, class)
- Add/Edit/Delete sponsors (name, email, organization, phone)
- Set project limits per sponsor

### Project Management
- Add/Edit/Delete projects
- Change project status
- Bulk actions on projects
- Assign projects to semesters

### Semester Management
- Create semesters (Fall, Spring, Summer)
- Set assignment deadlines

### Preference & Assignment Management
- View all student rankings
- View student-to-project assignments
- Manual assignment creation

### Feedback Management
- View all sponsor feedback
- View feedback by project

### Attachment Management
- View all uploaded files
- Download attachments
- Manage external links

### Email System

**Send Emails via Admin:**
- Select multiple sponsors
- Choose email action (Outreach, Presentation)
- Fill email form and send directly

**Export as EML:**
- Export emails for manual sending
- Download EML files
- Open in email client

---

## Technical Features

### Frontend (React/Vue)
- Responsive design
- Role-based navigation
- Form validation
- Loading and error states
- Interactive project ranking

### Backend (Django)
- REST API
- PostgreSQL database
- Django admin panel
- Email templates

### Storage
- File uploads (PDF, DOCX, PPTX, PNG, JPG, ZIP)
- Max file size: 25 MB
- Google Cloud Storage integration

### Deployment
- Google Cloud Run (backend)
- Cloud SQL (PostgreSQL)
- Cloud Storage (files)
- Firebase Hosting (frontend)
- Educational credits

---

## API Endpoints

| Endpoint | Description |
|----------|-------------|
| `/api/v1/projects/` | List all projects |
| `/api/v1/sponsors/` | List all sponsors |
| `/api/v1/students/` | List all students |
| `/api/v1/profile/` | User profile |
| `/api/v1/preferences/` | Student rankings |
| `/api/v1/assignments/` | Student assignments |
| `/api/v1/feedback/` | Sponsor feedback |
| `/api/v1/attachments/` | Project attachments |
| `/api/v1/semesters/` | Semester management |

---

## Security Features

- OAuth 2.0 authentication
- Role-based access control
- Email verification

---

For more details, see the User Guide.