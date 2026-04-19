# Overview

## System Description

The UA Computer Science Senior Design Projects Portal is a web application that manages the assignment of students to senior design projects. It provides:

- **Admin Panel**: For administrators to manage sponsors, students, projects, and assignments
- **REST API**: For frontend applications to interact with the data
- **Email System**: For sending outreach emails to sponsors and project presentations
- **Student Portal**: For students to submit their project preferences

## Technology Stack

### Backend
- **Framework**: Django 5.2 with Django REST Framework
- **Database**: PostgreSQL 17
- **File Storage**: MinIO (S3-compatible object storage)
- **Email**: SMTP (Gmail integration)

### Frontend
- **Framework**: React with Vite
- **Styling**: CSS Modules

### Infrastructure
- **Containerization**: Docker & Docker Compose
- **Authentication**: Auth0

## Key Concepts

### Students
Students are the end users who will be assigned to projects. They submit their preferences (ranked choices) for which projects they want to work on.

### Sponsors
Sponsors are external individuals or organizations that provide senior design projects. Each sponsor can have multiple projects.

### Projects
Projects are the actual senior design work that students will complete. Each project belongs to one sponsor and has a status (Pending, In Progress, Complete, Cancelled).

### Semesters
Semesters track when projects are offered. Each semester has an assignment date by which all student preferences must be submitted.

### Preferences
Students submit ranked preferences for projects. A student can rank up to 3 projects in order of preference.

### Assignments
Assignments are the final mapping of students to projects for a given semester.

### Attachments
Files or links associated with projects, including documents, images, and exported email drafts.

### Feedback
Notes and feedback from sponsors about project progress.
