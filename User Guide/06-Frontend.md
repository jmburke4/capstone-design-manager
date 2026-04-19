# Frontend Application

The frontend provides a user-friendly interface for students to view projects and submit preferences.

## Access

Frontend URL: http://localhost:5173

## Navigation

### Student Features

#### Login
Students log in using their Auth0 credentials. The system validates their CWID against the database.

#### Dashboard
After login, students see their dashboard with:
- Current semester information
- Their submitted preferences
- Project assignment status

#### View Projects
Students can browse available projects:
1. Click on **Projects** or **Browse Projects**
2. View project cards with:
   - Project name
   - Sponsor name
   - Brief description
   - Status badge

#### Submit Preferences
1. Go to the preferences section
2. Select up to 3 projects in order of preference
3. Rank 1 = First choice, Rank 2 = Second choice, Rank 3 = Third choice
4. Save preferences

#### View Assignment
Once assignments are made by administrators, students can:
1. Go to **My Assignment**
2. See their assigned project
3. View project details

## User Roles

### Student
- View projects
- Submit preferences (up to 3)
- View own assignment
- View own profile

### Administrator
(Access via Admin Panel at /admin)
- Full CRUD for all models
- Assign students to projects
- Manage semesters
- Send emails

## Screenshots

### Project List
Displays all available projects in a card layout with filtering options.

### Preference Form
Form for selecting and ranking project preferences.

### Assignment View
Shows the final project assignment for the semester.

## Troubleshooting

### Login Issues
- Ensure your CWID exists in the database
- Check Auth0 configuration
- Verify email matches CWID registration

### Preferences Not Saving
- Check that you're ranking exactly 1, 2, 3
- Ensure no duplicate project rankings
- Verify semester is active
