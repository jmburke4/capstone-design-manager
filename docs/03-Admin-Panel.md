# Admin Panel

The admin panel provides full management capabilities for all system data. Access it at http://localhost:8000/admin

## Navigation

The admin panel is organized into sections:

- **PROJECT**: Projects, Semesters, Preferences, Assignments, Attachments, Feedback
- **USER**: Sponsors, Students
- **EMAILS**: Email management

## Managing Sponsors

### Viewing Sponsors
1. Go to **USER** > **Sponsors**
2. View all sponsors with their organization and project count
3. Use search to find specific sponsors
4. Use filters to narrow by organization

### Adding a Sponsor
1. Click **Add Sponsor**
2. Fill in required fields:
   - First Name
   - Last Name
   - Email
3. Fill in optional fields:
   - Organization
   - Phone Number
   - Projects Allowed (default: 3)
4. Click **Save**

### Editing a Sponsor
1. Click on a sponsor's name
2. Modify fields as needed
3. Click **Save**

### Deleting a Sponsor
1. Select the sponsor checkbox
2. From the **Action** dropdown, select **Delete selected sponsors**
3. Click **Go**

## Managing Students

### Viewing Students
1. Go to **USER** > **Students**
2. View all students with their CWID, name, and contact info
3. Search by name, CWID, or email

### Adding a Student
1. Click **Add Student**
2. Fill in required fields:
   - CWID (8 digits)
   - First Name
   - Last Name
   - Email
3. Fill in optional fields:
   - Middle Name
   - Preferred Name
   - Description
   - Major Code (e.g., CS, CYS)
   - Class Code (FR, SO, JR, SR, GR)
4. Click **Save**

## Managing Projects

### Viewing Projects
1. Go to **PROJECT** > **Projects**
2. View all projects with sponsor and status
3. Filter by:
   - Status (Pending, In Progress, Complete, Cancelled)
   - Semester
   - Sponsor

### Adding a Project
1. Click **Add Project**
2. Fill in required fields:
   - Name
   - Sponsor (select from dropdown)
3. Fill in optional fields:
   - Description
   - Website URL
   - Sponsor Availability
   - Status (default: Pending)
4. Click **Save**

### Changing Project Status
1. Select one or more projects
2. From the **Action** dropdown, select **Change project status**
3. Choose the new status
4. Click **Go**

## Managing Semesters

### Viewing Semesters
1. Go to **PROJECT** > **Semesters**
2. View all semesters with assignment dates

### Adding a Semester
1. Click **Add Semester**
2. Fill in fields:
   - Semester (Fall, Spring, Summer)
   - Year
   - Assignment Date (deadline for preferences)
3. Click **Save**

### Adding Projects to a Semester
1. Edit a semester
2. In the **Projects** field, select available projects
3. Click **Save**

## Managing Preferences

### Viewing Preferences
1. Go to **PROJECT** > **Preferences**
2. View all student preferences
3. Filter by:
   - Semester
   - Student Assigned (Yes/No)
   - Rank (1, 2, 3)
   - Project

### Assigning Students to Projects
1. Select student preferences
2. From the **Action** dropdown, select **Assign to project**
3. Choose the target project
4. Click **Go**

## Managing Assignments

### Viewing Assignments
1. Go to **PROJECT** > **Assignments**
2. View all student-project assignments by semester

### Manual Assignment
Assignments are typically created through the preference workflow, but can be manually created by adding a preference.

## Managing Attachments

### Viewing Attachments
1. Go to **PROJECT** > **Attachments**
2. View attachments with type badges (EML, HTML, File, Link)
3. See accepted file types at the bottom of the page

### Adding an Attachment
1. Click **Add Attachment**
2. Choose one of these methods:

**Option A - File Upload:**
- Select a project
- Upload a file (PDF, DOCX, PPTX, PNG, JPEG, ZIP)
- Max file size: 25 MB

**Option B - Link:**
- Select a project
- Enter a URL

**Option C - Email Export (EML/HTML):**
- Leave project blank
- Use the Sponsor email actions to create email exports

### Downloading Attachments
1. Find the attachment in the list
2. Click the **Download** button

### Email Export Attachments
When creating email exports from sponsor actions, attachments are created with:
- **EML**: Email drafts that open in the user's default email client
- **HTML**: Email content as HTML files

## Managing Feedback

### Viewing Feedback
1. Go to **PROJECT** > **Feedback**
2. View all sponsor feedback notes

### Adding Feedback
1. Click **Add Feedback**
2. Select:
   - Sponsor
   - Project
   - Semester
3. Enter feedback text
4. Click **Save**

## Bulk Import/Export

### Exporting Data
1. Go to any model list (e.g., Sponsors)
2. Select items to export (or select all)
3. From the **Action** dropdown:
   - **Export to CSV**
   - **Export to XLSX**

### Importing Data
1. Go to any model list
2. Click **Import**
3. Upload a CSV or XLSX file
4. Map columns to fields
5. Review and confirm import

## Sponsor Email Actions

From the Sponsors list, you can:

### Send Sponsor Outreach Email
1. Select one or more sponsors
2. Choose **Send Sponsor Outreach Email**
3. Fill in:
   - Semester (Spring/Fall)
   - Collection Date
4. Optionally configure SMTP settings for a different sender
5. Click **Send Email**

### Export Sponsor Outreach as EML
1. Select one or more sponsors
2. Choose **Export Sponsor Outreach as EML**
3. Fill in semester and collection date
4. Preview the email
5. Click **Create Attachment**

### Send Project Presentation Email
1. Select one or more sponsors
2. Choose **Send Project Presentation Email**
3. Fill in:
   - Date
   - Time
   - Zoom Details
4. Optionally configure SMTP settings
5. Click **Send Emails**

### Export Project Presentation as EML
1. Select one or more sponsors
2. Choose **Export Project Presentation as EML**
3. Fill in date, time, and Zoom details
4. Preview the email
5. Click **Create Attachments**
