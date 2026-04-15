# Email System

The system provides email functionality for sponsor outreach and project presentations.

## Email Templates

### Sponsor Outreach Email
Sent to potential sponsors to recruit project ideas. Includes:
- Collection date for project submissions
- Spring/Fall semester selection

### Project Presentation Email
Sent to sponsors with their presentation time slot. Includes:
- Date and time
- Zoom meeting details
- Presentation guidelines

## Sending Emails

### Via Admin Panel

1. Go to **USER** > **Sponsors**
2. Select one or more sponsors
3. Choose an email action from the dropdown:
   - **Send Sponsor Outreach Email**
   - **Send Project Presentation Email**
4. Fill in the email details
5. Click **Send Email** or **Send Emails**

### SMTP Configuration

By default, emails are sent using the configured SMTP settings. To send from a different email:

1. In the email action form, expand the **SMTP Settings** section
2. Fill in:
   - From Email
   - SMTP Host (e.g., smtp.gmail.com)
   - SMTP Port (default: 587)
   - SMTP Username
   - SMTP Password (or App Password for Gmail)
3. Leave blank to use default settings

### Gmail Configuration

For Gmail, you need an App Password:

1. Enable 2-Factor Authentication on your Google account
2. Go to Google Account > Security
3. Under "2-Step Verification", click **App passwords**
4. Select "Mail" and your device
5. Copy the 16-character app password
6. Use this as the SMTP Password

## Exporting Emails as EML Drafts

Instead of sending directly, you can export emails as EML files that open in the user's default email client (Outlook, Apple Mail, etc.).

### How It Works

1. Select sponsors in the admin panel
2. Choose **Export as EML** action
3. Fill in email details
4. Preview the email
5. Create attachments
6. Download the EML files from the Attachments page

### Benefits of EML Export

- User can edit the email before sending
- Email is sent from the user's own email account
- No SMTP configuration needed on the server

### Opening EML Files

**Apple Mail**: Double-click the .eml file
**Microsoft Outlook**: Double-click the .eml file
**Thunderbird**: File > Open > Saved Message

## Email Testing with Mailhog

During development, all emails are captured by Mailhog instead of being sent.

Access Mailhog at: http://localhost:8025

From Mailhog, you can:
- View all sent emails
- Check email content and formatting
- Forward emails to real recipients
- Delete emails

## API Endpoints

### Send Email
```
POST /api/v1/emails/send
```

Request body:
```json
{
  "to": ["recipient@example.com"],
  "subject": "Email Subject",
  "body": "Email body text",
  "html": "<p>HTML version</p>"
}
```

### Send Sponsor Outreach
```
POST /api/v1/emails/sponsor-outreach
```

Request body:
```json
{
  "to": ["sponsor@example.com"],
  "semester": "spring",
  "collection_date": "Spring 2025 (1/14/25)"
}
```

### Send Project Presentation
```
POST /api/v1/emails/project-presentation
```

Request body:
```json
{
  "to": ["sponsor@example.com"],
  "date": "Tuesday Jan 14, 2025",
  "time": "3:45 - 4:00",
  "project_name": "Project Name",
  "project_description": "Description",
  "contact_name": "John Doe",
  "contact_email": "john@ua.edu",
  "zoom_details": "https://zoom.us/j/..."
}
```

## Troubleshooting

### Emails Not Sending

1. Check SMTP credentials
2. Verify email credentials in `.env` file
3. For Gmail, ensure App Password is correct
4. Check Mailhog at http://localhost:8025

### EML Files Not Opening

- **New Outlook**: EML support may be limited. Try Apple Mail or Thunderbird
- **Outlook Desktop**: Ensure Outlook is set as default mail client

### Authentication Errors

- Gmail: Generate new App Password
- Check SMTP username and password
- Verify 2FA is enabled for Gmail
