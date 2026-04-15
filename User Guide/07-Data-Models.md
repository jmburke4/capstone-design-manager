# Data Models

This document describes the database models in the system.

## Sponsor

Represents a project sponsor (faculty member, industry partner, etc.)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| first_name | string | Yes | Sponsor's first name |
| last_name | string | Yes | Sponsor's last name |
| email | email | Yes | Sponsor's email address |
| organization | string | No | Company or organization name |
| phone_number | string | No | Contact phone number |
| projects_allowed | integer | No | Max projects sponsor can offer (default: 3) |
| created_at | datetime | Auto | Record creation timestamp |
| updated_at | datetime | Auto | Last update timestamp |

**Constraints:**
- Email must be unique
- CWID must be exactly 8 digits

**String Representation:** `FirstName LastName`

---

## Student

Represents a student to be assigned to projects.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| cwid | string | Yes | Student CWID (8 digits) |
| first_name | string | Yes | Student's first name |
| middle_name | string | No | Student's middle name |
| last_name | string | Yes | Student's last name |
| preferred_name | string | No | Preferred name |
| email | email | Yes | Student's email |
| description | text | No | Skills, attributes |
| class_code | string | No | Class year (FR, SO, JR, SR, GR) |
| major_code | string | No | Major code (CS, CYS, etc.) |
| created_at | datetime | Auto | Record creation timestamp |
| updated_at | datetime | Auto | Last update timestamp |

**Constraints:**
- CWID must be unique and exactly 8 digits

**String Representation:** `FirstName LastName`

---

## Project

Represents a senior design project.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| name | string | Yes | Project name |
| description | text | No | Project description |
| sponsor | FK(Sponsor) | Yes | Project sponsor |
| sponsor_availability | text | No | When sponsor is available |
| status | choice | Yes | Project status |
| website | URL | No | Project website |
| created_at | datetime | Auto | Record creation timestamp |
| updated_at | datetime | Auto | Last update timestamp |

**Status Choices:**
- `PNDG` - Pending
- `IP` - In Progress
- `CMPL` - Complete
- `CNCL` - Cancelled

**Constraints:**
- Unique name per sponsor

**String Representation:** `ProjectName`

---

## Semester

Represents an academic semester.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| semester | choice | Yes | Fall, Spring, or Summer |
| year | integer | Yes | Year (1900-current+1) |
| assignment_date | datetime | Yes | Deadline for preferences |
| projects | M2M(Project) | No | Projects for this semester |
| created_at | datetime | Auto | Record creation timestamp |
| updated_at | datetime | Auto | Last update timestamp |

**Constraints:**
- Unique semester + year combination

**String Representation:** `Fall 2026`

---

## Preference

Student's ranked preference for a project.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | slug | Auto | Composite of student-project IDs |
| student | FK(Student) | Yes | The student |
| project | FK(Project) | Yes | The project |
| rank | integer | Yes | Preference rank (1, 2, or 3) |
| semester | FK(Semester) | Auto | Calculated from date |
| created_at | datetime | Auto | Record creation timestamp |
| updated_at | datetime | Auto | Last update timestamp |

**Constraints:**
- Rank must be 1, 2, or 3
- ID is auto-generated from student-project combination

**String Representation:** `StudentName (ProjectName)`

---

## Assignment

Final mapping of student to project for a semester.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | slug | Auto | Composite of student-semester IDs |
| semester | FK(Semester) | Yes | The semester |
| student | FK(Student) | Yes | The student |
| project | FK(Project) | Yes | The assigned project |
| created_at | datetime | Auto | Record creation timestamp |
| updated_at | datetime | Auto | Last update timestamp |

**String Representation:** `ProjectName -> StudentName (Semester)`

---

## Attachment

Files, links, or email exports associated with projects.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| project | FK(Project) | No | Associated project |
| file | file | No | Uploaded file |
| link | URL | No | External link |
| title | string | No | Attachment title |
| content | text | No | Email export content |
| created_at | datetime | Auto | Record creation timestamp |

**Constraints:**
- Either file, link, or content must be provided
- File types: PDF, DOCX, PPTX, PNG, JPEG, ZIP
- Max file size: 25 MB

**Validation:**
- For email exports, content alone is valid
- For regular attachments, either file or link is required (not both)

---

## Feedback

Notes from sponsors about project progress.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| sponsor | FK(Sponsor) | Yes | Sponsor providing feedback |
| project | FK(Project) | Yes | Project being discussed |
| semester | FK(Semester) | Yes | Relevant semester |
| text | text | Yes | Feedback content |
| created_at | datetime | Auto | Record creation timestamp |
| updated_at | datetime | Auto | Last update timestamp |

**String Representation:** `SponsorName (FeedbackID)`

---

## Key Relationships

```
Sponsor (1) ──────< Project (many)
    │                   │
    │                   │
    └───< Feedback      │
                            Semester (1) ──────< Assignment (many)
                                │                    │
                                │                    │
                                └────< Preference ───┘
                                               │
                                               │
                                         Project (1)
```
