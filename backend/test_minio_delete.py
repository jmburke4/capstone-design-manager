#!/usr/bin/env python
"""
Diagnostic script to test MinIO file deletion behavior.
Run with: python test_minio_delete.py
"""
from project.storage import S3MediaStorage
from user.models import Sponsor
from project.models import Project, Attachment
from django.core.files.uploadedfile import SimpleUploadedFile
import os
import django
import sys

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')
django.setup()


# Create a test sponsor and project
sponsor, _ = Sponsor.objects.get_or_create(
    email="test@example.com",
    defaults={
        "first_name": "Test",
        "last_name": "Sponsor",
        "organization": "Test Org",
        "phone_number": "(123) 456-7890",
    }
)

project, _ = Project.objects.get_or_create(
    name="Test Project",
    sponsor=sponsor,
)

# Create a test file attachment
test_file = SimpleUploadedFile(
    "test_deletion.pdf",
    b"This is test content for deletion",
    content_type="application/pdf",
)

print("=" * 80)
print("MINIO FILE DELETION DIAGNOSTIC TEST")
print("=" * 80)

try:
    # Create attachment
    attachment = Attachment.objects.create(
        project=project,
        file=test_file,
    )
    print(f"\n✓ Created attachment: {attachment.id}")
    print(f"  File name: {attachment.file.name}")
    print(f"  File size: {attachment.file.size}")

    # Check storage backend
    storage = attachment.file.storage
    print(f"\n✓ Storage backend: {storage.__class__.__name__}")
    print(f"  Bucket: {storage.bucket_name}")
    print(f"  Access Key ID: {storage.access_key[:5]}..." if storage.access_key else "  Access Key ID: Not set")
    print(f"  Endpoint URL: {storage.endpoint_url}")
    print(f"  Region: {storage.region_name}")

    # Try to verify the file exists in storage
    print(f"\n✓ Attempting to verify file exists...")
    file_exists = storage.exists(attachment.file.name)
    print(f"  File exists: {file_exists}")

    if file_exists:
        # Try to read the file to confirm it's accessible
        try:
            file_content = storage.open(attachment.file.name, 'rb').read()
            print(f"  File readable: True (size: {len(file_content)} bytes)")
        except Exception as e:
            print(f"  File readable: False - {str(e)}")

    # Now test deletion
    print(f"\n✓ Attempting to delete file from storage...")
    attachment_id = attachment.id

    # Delete the attachment (which should delete the file)
    try:
        attachment.delete()
        print(f"  ✓ Attachment deleted from database successfully")
    except Exception as e:
        print(f"  ✗ Error deleting attachment: {str(e)}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

    # Check if file still exists
    print(f"\n✓ Verifying file deletion...")
    file_still_exists = storage.exists(attachment.file.name)
    print(f"  File exists after deletion: {file_still_exists}")

    if file_still_exists:
        print(f"\n✗ WARNING: File still exists in MinIO after deletion!")
        try:
            file_content = storage.open(attachment.file.name, 'rb').read()
            print(f"  File is still readable (size: {len(file_content)} bytes)")
        except Exception as e:
            print(f"  File is not readable: {str(e)}")
    else:
        print(f"\n✓ File successfully deleted from MinIO storage")

    # Verify database record is gone
    if Attachment.objects.filter(id=attachment_id).exists():
        print(f"✗ Attachment record still exists in database!")
    else:
        print(f"✓ Attachment record removed from database")

except Exception as e:
    print(f"\n✗ Test failed with error: {str(e)}")
    import traceback
    traceback.print_exc()
    sys.exit(1)

print("\n" + "=" * 80)
print("DIAGNOSTIC TEST COMPLETE")
print("=" * 80)
