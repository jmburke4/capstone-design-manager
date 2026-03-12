from django.db import models
from user.models import Sponsor, Student
from django.utils.translation import gettext_lazy as _
from django.utils.text import slugify

# The project module will handle project, preference, and assignment objects
# Fields are ordered by importance descending


class Project(models.Model):
    """Model representing a senior design project that students can be assigned to"""

    name = models.CharField(max_length=100)
    """[Required] Project name"""

    description = models.TextField(blank=True, null=True)
    """[Optional] A description of the project"""

    sponsor = models.ForeignKey(
        Sponsor,
        on_delete=models.PROTECT
    )
    """[Required] FK to a Sponsor (on_delete=PROTECT)"""

    class StatusChoices(models.TextChoices):
        IN_PROGRESS = 'IP', _('In Progress')
        CANCELLED = 'CNCL', _('Cancelled')
        COMPLETE = 'CMPL', _('Complete')
        PENDING = 'PNDG', _('Pending')

    status = models.CharField(
        max_length=4,
        choices=StatusChoices.choices,
        default=StatusChoices.PENDING
    )
    """[Required] The current status of the project"""

    # TODO Adapt this field to be allowed to support multiple URLs
    website = models.URLField(blank=True, null=True)
    """[Optional] A URL field for the project's website"""

    created_at = models.DateTimeField(auto_now_add=True)
    """[Default] Tracks when the record was created"""

    updated_at = models.DateTimeField(auto_now=True)
    """[Default] Tracks when the record was last updated"""

    def __str__(self):
        return self.name


class Preference(models.Model):
    """Model representing a student's ranked preference for a project"""

    id = models.SlugField(max_length=64, primary_key=True, editable=False)
    """[Calculated] A slug field that serves as the PK for the model, this is generated from the student and project FKs"""

    student = models.ForeignKey(
        Student,
        on_delete=models.CASCADE
    )
    """[Required] FK to a Student"""

    project = models.ForeignKey(
        Project,
        on_delete=models.CASCADE
    )
    """[Required] FK to a Project"""

    class RankChoices(models.IntegerChoices):
        ONE = 1, '1'
        TWO = 2, '2'
        THREE = 3, '3'

    rank = models.PositiveSmallIntegerField(
        choices=RankChoices.choices
    )
    """[Required] Number rank of student's preference toward project, 1 being the first choice"""

    created_at = models.DateTimeField(auto_now_add=True)
    """[Default] Tracks when the record was created"""

    updated_at = models.DateTimeField(auto_now=True)
    """[Default] Tracks when the record was last updated"""

    def generate_id(self, student_id=None, project_id=None):
        """Generates a slug from the student and project FKs, this is used as the PK for the model"""
        if (not student_id or not project_id) and self:
            student_id = self.student.id
            project_id = self.project.id
        return slugify(f'{student_id}-{project_id}')

    # Override the model save method to compute the slug from the fields on saving to DB
    def save(self, *args, **kwargs):
        if not self.id:
            self.id = self.generate_id()
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.student} ({self.project})"


class Assignment(models.Model):
    # Available person enumerable
    class PersonType(models.TextChoices):
        SPONSOR = "sponsor", "Sponsor"
        STUDENT = "student", "Student"

    # Available semester enumerable
    class Semester(models.TextChoices):
        FALL = "fall", "Fall"
        SPRING = "spring", "Spring"
        SUMMER = "summer", "Summer"

    # [Required] FK to a project object
    project = models.ForeignKey(
        "project.Project",
        related_name="assignments",
        on_delete=models.CASCADE,
    )

    # [Required] FK to a student or sponsor
    person_id = models.PositiveIntegerField()

    # [Required] Whether the person is a student or a sponsor
    person_type = models.CharField(
        max_length=10,
        choices=PersonType.choices,
    )

    # [Required] The semester that this assignment is valid for
    semester = models.CharField(
        max_length=10,
        choices=Semester.choices,
    )

    # [Required] The year that this assignment is valid for
    year = models.PositiveIntegerField()

    # [Default] Tracks when the record was created
    created_at = models.DateTimeField(auto_now_add=True)

    # [Default] Tracks when the Assignment record was updated
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.person_type} {self.person_id} → {self.project} ({self.semester} {self.year})"
