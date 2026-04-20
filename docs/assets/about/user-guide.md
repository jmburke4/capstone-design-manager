# User Guide - Comprehensive Documentation for the Capstone Design Manager

## Table of Contents

1. [Overview](#overview)
2. [Getting Started](#getting-started)
3. [Admin Panel](#admin-panel)
4. [Email System](#email-system)
5. [REST API](#rest-api)
6. [Frontend](#frontend)
7. [Data Models](#data-models)
8. [Troubleshooting](#troubleshooting)

---

## 1. Overview

The UA Computer Science Senior Design Projects Portal is a web application that manages the assignment of students to senior design projects. It provides:

- **Admin Panel**: For administrators to manage sponsors, students, projects, and assignments
- **REST API**: For frontend applications to interact with the data
- **Email System**: For sending outreach emails to sponsors and project presentations
- **Student Portal**: For students to submit their project preferences

### Technology Stack

**Backend:**
- Framework: Django 5.2 with Django REST Framework
- Database: PostgreSQL 17
- File Storage: MinIO (S3-compatible object storage)
- Email: SMTP (Gmail integration)

**Frontend:**
- Framework: Vue 3 with Vite
- Pinia: State management
- Styling: CSS Modules

**Infrastructure:**
- Containerization: Docker & Docker Compose
- Authentication: Auth0

### Key Concepts

- **Students**: End users who will be assigned to projects. They submit ranked preferences for which projects they want to work on.
- **Sponsors**: External individuals or organizations that provide senior design projects. Each sponsor can have multiple projects.
- **Projects**: The actual senior design work that students will complete. Each project belongs to one sponsor and has a status (Pending, In Progress, Complete, Cancelled).
- **Semesters**: Track when projects are offered. Each semester has an assignment date by which all student preferences must be submitted.
- **Preferences**: Students submit ranked preferences for projects. A student can rank up to 3 projects.
- **Assignments**: The final mapping of students to projects for a given semester.
- **Attachments**: Files or links associated with projects, including documents, images, and exported email drafts.
- **Feedback**: Notes from sponsors about project progress.

---

## 2. Getting Started

### Prerequisites
- Docker and Docker Compose
- Git

### Clone the Repository
```bash
git clone https://github.com/your-repo/capstone-design-manager.git
cd capstone-design-manager
```

### Configure Environment Variables
Copy the example environment file:
```bash
cp .env.dev .env
```

Edit `.env` with your configuration (see section on environment variables in the full documentation).

### Start the Application
Using Docker Compose:
```bash
docker-compose -f docker-compose.dev.yml up -d
```

This starts:
- **Backend**: http://localhost:8000
- **Frontend**: http://localhost:5173
- **Admin Panel**: http://localhost:8000/admin
- **Mailhog**: http://localhost:8025
- **MinIO Console**: http://localhost:9000

### Run Database Migrations
```bash
docker-compose -f docker-compose.dev.yml exec backend python manage.py migrate
```

### Create a Superuser
```bash
docker-compose -f docker-compose.dev.yml exec backend python manage.py createsuperuser
```

### Access the Application
- **Admin Panel**: http://localhost:8000/admin
- **Frontend**: http://localhost:5173

### Creating Sample Data
```bash
docker-compose -f docker-compose.dev.yml exec backend python manage.py create_sample_data
```

---

## 3. Admin Panel

The admin panel provides full management capabilities for all system data. Access it at http://localhost:8000/admin

### Navigation
The admin panel is organized into sections:
- **PROJECT**: Projects, Semesters, Preferences, Assignments, Attachments, Feedback
- **USER**: Sponsors, Students
- **EMAILS**: Email management

### Managing Sponsors
1. Go to **USER** > **Sponsors**
2. Add, edit, or delete sponsors
3. View projects linked to each sponsor

### Managing Students
1. Go to **USER** > **Students**
2. Add students with CWID, name, email, major code, and class code

### Managing Projects
1. Go to **PROJECT** > **Projects**
2. Add projects with name, sponsor, description, status, website

### Managing Semesters
1. Go to **PROJECT** > **Semesters**
2. Create semesters with assignment dates

### Managing Preferences
1. Go to **PROJECT** > **Preferences**
2. View and manage student project preferences

### Managing Attachments
1. Go to **PROJECT** > **Attachments**
2. Add file uploads, links, or email exports (EML/HTML)

### Managing Feedback
1. Go to **PROJECT** > **Feedback**
2. Add feedback notes from sponsors

### Sponsor Email Actions
From the Sponsors list, you can:
- **Send Sponsor Outreach Email** - Send outreach to multiple sponsors
- **Export Sponsor Outreach as EML** - Create email drafts for download
- **Send Project Presentation Email** - Send presentation invitations
- **Export Project Presentation as EML** - Create presentation email drafts

---

## 4. Email System

### Email Templates

**Sponsor Outreach Email**: Sent to potential sponsors to recruit project ideas.

**Project Presentation Email**: Sent to sponsors with their presentation time slot.

### Sending Emails via Admin Panel
1. Go to **USER** > **Sponsors**
2. Select one or more sponsors
3. Choose an email action
4. Fill in details and send

### SMTP Configuration
Configure in `.env`:
```
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password
```

For Gmail, use an App Password (enable 2FA first, then generate from Google Account > Security > App passwords).

### Exporting Emails as EML Drafts
Instead of sending directly, export as EML files that open in the user's default email client:
1. Select sponsors
2. Choose **Export as EML** action
3. Create attachments
4. Download from Attachments page

### API Endpoints
- `POST /api/v1/emails/send` - Send custom email
- `POST /api/v1/emails/sponsor-outreach` - Send sponsor outreach
- `POST /api/v1/emails/project-presentation` - Send project presentation

---

## 5. REST API

Base URL: `http://localhost:8000/api/v1/`

### Authentication
Uses Auth0 JWT tokens. Include in header:
```
Authorization: Bearer <your-token>
```

### Key Endpoints

**Projects:**
- `GET /api/v1/projects/` - List projects
- `POST /api/v1/projects/` - Create project
- `GET /api/v1/projects/{id}/` - Get project

**Students:**
- `GET /api/v1/students/` - List students
- `POST /api/v1/students/` - Create student

**Preferences:**
- `GET /api/v1/preferences/` - List preferences
- `PUT /api/v1/preferences/` - Bulk update preferences

**Assignments:**
- `GET /api/v1/assignments/` - List assignments

**Attachments:**
- `GET /api/v1/attachments/` - List attachments
- `GET /api/v1/attachments/{id}/download/` - Download file

**Feedback:**
- `GET /api/v1/feedback/` - List feedback
- `POST /api/v1/feedback/` - Create feedback

---

## 6. Frontend Application

The frontend provides a user-friendly interface for students.

### Access
URL: http://localhost:5173

### Student Features
- **Login**: Auth0 authentication
- **Dashboard**: View semester info and assignments
- **Browse Projects**: View available projects
- **Submit Preferences**: Rank 15 projects (high, medium, low priority)
- **View Assignment**: See final project assignment

---

## 7. Data Models

### Sponsor
| Field | Type | Description |
|-------|------|-------------|
| first_name | string | Sponsor's first name |
| last_name | string | Sponsor's last name |
| email | email | Sponsor's email (unique) |
| organization | string | Company or organization |
| phone_number | string | Contact phone number |
| projects_allowed | integer | Max projects sponsor can offer |

### Student
| Field | Type | Description |
|-------|------|-------------|
| cwid | string | 8-digit CWID (unique) |
| first_name | string | First name |
| last_name | string | Last name |
| email | string | Email address |
| major_code | string | Major (e.g., CS, CYS) |
| class_code | string | Class year (FR, SO, JR, SR, GR) |

### Project
| Field | Type | Description |
|-------|------|-------------|
| name | string | Project name |
| description | text | Project description |
| sponsor | FK(Sponsor) | Project sponsor |
| status | choice | PNDG, IP, CMPL, CNCL |
| website | URL | Project website |

### Semester
| Field | Type | Description |
|-------|------|-------------|
| semester | choice | Fall, Spring, Summer |
| year | integer | Year |
| assignment_date | datetime | Preference deadline |
| projects | M2M(Project) | Projects for semester |

### Preference
| Field | Type | Description |
|-------|------|-------------|
| student | FK(Student) | The student |
| project | FK(Project) | The project |
| rank | integer | Preference rank (1, 2, or 3) |
| semester | FK(Semester) | Calculated from date |

### Attachment
| Field | Type | Description |
|-------|------|-------------|
| project | FK(Project) | Associated project |
| file | file | Uploaded file |
| link | URL | External link |
| title | string | Attachment title |
| content | text | Email export content |

Allowed file types: PDF, DOCX, PPTX, PNG, JPEG, JPG, ZIP (max 25 MB)

---

## 8. Troubleshooting

### Database Issues
```bash
# Migrate
docker-compose -f docker-compose.dev.yml exec backend python manage.py migrate
```

### File Upload Issues
1. Check MinIO is running: `docker-compose -f docker-compose.dev.yml ps minio`
2. Verify AWS credentials in `.env`:
   ```
   AWS_ACCESS_KEY_ID=minio
   AWS_SECRET_ACCESS_KEY=minio123
   AWS_STORAGE_BUCKET_NAME=capstone-attachments
   AWS_S3_ENDPOINT_URL=http://minio:9000
   ```

### Email Issues
1. Check Mailhog at http://localhost:8025
2. Verify SMTP settings in `.env`
3. For Gmail, generate new App Password

### Authentication Issues
1. Check Auth0 configuration in `.env`
2. Verify user exists in database

### Docker Issues
```bash
# Rebuild containers
docker-compose -f docker-compose.dev.yml down
docker-compose -f docker-compose.dev.yml up -d --build
```

---

For developers, see the backend [README.md](https://github.com/jmburke4/capstone-design-manager/blob/b35c08f4c0e82e3b91b8aaef572b9e97b944d132/backend/README.md) for technical documentation.