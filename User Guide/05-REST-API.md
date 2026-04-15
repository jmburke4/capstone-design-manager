# REST API

The system provides a RESTful API for frontend applications and integrations.

## Base URL

```
http://localhost:8000/api/v1/
```

## Authentication

The API uses Auth0 for authentication. Include the JWT token in the Authorization header:

```
Authorization: Bearer <your-token>
```

## Endpoints

### Projects

#### List Projects
```
GET /api/v1/projects/
```

Query parameters:
- `status`: Filter by status (IP, PNDG, CMPL, CNCL)
- `sponsor`: Filter by sponsor ID
- `semester`: Filter by semester ID
- `search`: Search by name or description

#### Get Project
```
GET /api/v1/projects/{id}/
```

#### Create Project
```
POST /api/v1/projects/
```

Request body:
```json
{
  "name": "Project Name",
  "description": "Project description",
  "sponsor": 1,
  "status": "PNDG"
}
```

#### Update Project
```
PUT /api/v1/projects/{id}/
```

#### Delete Project
```
DELETE /api/v1/projects/{id}/
```

### Students

#### List Students
```
GET /api/v1/students/
```

Query parameters:
- `search`: Search by name or CWID
- `major_code`: Filter by major
- `class_code`: Filter by class

#### Get Student
```
GET /api/v1/students/{cwid}/
```

#### Create Student
```
POST /api/v1/students/
```

Request body:
```json
{
  "cwid": "12345678",
  "first_name": "John",
  "last_name": "Doe",
  "email": "john@ua.edu",
  "major_code": "CS",
  "class_code": "SR"
}
```

### Semesters

#### List Semesters
```
GET /api/v1/semesters/
```

#### Get Semester
```
GET /api/v1/semesters/{id}/
```

#### Create Semester
```
POST /api/v1/semesters/
```

Request body:
```json
{
  "semester": "Fall",
  "year": 2026,
  "assignment_date": "2026-08-24T17:00:00Z"
}
```

### Preferences

#### List Preferences
```
GET /api/v1/preferences/
```

Query parameters:
- `student`: Filter by student ID
- `project`: Filter by project ID
- `semester`: Filter by semester ID
- `rank`: Filter by rank (1, 2, 3)

#### Get Preference
```
GET /api/v1/preferences/{student_id}-{project_id}/
```

Note: The preference ID is a slug combining student ID and project ID.

#### Create/Update Preferences (Bulk)
```
PUT /api/v1/preferences/
```

Request body:
```json
{
  "student": 1,
  "preferences": [
    {"project": 1, "rank": 1},
    {"project": 2, "rank": 2},
    {"project": 3, "rank": 3}
  ]
}
```

This endpoint creates or updates multiple preferences for a student in one request.

### Assignments

#### List Assignments
```
GET /api/v1/assignments/
```

Query parameters:
- `student`: Filter by student ID
- `project`: Filter by project ID
- `semester`: Filter by semester ID

#### Get Assignment
```
GET /api/v1/assignments/{student_id}-{semester_id}/
```

### Attachments

#### List Attachments
```
GET /api/v1/attachments/
```

Query parameters:
- `project`: Filter by project ID

#### Get Attachment
```
GET /api/v1/attachments/{id}/
```

#### Download Attachment
```
GET /api/v1/attachments/{id}/download/
```

Returns the file content with appropriate Content-Type header.

### Feedback

#### List Feedback
```
GET /api/v1/feedback/
```

Query parameters:
- `sponsor`: Filter by sponsor ID
- `project`: Filter by project ID
- `semester`: Filter by semester ID

#### Get Feedback
```
GET /api/v1/feedback/{id}/
```

#### Create Feedback
```
POST /api/v1/feedback/
```

Request body:
```json
{
  "sponsor": 1,
  "project": 1,
  "semester": 1,
  "text": "Feedback note"
}
```

## Response Format

### Success Response
```json
{
  "id": 1,
  "name": "Example",
  "created_at": "2026-01-01T00:00:00Z"
}
```

### List Response with Pagination
```json
{
  "count": 100,
  "next": "http://localhost:8000/api/v1/projects/?page=2",
  "previous": null,
  "results": [
    {"id": 1, "name": "Project 1"},
    {"id": 2, "name": "Project 2"}
  ]
}
```

### Error Response
```json
{
  "field_name": ["Error message"]
}
```

## HTTP Status Codes

| Code | Description |
|------|-------------|
| 200 | Success |
| 201 | Created |
| 204 | No Content (deleted) |
| 400 | Bad Request (validation error) |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 500 | Server Error |

## Filtering Examples

### Get In-Progress Projects
```
GET /api/v1/projects/?status=IP
```

### Get Preferences for a Student
```
GET /api/v1/preferences/?student=1
```

### Get Assignments for Fall 2026
```
GET /api/v1/assignments/?semester=1
```

## Rate Limiting

No rate limiting is currently enforced in development. Production deployments may have rate limits.
