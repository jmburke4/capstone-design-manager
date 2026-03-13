## Configuration

Configure emails via the environment variables in your `.env.dev` file as so:

| Variable | Description | Default |
|----------|-------------|---------|
| `EMAIL_BACKEND` | Email backend | `django.core.mail.backends.console.EmailBackend` |
| `EMAIL_HOST` | SMTP server hostname | `localhost` |
| `EMAIL_PORT` | SMTP server port | `1025` |
| `EMAIL_USE_TLS` | Use TLS | `False` |
| `EMAIL_HOST_USER` | SMTP username | (empty) |
| `EMAIL_HOST_PASSWORD` | SMTP password | (empty) |
| `DEFAULT_FROM_EMAIL` | Default sender email | `noreply@example.com` |
| `EMAIL_FAIL_SILENTLY` | Fail silently on error | `False` |

### Production (Gmail SMTP)

```bash
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password
DEFAULT_FROM_EMAIL=your-email@gmail.com
```

**Note:** Gmail requires an App Password, not your regular password. Generate one at: https://myaccount.google.com/apppasswords. If you can't, enable two factor authentication on your account.


### Using the API


## Templates

Email templates are located in `backend/emails/templates/emails/`:

- `sponsor_outreach.txt` - Plain text sponsor outreach email
- `sponsor_outreach.html` - HTML sponsor outreach email
- `base.html` - absolute basic text for an email template

## Frontend

The frontend provides two pages for sending emails:

1. **Send Email** (`/email`) - Send custom emails with subject, message, and recipients
2. **Sponsor Outreach** (`/sponsor-outreach`) - Send the sponsor outreach template

Access these at `http://localhost:5173/email` and `http://localhost:5173/sponsor-outreach` when the frontend is running.
