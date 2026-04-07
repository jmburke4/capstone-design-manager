from django.core.management.base import BaseCommand
from django.core.files.uploadedfile import SimpleUploadedFile
from project.models import Project, Attachment
from user.models import Sponsor
import logging

logger = logging.getLogger(__name__)


class Command(BaseCommand):
    help = 'Test MinIO file deletion behavior'

    def handle(self, *args, **options):
        # Create a test sponsor and project
        sponsor, _ = Sponsor.objects.get_or_create(
            email="test-delete@example.com",
            defaults={
                "first_name": "Test",
                "last_name": "Delete",
                "organization": "Test Org",
                "phone_number": "(123) 456-7890",
            }
        )

        project, _ = Project.objects.get_or_create(
            name="Test Delete Project",
            sponsor=sponsor,
        )

        # Create a test file attachment
        test_file = SimpleUploadedFile(
            "test_delete_diagnostic.pdf",
            b"Test content for deletion diagnostic",
            content_type="application/pdf",
        )

        self.stdout.write("\n" + "="*80)
        self.stdout.write("MINIO FILE DELETION DIAGNOSTIC")
        self.stdout.write("="*80)

        # Create attachment
        attachment = Attachment.objects.create(
            project=project,
            file=test_file,
        )
        self.stdout.write(f"\n✓ Created attachment: {attachment.id}")
        self.stdout.write(f"  File name: {attachment.file.name}")

        # Check storage
        storage = attachment.file.storage
        file_name = attachment.file.name

        # Verify file exists
        file_exists = storage.exists(file_name)
        self.stdout.write(f"\n✓ File exists in MinIO: {file_exists}")

        if file_exists:
            try:
                f = storage.open(file_name, 'rb')
                content = f.read()
                f.close()
                self.stdout.write(f"  File readable: True (size: {len(content)} bytes)")
            except Exception as e:
                self.stdout.write(f"  File readable: False - {e}")

        # Delete attachment
        self.stdout.write(f"\n✓ Deleting attachment...")
        attachment_id = attachment.id
        attachment.delete()

        # Check if file still exists
        file_exists_after = storage.exists(file_name)
        self.stdout.write(f"\n✓ File exists after deletion: {file_exists_after}")

        if file_exists_after:
            self.stdout.write(f"  ✗ WARNING: File still exists!")
            try:
                f = storage.open(file_name, 'rb')
                content = f.read()
                f.close()
                self.stdout.write(f"    File is readable (size: {len(content)} bytes)")
            except Exception as e:
                self.stdout.write(f"    File is not readable: {e}")
        else:
            self.stdout.write(f"  ✓ File successfully deleted")

        # Check database
        if Attachment.objects.filter(id=attachment_id).exists():
            self.stdout.write(f"  ✗ Attachment record still in database!")
        else:
            self.stdout.write(f"  ✓ Attachment record removed")

        self.stdout.write("\n" + "="*80)
