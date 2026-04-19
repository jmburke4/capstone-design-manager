# Troubleshooting

This guide covers common issues and their solutions.

## Database Issues

### Migrations Not Applied

**Symptom:** Error about missing columns or tables

**Solution:**
```bash
docker-compose -f docker-compose.dev.yml exec backend python manage.py migrate
```

### Reset Database

**WARNING: This deletes all data!**

```bash
# Stop containers
docker-compose -f docker-compose.dev.yml down

# Remove database volume
docker volume rm capstone-design-manager_postgres_data

# Restart containers
docker-compose -f docker-compose.dev.yml up -d

# Recreate tables
docker-compose -f docker-compose.dev.yml exec backend python manage.py migrate
docker-compose -f docker-compose.dev.yml exec backend python manage.py createsuperuser
```

---

## File Upload Issues

### Attachment Upload Fails

**Symptom:** Error when uploading files to attachments

**Possible Causes:**

1. **MinIO not running**
   ```bash
   docker-compose -f docker-compose.dev.yml logs minio
   docker-compose -f docker-compose.dev.yml up -d minio
   ```

2. **Bucket not created**
   ```bash
   docker-compose -f docker-compose.dev.yml logs minio-bootstrap
   ```

3. **Missing AWS credentials in .env**
   Ensure these are in your `.env`:
   ```
   AWS_ACCESS_KEY_ID=minioadmin
   AWS_SECRET_ACCESS_KEY=minioadmin
   AWS_STORAGE_BUCKET_NAME=capstone-attachments
   AWS_S3_ENDPOINT_URL=http://minio:9000
   ```

### File Size Too Large

**Symptom:** "File size must be 25 MB or less"

**Solution:** Compress the file or split into multiple attachments. Max allowed size is 25 MB.

### Unsupported File Type

**Symptom:** "File extension not allowed"

**Solution:** Supported file types are:
- PDF (.pdf)
- Word (.docx)
- PowerPoint (.pptx)
- Images (.png, .jpeg, .jpg)
- Archives (.zip)

---

## Email Issues

### Emails Not Sending

**Symptom:** Email action completes but recipient doesn't receive email

**Solutions:**

1. **Check Mailhog** (development captures all emails)
   - Go to http://localhost:8025
   - Verify email was captured

2. **Check SMTP settings in .env**
   ```env
   EMAIL_HOST=smtp.gmail.com
   EMAIL_PORT=587
   EMAIL_USE_TLS=True
   EMAIL_HOST_USER=your-email@gmail.com
   EMAIL_HOST_PASSWORD=your-app-password
   ```

3. **Gmail App Password issues**
   - Ensure 2-Factor Authentication is enabled
   - Generate a new App Password
   - App passwords are 16 characters with no spaces

### EML Files Not Opening

**Symptom:** Double-clicking .eml file doesn't open email client

**Solutions:**

1. **Set default mail app**
   - macOS: Mail > Settings > General > Default email app
   - Windows: Settings > Apps > Default apps > Email

2. **Try different email client**
   - Apple Mail works best on macOS
   - Thunderbird works well on all platforms

3. **Export as HTML instead**
   - Use the HTML export option instead of EML

---

## Authentication Issues

### Login Failed

**Symptom:** Can't log in through frontend

**Solutions:**

1. **Check Auth0 configuration**
   ```env
   AUTH0_DOMAIN=your-tenant.auth0.com
   AUTH0_CLIENT_ID=your-client-id
   AUTH0_AUDIENCE=https://your-api-audience/
   ```

2. **Verify student exists in database**
   - Email must match registration

3. **Check Auth0 dashboard**
   - Verify application is enabled
   - Check allowed callback URLs

### Admin Login Failed

**Symptom:** Can't access /admin

**Solution:**
```bash
docker-compose -f docker-compose.dev.yml exec backend python manage.py createsuperuser
```

---

## API Issues

### 401 Unauthorized

**Symptom:** API returns "Authentication credentials were not provided"

**Solution:** Include JWT token in request header:
```
Authorization: Bearer <your-token>
```

### 404 Not Found

**Symptom:** API endpoint returns 404

**Solution:** Verify base URL:
```
http://localhost:8000/api/v1/
```

---

## Docker Issues

### Container Won't Start

**Symptom:** `docker-compose up` fails

**Solutions:**

1. **Check port conflicts**
   ```bash
   lsof -i :8000  # Backend
   lsof -i :5432  # Database
   lsof -i :5173  # Frontend
   ```

2. **Rebuild containers**
   ```bash
   docker-compose -f docker-compose.dev.yml down
   docker-compose -f docker-compose.dev.yml up -d --build
   ```

3. **Clear Docker cache**
   ```bash
   docker system prune -a
   docker-compose -f docker-compose.dev.yml up -d --build
   ```

### Database Connection Failed

**Symptom:** Backend can't connect to database

**Solutions:**

1. **Check database container**
   ```bash
   docker-compose -f docker-compose.dev.yml ps db
   docker-compose -f docker-compose.dev.yml logs db
   ```

2. **Restart database**
   ```bash
   docker-compose -f docker-compose.dev.yml restart db
   ```

3. **Verify environment variables**
   ```env
   SQL_HOST=db
   SQL_DATABASE=DB_BACKEND
   SQL_USER=your_user
   SQL_PASSWORD=your_password
   ```

---

## Performance Issues

### Slow Page Load

**Solutions:**
- Check Docker resource usage
- Increase Docker memory allocation
- Clear browser cache

### Large Data Exports

**Solutions:**
- Export data in smaller batches
- Use CSV instead of XLSX for large datasets

---

## Getting Help

If you encounter an issue not covered here:

1. Check the backend logs:
   ```bash
   docker-compose -f docker-compose.dev.yml logs backend
   ```

2. Check the frontend logs:
   ```bash
   docker-compose -f docker-compose.dev.yml logs frontend
   ```

3. Search existing issues in the repository

4. Create a new issue with:
   - Steps to reproduce
   - Expected behavior
   - Actual behavior
   - Error messages
