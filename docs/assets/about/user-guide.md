# User Guide - Capstone Design Manager

A comprehensive guide for all users of the Capstone Design Manager application, including Students, Sponsors, and Administrators.

## Table of Contents

1. [Overview](#1-overview)
2. [Getting Started](#2-getting-started)
3. [Student Guide](#3-student-guide)
4. [Sponsor Guide](#4-sponsor-guide)
5. [Admin Guide](#5-admin-guide)
6. [Email System](#6-email-system)
7. [Troubleshooting](#7-troubleshooting)

---

## 1. Overview

The Capstone Design Manager is a web-based application developed for the University of Alabama Computer Science department. Its primary purpose is for managing senior design projects by connecting students with external sponsors who provide project ideas.

This system streamlines the entire process of project submission, gathering student preferences, matching students to projects, and other project management such as email management. It serves as a centralized platform where sponsors can submit projects and administrators can oversee the entire process from beginning to end.

### User Roles

The system supports three distinct user roles, each with specific permissions and capabilities:

| Role | Description | Primary Responsibility |
|------|-------------|----------------------|
| **Student** | An enrolled UA Computer Science student who will be assigned to work on a senior design project | Browse projects, rank preferences, view assignment |
| **Sponsor** | An non-student professional from a company, organization or even from UA who submits project ideas for students to work on | Submit projects, provide feedback, track progress |
| **Admin** | A faculty member or staff administrator who manages the entire system | Manage all data, send emails, oversee process |

### Understanding the Workflow

The system follows a specific workflow that progresses through several stages throughout the semester:

**Stage 1 - Project Submission:**
Sponsors log into the system and submit their project proposals. Each sponsor can submit multiple projects based on their organization's needs and the limit set by the administrator. Admins can send emails to sponsors for submitting projects and for presenting the projects to students in class.

**Stage 2 - Student Preferences:**
After projects are submitted and reviewed, students log into the system to browse all available projects. Each student selects and ranks their top three choices in order of preference.

**Stage 3 - Assignment:**
After the preference deadline passes, the system or administrator creates assignments that match students to projects based on their preferences and other factors.

**Stage 4 - Project Execution:**
Students work on their assigned projects throughout the semester. Sponsors can view progress and provide feedback.

**Stage 5 - Completion:**
Projects are marked as complete when the semester ends and deliverables are submitted.

### System Features

The Capstone Design Manager provides the following features:

- **Project Submission Form**: A web-based form that sponsors use to submit their project ideas with detailed descriptions, requirements, and deliverables.

- **Project Browsing**: A searchable and filterable list of all available projects that students can browse to find projects that match their interests.

- **Preference Ranking System**: An intuitive system that allows students to rank their top three project choices in order of preference.

- **Automated Assignment**: A system that helps administrators create fair assignments based on student preferences.

- **Feedback System**: A messaging system that allows sponsors to communicate progress updates and concerns to students through the platform.

- **Attachment Management**: A file upload system that allows sponsors to share documents, images, and other relevant materials related to their projects.

- **Email Notification System**: An automated email system that sends notifications to sponsors and students about important updates, deadlines, and events.

- **Admin Control Panel**: A comprehensive administrative interface that provides full control over all aspects of the system.

---

## 2. Getting Started

This section explains how to access and set up your account on the Capstone Design Manager application.

### Accessing the Application

To access the Capstone Design Manager application, follow these steps:

1. Open your web browser (Chrome, Firefox, Safari, or Edge are recommended).
2. Navigate to https://ua-capstone-projects.com/
3. You will see the landing page with options to Sign Up or Log In.

![Application Landing Page](docs/assets/user-guide/landing-page.png)

### Understanding Authentication

The Capstone Design Manager uses OAuth for user authentication. OAuth is an industry-standard protocol that allows users to log in using third-party services (like Google or GitHub) without sharing passwords directly with the application.

### How User Accounts Are Created

**Sign-Up Process:**

When a user signs up for the first time, their account is created automatically:

1. User clicks **Sign Up** on the landing page
2. User selects their role (Student or Sponsor)
3. User authenticates using their chosen method (Google, GitHub, or email/password)
4. The system creates a user account
5. A verification email is sent to the user's email address
6. User clicks the verification link in the email
7. The verified user can now log in

**Role Assignment:**

- **Students**: The "student" role is automatically assigned when signing up as a student
- **Sponsors**: The "sponsor" role is automatically assigned when signing up as a sponsor
- **Admins**: The "admin" role must be manually assigned by an administrator

**Logging In:**

1. User clicks **Log In**
2. User authenticates using their chosen method
3. The system verifies their identity and creates a session

### Creating a New Account (Sign Up)

If you do not have an account yet, follow these steps to sign up:

1. Click the **Sign Up** button on the landing page.
2. You will be prompted to select your role. Choose one of the following:
   - **I am a Student** - Select this if you are enrolled in the capstone class
   - **I am a Sponsor** - Select this if you are providing project ideas as an external professional
3. Complete the sign-up process using your chosen authentication method:
   - For students: Enter your @crimson.ua.edu email and follow the prompts
   - For sponsors: Either sign in with Google/GitHub or create an email/password account
4. Check your email inbox for a verification email.
5. Click the verification link to confirm your email address.
6. Once verified, you can log in to the application.

### Logging Into Your Account

To log in after creating your account:

1. Click the **Log In** button on the landing page.
2. Choose your authentication method (Google, GitHub, or email/password).
3. Complete the authentication process.
4. You will be redirected to your dashboard based on your role.

![Log In Page](docs/assets/user-guide/log-in-page.png)

---

## 3. Student Guide

This section provides detailed instructions for students on how to use the Capstone Design Manager.

### Understanding the Student Dashboard

After successfully logging in, you will be taken to your Student Dashboard. This is your home page within the application and provides an overview of your status.

![Student Dashboard](docs/assets/user-guide/student/student-dashboard.png)

The Student Dashboard displays the following information:

- **Your Profile**: Your first and last name displayed at the top of the page
- **Your CWID**: Your 8-digit Campus-Wide ID number
- **Current Semester**: The current academic semester (Fall, Spring, or Summer)
- **Your Project Preferences**: A summary of the projects you have ranked
- **Your Project Assignment**: The project you have been assigned to (visible after the assignment date)

### Navigating the Student Interface

The student interface includes a sidebar with the following menu options:

- **All Projects**: Browse and view all available projects
- **My Preferences**: View and manage your project rankings
- **My Assignment**: View your final project assignment
- **Profile**: Update your personal information

![Student Sidebar Menu](docs/assets/user-guide/student/student-sidebar.png)

### How to View All Available Projects

To browse all projects that are available for the current semester:

1. Locate the sidebar on the left side of the screen.
2. Click on **All Projects**.
3. You will see a list of all projects that have been submitted by sponsors.

![Project List](docs/assets/user-guide/student/project-list.png)

The project list displays each project with:

- **Project Name**: The title of the project
- **Sponsor Organization**: The company or organization providing the project
- **Brief Description**: A short summary of the project (first 100-150 characters)
- **Status**: The current status of the project

**Understanding Project Status Values:**

| Status | Meaning |
|--------|----------|
| Pending | The project has been submitted but not yet started |
| In Progress | The project is active and students are working on it |
| Complete | The project has been finished |
| Cancelled | The project will not proceed |

### How to View Detailed Project Information

To see all details about a specific project:

1. From the **All Projects** page, click on the project name or the View/Edit icon.
2. A detailed view of the project will open.

![Project Details](docs/assets/user-guide/student/project-details.png)

The project details page shows:

- **Full Description**: Complete details about the project including goals, requirements, and deliverables
- **Sponsor Information**: The name of the sponsor and their organization
- **Website Link**: A link to additional information (if provided by the sponsor)
- **Attachments**: Files or documents uploaded by the sponsor
- **Feedback**: Progress updates from the sponsor

### How to Submit Your Preferences

As a student, you can rank up to three projects in order of preference. Your rankings are important because they help determine your final project assignment.

To submit or update your preferences:

1. Navigate to **All Projects** from the sidebar.
2. Browse the list of available projects.
3. When you find a project you are interested in, click on it to view the details.
4. Click the **Rank This Project** button.
5. Select your preferred rank number from the dropdown:
   - **Rank 1**: This is your first choice (most wanted)
   - **Rank 2**: This is your second choice
   - **Rank 3**: This is your third choice
6. Click **Submit** or **Save** to confirm your ranking.
7. Repeat these steps for other projects until you have ranked three projects.

![Rank Form](docs/assets/user-guide/student/rank-form.png)

**Important Rules for Preferences:**

- Each student can rank a maximum of three different projects.
- You cannot assign the same rank number to two different projects (Rank 1 is for one project only, Rank 2 is for one project only, etc.).
- You can change your rankings at any time before the preference deadline.
- After the deadline passes, your preferences are locked and cannot be changed.
- Not ranking any projects may result in a random assignment.

### How to View and Manage Your Preferences

To view your current rankings:

1. Click on **My Preferences** in the sidebar.
2. You will see a list of your ranked projects with their rank numbers.
3. From this page, you can:
   - View your current rankings
   - Change the rank of a project
   - Remove a project from your preferences

![My Preferences Page](docs/assets/user-guide/student/my-preferences.png)

### How to View Your Project Assignment

After the preference deadline passes and assignments are created, you can view your final project assignment:

1. Click on **My Assignment** in the sidebar.
2. Your assigned project will be displayed.

![My Assignment](docs/assets/user-guide/student/my-assignment.png)

The assignment page shows:

- **Project Name**: The name of your assigned project
- **Sponsor Name**: The name of the sponsor who submitted the project
- **Project Description**: The full project description
- **Contact Information**: How to reach your sponsor

### What to Do If You See "Not Registered"

If upon logging in you see a message indicating "Not Registered" or you cannot access student features:

![Not Registered](docs/assets/user-guide/student/not-registered.png)

This message appears when your account exists in the system but your student record has not been created in the database. To resolve this:

1. Contact your course instructor or the system administrator.
2. Ask them to add your student record to the database using your CWID.
3. Provide them with your:
   - Full name
   - CWID (8-digit number)
   - Email address (@crimson.ua.edu)
   - Major code
   - Class year

### How to Update Your Profile

To update your personal information:

1. Click on your name in the top-right corner of the screen.
2. Select **Profile** from the dropdown menu.
3. You can update the following fields:

| Field | Description | Notes |
|-------|-------------|-------|
| First Name | Your first name | Must match your university records |
| Last Name | Your last name | Must match your university records |
| Email | Your email address | Must be @crimson.ua.edu |
| Major Code | Your major | Examples: CS, CYS |
| Class Year | Your class standing | FR (Freshman), SO (Sophomore), JR (Junior), SR (Senior), GR (Graduate) |

4. Click **Save** to confirm your changes.

![Student Profile Form](docs/assets/user-guide/student/student-profile-form.png)
![Student Profile Saved](docs/assets/user-guide/student/student-profile-saved.png)

---

## 4. Sponsor Guide

This section provides detailed instructions for sponsors on how to use the Capstone Design Manager.

### Understanding the Sponsor Dashboard

After logging in, you will see your Sponsor Dashboard. This is your main page within the application.

![Sponsor Dashboard](docs/assets/user-guide/sponsor/sponsor-dashboard.png)

The Sponsor Dashboard displays:

- **Your Organization**: Your company or organization name
- **Projects Submitted**: The number of projects you have submitted
- **Project List**: A table showing your submitted projects with their current status

### Navigating the Sponsor Interface

The sponsor interface includes a sidebar with the following menu options:

- **Dashboard**: View your dashboard and project summary
- **New Project**: Submit a new project idea
- **My Projects**: View and manage your submitted projects
- **All Projects**: Browse all projects in the system
- **Profile**: Update your organization information

![Sponsor Sidebar Menu](docs/assets/user-guide/sponsor/sponsor-sidebar.png)

### How to Submit a New Project

To submit a new project idea for students to work on:

1. Click on **New Project** in the sidebar.
2. A project submission form will appear.

![New Project Form](docs/assets/user-guide/sponsor/new-project-form.png)

3. Fill in the following fields:

| Field | Required | Description |
|-------|----------|-------------|
| Project Name | Yes | A clear, descriptive title for your project |
| Description | Yes | Detailed information about the project including goals, deliverables, and requirements |
| Website | No | A link to additional information about the project or your organization |

4. Click the **Submit Project** button to save your project.

**Tips for Writing a Good Project Description:**

A well-written project description helps students understand your expectations and decide if the project matches their skills. Include the following information:

- **Project Goal**: What is the main objective or problem you are trying to solve?
- **Deliverables**: What specific items should students produce? (prototype, documentation, presentation, etc.)
- **Required Skills**: What technical skills or programming languages are needed?
- **Team Size**: How many students do you want working on this project? (typically 3-5)
- **Timeline**: Are there important milestones or deadlines?
- **Constraints**: Are there any budgetary, equipment, or other limitations?

### How to View and Manage Your Projects

To view all projects you have submitted:

1. Click on **My Projects** in the sidebar.
2. A list of your submitted projects will be displayed.

![My Projects](docs/assets/user-guide/sponsor/my-projects.png)

For each project, you can see:

- **Project Name**: The title of the project
- **Status**: Current status (Pending, In Progress, Complete, Cancelled)
- **Students Assigned**: Number of students assigned to the project

### How to Edit a Project

To make changes to a project you have submitted:

1. Go to **My Projects**.
2. Click on the project you want to edit.
3. Click the **Edit Project** button.
4. Update the fields as needed.
5. Click **Save Changes** to confirm your updates.

![Edit Project Form](docs/assets/user-guide/sponsor/edit-project-form.png)
![Project Edited Success](docs/assets/user-guide/sponsor/project-edited-success.png)

**Note:** You can only edit projects that have not yet been assigned to students, or edit the description/sponsor fields of assigned projects.

### How to Add Feedback About a Project

You can provide feedback to communicate with students working on your project:

1. Go to **My Projects**.
2. Click on the project you want to add feedback for.
3. Click the **Add Feedback** button.
4. Enter your feedback message in the text box.
5. Click **Submit** to save your feedback.

![Add Feedback](docs/assets/user-guide/sponsor/add-feedback.png)

**What to Include in Feedback:**

- Progress updates and observations
- Concerns or issues that need addressing
- Recommendations for the students
- Praise for good work
- Suggestions for improvement
- Final evaluation at the end of the semester

### How to Upload Attachments

You can upload documents, images, or other files related to your project:

1. Go to **My Projects**.
2. Click on the project you want to add an attachment to.
3. Click the **Add Attachment** button.
4. Choose the type of attachment:
   - **File Upload**: Click "Choose File" to select a file from your computer
   - **Link**: Enter a URL to an external website or document
5. If uploading a file, select the file from your computer.
6. Click **Upload** to save the attachment.

![Upload Attachment](docs/assets/user-guide/sponsor/upload-attachment.png)

**File Requirements:**

- Maximum file size: 25 MB
- Allowed file types: PDF, DOCX, PPTX, PNG, JPG, ZIP

### How to View Assigned Students

After the assignment date passes and students are assigned to projects:

1. Go to **My Projects**.
2. Click on your project.
3. Scroll to the "Assigned Students" section.
4. You will see a list of students assigned to your project.

![Assigned Students List](docs/assets/user-guide/sponsor/assigned-students-list.png)

Each student is displayed with:

- **Name**: Student's full name
- **CWID**: Student's Campus-Wide ID
- **Email**: Student's email address

### How to Update Your Profile

To update your organization and contact information:

1. Click on your name in the top-right corner.
2. Select **Profile** from the dropdown.
3. Update the following fields:

| Field | Description |
|-------|-------------|
| Organization | Your company or organization name |
| Phone Number | Your contact phone number |
| Website | Your organization website (optional) |

4. Click **Save** to confirm your changes.

![Sponsor Profile Form](docs/assets/user-guide/sponsor/sponsor-profile-form.png)

---

## 5. Admin Guide

This section provides detailed instructions for administrators on how to use the Django admin panel.

### Understanding Admin Access

There are two steps required to gain Django admin access in this system:

**Step 1 - Create a Sponsor Account:**
You must first create a user account in the system by signing up as a sponsor. Follow the sponsor sign-up process described in the Getting Started section.

**Step 2 - Assign Admin Role:**
The system administrator must assign the 'admin' role to your account.

**Step 3 - Create Django Superuser:**
After logging in with your sponsor account and seeing the admin button, you need to create your Django superuser credentials or have an existing administrator create them for you.

### Accessing the Admin Panel

Once you have completed the steps above, follow these instructions to access the admin panel:

1. Log in to the application with your sponsor account.
2. After logging in, look for the **Admin** button in the navigation.
3. Click the **Admin** button.
4. You will be redirected to the Django admin login page.
5. Enter your Django superuser credentials (username and password).
6. Click **Log In** to access the admin panel.

![Admin Button Location](docs/assets/user-guide/admin/admin-button-location.png)
![Django Admin Login](docs/assets/user-guide/admin/django-admin-login.png)

**Note:** If you do not see the Admin button after logging in, your account has not been assigned the admin role yet. Contact the system administrator to assign the 'admin' role to your account.

### Admin Panel Navigation

The admin panel is organized into sections:

- **PROJECT**: Contains all project-related data
  - Projects
  - Semesters
  - Preferences
  - Assignments
  - Attachments
  - Feedback
- **USER**: Contains all user-related data
  - Sponsors
  - Students
- **AUTHENTICATION AND AUTHORIZATION**: Django authentication system
  - Users
  - Groups

![Admin Navigation Menu](docs/assets/user-guide/admin/admin-navigation-menu.png)

### Managing Students

To add or edit student records:

1. In the admin panel, click on **Students** under the USER section.
2. Click **Add Student** to create a new student, or click on an existing student to edit.

![Student Admin](docs/assets/user-guide/admin/student-admin.png)

**Student Fields:**

| Field | Description | Required | Notes |
|-------|-------------|----------|-------|
| CWID | 8-digit Campus-Wide ID | Yes | Must be unique |
| First Name | Student's first name | Yes | |
| Last Name | Student's last name | Yes | |
| Email | Student's email address | Yes | Must be @crimson.ua.edu |
| Major Code | Major of study | Yes | CS, CYS, etc. |
| Class Code | Class year | Yes | FR, SO, JR, SR, GR |

**To Add a New Student:**

1. Click the **Add Student** button.
2. Fill in all required fields.
3. Click the **Save** button to create the student record.

![Add Student Form](docs/assets/user-guide/admin/add-student-form.png)
![Student Added Success](docs/assets/user-guide/admin/student-added-success.png)

### Managing Sponsors

To add or edit sponsor records:

1. Click on **Sponsors** under the USER section.
2. Click **Add Sponsor** to create a new sponsor, or click on an existing sponsor to edit.

![Sponsor Admin](docs/assets/user-guide/admin/sponsor-admin.png)

**Sponsor Fields:**

| Field | Description | Required | Notes |
|-------|-------------|----------|-------|
| First Name | Sponsor's first name | Yes | |
| Last Name | Sponsor's last name | Yes | |
| Email | Sponsor's email address | Yes | Must be unique |
| Organization | Company or organization name | Yes | |
| Phone Number | Contact phone number | No | |
| Projects Allowed | Maximum projects this sponsor can submit | Yes | Default is usually 3 |

### Managing Projects

To add or edit project records:

1. Click on **Projects** under the PROJECT section.
2. Click **Add Project** to create a new project, or click on an existing project to edit.

![Project Admin](docs/assets/user-guide/admin/project-admin.png)

**Project Fields:**

| Field | Description | Required | Notes |
|-------|-------------|----------|-------|
| Name | Project title | Yes | |
| Description | Full project description | Yes | |
| Sponsor | Sponsor who submitted the project | Yes | Select from dropdown |
| Status | Current status | Yes | See status values below |
| Website | External link | No | |

**Status Values:**

| Status Code | Meaning | Description |
|-------------|---------|-------------|
| PNDG | Pending | Project has been submitted but not yet started |
| IP | In Progress | Students are actively working on the project |
| CMPL | Complete | Project has been finished successfully |
| CNCL | Cancelled | Project will not proceed |

**Project Actions:**

From the projects list, you can perform bulk actions:

- **Change Status**: Select multiple projects and change their status in bulk
- **Assign to Semester**: Add selected projects to a specific semester
- **Remove from Semester**: Remove selected projects from a semester

![Project Bulk Actions](docs/assets/user-guide/admin/project-bulk-actions.png)

### Managing Semesters

To create and manage semesters:

1. Click on **Semesters** under the PROJECT section.
2. Click **Add Semester** to create a new semester.

![Semester Admin](docs/assets/user-guide/admin/semester-admin.png)

**Semester Fields:**

| Field | Description | Required | Notes |
|-------|-------------|----------|-------|
| Semester | Academic term | Yes | Fall, Spring, or Summer |
| Year | Academic year | Yes | 4-digit year (e.g., 2026) |
| Assignment Date | Deadline for student preferences | Yes | Date and time when preferences are locked |

![Add Semester Form](docs/assets/user-guide/admin/add-semester-form.png)

### Managing Preferences

To view student preferences:

1. Click on **Preferences** under the PROJECT section.
2. View all student project rankings.

![Preferences Admin](docs/assets/user-guide/admin/preferences-admin.png)

The preferences view shows:

- **Student**: The student who submitted the preference
- **Project**: The project being ranked
- **Rank**: The preference rank (1, 2, or 3)
- **Created**: When the preference was submitted

**Admin Actions for Preferences:**

- From the preferences list, you can select students and assign them to a project manually.

![Preferences Bulk Actions](docs/assets/user-guide/admin/preferences-bulk-actions.png)
![Assign Students to Project](docs/assets/user-guide/admin/assign-students-to-project.png)

### Managing Assignments

To view and create student assignments:

1. Click on **Assignments** under the PROJECT section.
2. View current student-to-project assignments.

![Assignments Admin](docs/assets/user-guide/admin/assignments-admin.png)

The assignments view shows:

- **Student**: The assigned student
- **Project**: The project they are assigned to
- **Created**: When the assignment was made

**Creating Assignments:**

Assignments can be created using:
- The "Assign selected students to project" admin action
- The assignment algorithm endpoint

### Managing Feedback

To view feedback from sponsors:

1. Click on **Feedback** under the PROJECT section.
2. View all feedback messages.

![Feedback Admin List](docs/assets/user-guide/admin/feedback-admin-list.png)

**Feedback Fields:**

| Field | Description |
|-------|-------------|
| Project | The project this feedback relates to |
| Sponsor | The sponsor who gave the feedback |
| Content | The feedback message |
| Created | Date and time the feedback was submitted |

![View Feedback Detail](docs/assets/user-guide/admin/view-feedback-detail.png)

### Managing Attachments

To view and manage all file uploads:

1. Click on **Attachments** under the PROJECT section.
2. View all uploaded files and links.

![Attachments Admin](docs/assets/user-guide/admin/attachments-admin.png)

**Attachment Fields:**

| Field | Description |
|-------|-------------|
| Project | The project this attachment belongs to |
| File | The uploaded file (click to download) |
| Link | An external URL |
| Title | A title for the attachment |
| Content | Email export content (for EML/HTML exports) |

**Downloading Attachments:**

- Click on the file name to download
- Click on EML attachments to open in your default email client

### Sending Bulk Emails to Sponsors

To send emails to multiple sponsors at once:

1. Click on **Sponsors** under the USER section.
2. Select the sponsors you want to email using the checkboxes.
3. From the "Action" dropdown menu, select an action:

| Action | Description |
|--------|-------------|
| Send Sponsor Outreach Email | Sends a recruitment email to selected sponsors via SMTP |
| Export Sponsor Outreach as EML | Creates downloadable EML files for each sponsor |
| Send Project Presentation Email | Sends presentation invitations for each project |
| Export Project Presentation as EML | Creates downloadable EML files for presentations |

4. Click the **Go** button to execute the action.
5. Fill in the email form details.
6. Click **Send** to send the emails, or download the attachments.

![Select Sponsors for Email](docs/assets/user-guide/admin/select-sponsors-for-email.png)
![Email Action Dropdown](docs/assets/user-guide/admin/email-action-dropdown.png)
![Email Form Fill](docs/assets/user-guide/admin/email-form-fill.png)
![Email Sent Success](docs/assets/user-guide/admin/email-sent-success.png)

---

## 6. Email System

This section explains the email functionality built into the Capstone Design Manager.

### Email Templates

The system includes predefined email templates:

**Sponsor Outreach Email:**
This email is sent to recruit new sponsors or remind existing sponsors to submit projects. It includes instructions on how to submit a project and relevant deadlines.

**Project Presentation Email:**
This email is sent to inform sponsors about their presentation time slot for the semester. It includes the date, time, and location (or virtual meeting link) for the presentation.

### How to Send Emails Through the Admin Panel

To send emails from the admin panel:

1. Navigate to the admin panel at `/admin/`.
2. Go to the Sponsors list.
3. Select the sponsors you want to send emails to.
4. Choose an email action from the dropdown.
5. Click the **Go** button.
6. Fill in the required fields in the email form.
7. Click **Send** to send immediately.

![Admin Email Send Flow](docs/assets/user-guide/admin/admin-email-send-flow.png)

### How to Use EML Files

If SMTP sending is not available or you prefer to send emails manually, you can export emails as EML files:

1. Select sponsors in the admin panel.
2. Choose either "Export Sponsor Outreach as EML" or "Export Project Presentation as EML".
3. Click **Go**.
4. The system creates attachment records with EML files.
5. Go to **Attachments** in the admin panel.
6. Click on each EML file to download.
7. Double-click the downloaded EML file to open it in your default email client (Outlook, Apple Mail, etc.).
8. The email will open as a new unsent message with the recipient pre-filled.
9. Click **Send** from your email client.

![Download EML Files](docs/assets/user-guide/admin/download-eml-files.png)
![EML File Opened in Email Client](docs/assets/user-guide/admin/eml-file-opened-email-client.png)

---

## 7. Troubleshooting

This section provides solutions to common problems you may encounter.

### Student Troubleshooting

| Issue | Possible Cause | Solution |
|-------|----------------|----------|
| Cannot log in | Not using @crimson.ua.edu email | Students must use their @crimson.ua.edu email address |
| Account exists but features not working | Student record not in database | Contact your instructor to be added to the system |
| Cannot rank projects | Past the preference deadline | Contact your instructor if you need an extension |
| Cannot view assignment | Assignments not yet created | Wait until after the assignment date, or contact the administrator |
| Profile information wrong | Incorrect data in database | Contact your instructor to correct your information |

### Sponsor Troubleshooting

| Issue | Possible Cause | Solution |
|-------|----------------|----------|
| Cannot log in | Account not recognized | Try using Google sign-in, or create a new account |
| Form says email already exists | Duplicate account | Try logging in instead, or use a different login method |
| Cannot submit project | Required fields empty | Fill in all required fields (Project Name and Description) |
| File upload fails | File too large or wrong type | Check that file is under 25 MB and is PDF, DOCX, PPTX, PNG, JPG, or ZIP |
| Cannot see students assigned | Assignments not yet created | Wait until after the assignment date |

### Admin Troubleshooting

| Issue | Possible Cause | Solution |
|-------|----------------|----------|
| Cannot access /admin/ | Not a superuser | Create a superuser account using `python manage.py createsuperuser` |
| Email sending fails | SMTP not configured | Check email settings in .env file |
| File upload fails | MinIO not running | Check that MinIO container is running |
| Students cannot log in | No student records | Add students to the database through the admin panel |

### Getting Help

If you continue to experience issues:

1. Check this troubleshooting section for a solution.
2. Contact your system administrator for technical support.
3. For development issues, consult the README.md file in the repository.

---

## Additional Information

### Email Communication

All email communication is sent from the system to notify users:

- **Sponsor Outreach**: Sent at the beginning of each semester to recruit projects
- **Project Presentation**: Sent to inform sponsors of their presentation time slot
- **Verification**: Sent when users need to verify their email address

### Data Storage

The application stores data in several places:

- **User Accounts**: Stored in the authentication system (Auth0)
- **Student/Sponsor Records**: Stored in PostgreSQL database
- **Project Information**: Stored in PostgreSQL database
- **Uploaded Files**: Stored in Google Cloud Storage

### Related Documentation

For more information, see these documents:

- **README.md** (root directory) - General project overview and setup instructions
- **backend/README.md** - Backend development documentation
- **frontend/README.md** - Frontend development documentation
- **backend/emails/README.md** - Email system details

---

## Quick Reference

### Application URLs

| Service | URL | Description |
|---------|-----|-------------|
| Main Application | https://ua-capstone-projects.com/ | The production web application |
| Admin Panel | https://ua-capstone-projects.com/admin/ | Django admin interface |
| REST API | https://ua-capstone-projects.com/api/v1/ | API endpoints |
| Local Development | http://localhost:5173 | Local frontend (development) |
| Local Admin | http://localhost:8000/admin | Local admin (development) |
| Email Testing | http://localhost:8025 | View sent emails (development) |

### Common Task Locations

| Task | User Role | Location in Application |
|------|----------|---------------------|
| Create account | All | Landing page > Sign Up |
| Log in | All | Landing page > Log In |
| Submit a project | Sponsor | Sidebar > New Project |
| View my projects | Sponsor | Sidebar > My Projects |
| View all projects | Student | Sidebar > All Projects |
| Rank project preferences | Student | All Projects > Rank This Project |
| View project assignment | Student | Sidebar > My Assignment |
| Add feedback to project | Sponsor | My Projects > project name > Add Feedback |
| Upload project files | Sponsor | My Projects > project name > Add Attachment |
| Manage all students | Admin | /admin/ > USER > Students |
| Manage all sponsors | Admin | /admin/ > USER > Sponsors |
| Manage all projects | Admin | /admin/ > PROJECT > Projects |
| Send sponsor emails | Admin | /admin/ > Select Sponsors > Choose Action |

---

### Google Cloud Deployment (Current Production)

This project is currently hosted on Google Cloud Platform. The deployment uses the following Google Cloud services:

- **Backend**: Hosted on Google Cloud Run
- **Database**: PostgreSQL on Google Cloud SQL
- **File Storage**: Google Cloud Storage for attachments
- **Frontend**: Firebase Hosting

**Google Cloud Credits:**

This project uses educational credits provided by Google Cloud for students. The $50 in credits covers the hosting costs for this semester.

---

For technical documentation for developers, please refer to the README.md file in the root directory and the backend/README.md file in the backend directory.